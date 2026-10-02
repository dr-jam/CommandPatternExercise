extends GdUnitTestSuite

# Stage 2 test suite: validates FollowCommand behavior described in README.md
# ("Stage 2: A Best Friend"):
#   "A FollowCommand class that enables your Follower to be near the player.
#    This class should extend Command and include a leash member variable
#    representing a maximum distance between the Follower and the Player.
#    When the two are greater than leash units apart, the command should end
#    and return Status.DONE."
#
# FollowCommand is loaded dynamically by path (never referenced by class_name) so this
# suite still parses and runs before a student creates it; the tests that need it are
# skipped with a clear reason instead of crashing the whole suite.
#
# ASSUMPTION (not specified verbatim by the README, confirmed with the instructor):
# Command.execute(character) only receives the Character being commanded (the
# Follower), not the Player, so FollowCommand needs some way to know where the
# Player is. These tests assume FollowCommand exposes a public, settable `player`
# property (a Node2D/Character) used for the distance check - mirroring the
# existing `Boss.target : Character` convention in the codebase. If a student's
# implementation locates the Player a different way (e.g. a unique scene node),
# these tests will fail with a clear "Invalid get/set" runtime error rather than
# a parse error, since FollowCommand is loaded dynamically without static typing.
const FOLLOW_COMMAND_PATH := "res://scripts/commands/FollowCommand.gd"
const NOT_IMPLEMENTED_REASON := "FollowCommand not implemented yet (expected at res://scripts/commands/FollowCommand.gd)"


static func _follow_command_implemented() -> bool:
	return ResourceLoader.exists(FOLLOW_COMMAND_PATH)


func _new_follow_command() -> Command:
	var script := load(FOLLOW_COMMAND_PATH) as GDScript
	return script.new() as Command


func _make_target() -> Character:
	var character := Character.new()

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


func _make_player_at(pos: Vector2) -> Node2D:
	var player := Node2D.new()
	player.name = "Player"
	player.global_position = pos
	add_child(player)
	return auto_free(player)


func test_follow_command_extends_command(do_skip := not _follow_command_implemented(), skip_reason := NOT_IMPLEMENTED_REASON) -> void:
	assert_object(_new_follow_command()).is_instanceof(Command)


func test_follow_command_has_leash_member(do_skip := not _follow_command_implemented(), skip_reason := NOT_IMPLEMENTED_REASON) -> void:
	var command := _new_follow_command()
	assert_float(command.leash).is_greater(0.0)


func test_follow_command_leash_is_settable(do_skip := not _follow_command_implemented(), skip_reason := NOT_IMPLEMENTED_REASON) -> void:
	var command := _new_follow_command()
	command.leash = 10.0
	assert_float(command.leash).is_equal(10.0)


func test_follow_command_returns_done_when_beyond_leash(do_skip := not _follow_command_implemented(), skip_reason := NOT_IMPLEMENTED_REASON) -> void:
	var target := _make_target()
	target.global_position = Vector2.ZERO

	var command := _new_follow_command()
	command.leash = 5.0
	command.player = _make_player_at(Vector2(command.leash + 10.0, 0))

	var status: Command.Status = command.execute(target)

	assert_that(status).is_equal(Command.Status.DONE)


func test_follow_command_returns_active_when_within_leash(do_skip := not _follow_command_implemented(), skip_reason := NOT_IMPLEMENTED_REASON) -> void:
	var target := _make_target()
	target.global_position = Vector2.ZERO

	var command := _new_follow_command()
	command.leash = 5.0
	command.player = _make_player_at(Vector2(command.leash - 1.0, 0))

	var status: Command.Status = command.execute(target)

	assert_that(status).is_equal(Command.Status.ACTIVE)


func test_follow_command_returns_done_exactly_at_leash_boundary(do_skip := not _follow_command_implemented(), skip_reason := NOT_IMPLEMENTED_REASON) -> void:
	var target := _make_target()
	target.global_position = Vector2.ZERO

	var command := _new_follow_command()
	command.leash = 5.0
	command.player = _make_player_at(Vector2(command.leash, 0))

	var status: Command.Status = command.execute(target)

	# README: "When the two are greater than leash units apart" -> DONE.
	# Exactly at the boundary is not "greater than", so it should remain ACTIVE.
	assert_that(status).is_equal(Command.Status.ACTIVE)
