extends GdUnitTestSuite

# Stage 2 test suite: validates FollowerController behavior described in README.md
# ("Stage 2: A Best Friend"):
#   "A FollowerController class that is the brains behind your Follower. Through
#    extend Character, it contains basic functionality for physics and rendering.
#    It should also have the following functionality:
#      - A _ready() function where the follower's movement_speed and jump_velocity
#        are set.
#      - When the Player is within 5 units of the Follower, the follower should
#        initiate a FollowCommand (see below) to stay near the Player.
#      - When the player is higher (i.e., Player has a more negative position.y
#        than the Follower), the Follower should use your JumpCommand to help
#        reach the player."
#
# FollowerController is loaded dynamically by path (never referenced by class_name)
# so this suite still parses and runs before a student creates it; the tests that
# need it are skipped with a clear reason instead of crashing the whole suite.
#
# ASSUMPTION (not specified verbatim by the README, confirmed with the instructor):
# FollowerController exposes a public, settable `player` property (a Character/
# Node2D reference to the Player) and reuses the inherited `up_cmd : Command` slot
# for jumping, mirroring the existing `Boss.target : Character` and
# `Player.up_cmd` conventions already used elsewhere in this codebase. Behavior is
# verified via observable side effects (resulting velocity) rather than internal
# state, so these tests remain valid regardless of exactly how _physics_process
# is structured internally.
#
# is_on_floor() is a native CharacterBody2D getter and cannot be overridden from
# GDScript, so the "on floor" case is tested with a real CollisionShape2D/StaticBody2D
# floor instead of a mock.
const FOLLOWER_CONTROLLER_PATH := "res://scripts/follower.gd"
const NOT_IMPLEMENTED_REASON := "FollowerController not implemented yet (expected at res://scripts/follower.gd)"
const FOLLOW_THRESHOLD := 5.0


static func _follower_implemented() -> bool:
	return ResourceLoader.exists(FOLLOWER_CONTROLLER_PATH)


func _make_follower() -> Character:
	var script := load(FOLLOWER_CONTROLLER_PATH) as GDScript
	var follower := script.new() as Character

	# Character._ready() expects these via @onready; provide stubs to avoid "Node not found" noise.
	var animation_player := AnimationPlayer.new()
	animation_player.name = "AnimationPlayer"
	follower.add_child(animation_player)

	var sprite := Sprite2D.new()
	sprite.name = "Sprite2D"
	follower.add_child(sprite)

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
	follower.add_child(dialogue_box)
	dialogue_box.owner = follower

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(16, 16)
	shape.shape = rect
	follower.add_child(shape)
	add_child(follower)
	return auto_free(follower)


func _make_character_at(pos: Vector2) -> Character:
	var character := Character.new()
	character.name = "Player"
	character.global_position = pos

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

	add_child(character)
	return auto_free(character)


func _settle_onto_floor(character: Character) -> void:
	var floor_body := StaticBody2D.new()
	var floor_shape := CollisionShape2D.new()
	var floor_rect := RectangleShape2D.new()
	floor_rect.size = Vector2(400, 20)
	floor_shape.shape = floor_rect
	floor_body.add_child(floor_shape)
	floor_body.position = character.position + Vector2(0, 18)
	add_child(auto_free(floor_body))

	# Let physics register the newly added bodies, then settle the character onto the floor.
	await get_tree().physics_frame
	await get_tree().physics_frame
	character.velocity = Vector2(0, 5)
	character.move_and_slide()


func test_follower_extends_character(do_skip := not _follower_implemented(), skip_reason := NOT_IMPLEMENTED_REASON) -> void:
	assert_object(_make_follower()).is_instanceof(Character)


func test_follower_ready_sets_movement_speed_and_jump_velocity(do_skip := not _follower_implemented(), skip_reason := NOT_IMPLEMENTED_REASON) -> void:
	var follower := _make_follower()

	# movement_speed/jump_velocity are untyped (int by default, per Character's own
	# field declarations), so use a generic comparison rather than assert_float,
	# which requires an actual float value.
	assert_that(follower.movement_speed).is_not_equal(0)
	assert_that(follower.jump_velocity).is_not_equal(0)


func test_follower_player_reference_is_settable(do_skip := not _follower_implemented(), skip_reason := NOT_IMPLEMENTED_REASON) -> void:
	var follower := _make_follower()
	var player := _make_character_at(Vector2.ZERO)

	follower.player = player

	assert_object(follower.player).is_same(player)


func test_follower_jumps_when_player_is_higher(do_skip := not _follower_implemented(), skip_reason := NOT_IMPLEMENTED_REASON) -> void:
	var follower := _make_follower()
	follower.position = Vector2(100, 40)
	follower.jump_velocity = -400.0
	await _settle_onto_floor(follower)
	assert_bool(follower.is_on_floor()).is_true()

	# Player is above the follower (more negative position.y), but at the same x
	# so the "follow" behavior alone would not need to move the follower.
	follower.player = _make_character_at(follower.global_position + Vector2(0, -100))

	await get_tree().physics_frame
	await get_tree().physics_frame

	# Gravity is applied in the same physics tick after JumpCommand sets the
	# initial velocity, so the exact jump_velocity is frame-dependent. An
	# upward velocity is the observable contract.
	assert_float(follower.velocity.y).is_less(0.0)


func test_follower_moves_toward_player_within_threshold(do_skip := not _follower_implemented(), skip_reason := NOT_IMPLEMENTED_REASON) -> void:
	var follower := _make_follower()
	follower.position = Vector2(100, 40)
	await _settle_onto_floor(follower)
	assert_bool(follower.is_on_floor()).is_true()

	# Player is within the 5-unit threshold and to the right, at the same height.
	follower.player = _make_character_at(follower.global_position + Vector2(FOLLOW_THRESHOLD - 1.0, 0))

	# Observe the first command tick. A second tick can legitimately overshoot a
	# player only four units away and reverse velocity.
	await get_tree().physics_frame

	assert_float(follower.velocity.x).is_greater(0.0)
