extends GdUnitTestSuite

# Stage 1 test suite: validates JumpCommand behavior and the "jump" Input Map action.
# Runs in both the GdUnit4 GUI and headless (runtest.sh) modes.
#
# JumpCommand is loaded dynamically by path (never referenced by class_name) so this
# suite still parses and runs before a student creates it; the tests that need it are
# skipped with a clear reason instead of crashing the whole suite.
#
# is_on_floor() is a native CharacterBody2D getter and cannot be overridden from
# GDScript, so the "on floor" case is tested with a real CollisionShape2D/StaticBody2D
# floor instead of a mock. command_callback() is plain GDScript, so it can be spied on.
const JUMP_COMMAND_PATH := "res://scripts/commands/Player/jump_command.gd"
const NOT_IMPLEMENTED_REASON := "JumpCommand not implemented yet (expected at res://scripts/commands/Player/jump_command.gd)"

class SpyCharacter:
	extends Character

	var last_callback := ""

	func command_callback(cmd_name: String) -> void:
		last_callback = cmd_name


static func _jump_command_implemented() -> bool:
	return ResourceLoader.exists(JUMP_COMMAND_PATH)


func _new_jump_command() -> Command:
	var script := load(JUMP_COMMAND_PATH) as GDScript
	return script.new() as Command


func _make_character() -> SpyCharacter:
	var character := SpyCharacter.new()

	# Character._ready() expects these via @onready; provide stubs to avoid "Node not found" noise.
	var animation_player := AnimationPlayer.new()
	animation_player.name = "AnimationPlayer"
	character.add_child(animation_player)

	var sprite := Sprite2D.new()
	sprite.name = "Sprite2D"
	character.add_child(sprite)

	var dialogue_box := DialogueBox.new()
	dialogue_box.name = "DialogueBox"
	var margin := MarginContainer.new()
	margin.name = "MarginContainer"
	var label := Label.new()
	label.name = "Label"
	margin.add_child(label)
	dialogue_box.add_child(margin)
	var nine_patch := NinePatchRect.new()
	nine_patch.name = "NinePatchRect"
	dialogue_box.add_child(nine_patch)
	dialogue_box.unique_name_in_owner = true
	character.add_child(dialogue_box)
	dialogue_box.owner = character

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(16, 16)
	shape.shape = rect
	character.add_child(shape)
	add_child(character)
	return auto_free(character)


func _settle_onto_floor(character: Character) -> void:
	var floor_body := StaticBody2D.new()
	var floor_shape := CollisionShape2D.new()
	var floor_rect := RectangleShape2D.new()
	floor_rect.size = Vector2(200, 20)
	floor_shape.shape = floor_rect
	floor_body.add_child(floor_shape)
	floor_body.position = character.position + Vector2(0, 18)
	add_child(auto_free(floor_body))

	# Let physics register the newly added bodies, then settle the character onto the floor.
	await get_tree().physics_frame
	await get_tree().physics_frame
	character.velocity = Vector2(0, 5)
	character.move_and_slide()


func test_jump_command_extends_command(do_skip := not _jump_command_implemented(), skip_reason := NOT_IMPLEMENTED_REASON) -> void:
	assert_object(_new_jump_command()).is_instanceof(Command)


func test_jump_does_nothing_when_not_on_floor(do_skip := not _jump_command_implemented(), skip_reason := NOT_IMPLEMENTED_REASON) -> void:
	var character := _make_character()
	var command := _new_jump_command()

	assert_bool(character.is_on_floor()).is_false()
	var status: Command.Status = command.execute(character)

	assert_float(character.velocity.y).is_equal(0.0)
	assert_str(character.last_callback).is_not_equal("jump")
	assert_that(status).is_equal(Command.Status.DONE)


func test_jump_sets_velocity_and_notifies_callback_when_on_floor(do_skip := not _jump_command_implemented(), skip_reason := NOT_IMPLEMENTED_REASON) -> void:
	var character := _make_character()
	character.jump_velocity = -400.0
	await _settle_onto_floor(character)
	assert_bool(character.is_on_floor()).is_true()

	var command := _new_jump_command()
	var status: Command.Status = command.execute(character)

	assert_float(character.velocity.y).is_equal(character.jump_velocity)
	assert_str(character.last_callback).is_equal("jump")
	assert_that(status).is_equal(Command.Status.DONE)


func test_jump_input_action_exists() -> void:
	assert_bool(InputMap.has_action("jump")).is_true()


func test_jump_input_action_bound_to_space_up_and_w() -> void:
	var bound_keys: Array[Key] = []
	for event in InputMap.action_get_events("jump"):
		if event is InputEventKey:
			bound_keys.append((event as InputEventKey).physical_keycode)

	assert_array(bound_keys).contains(KEY_SPACE, KEY_UP, KEY_W)
