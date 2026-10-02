extends GdUnitTestSuite

# Stage 3 integration suite: validates the boss-room cutscene described in README.md
# ("Stage 3: Death by a Thousand Cutscenes") by playing the real Main scene:
#   - The Player, Follower, and Boss each have a cmd_list with their cutscene actions.
#   - The cutscene is between 20 and 30 seconds long and includes all three characters.
#   - The characters are staged in the boss room.
#   - The Player's input is disabled before the cutscene and enabled before the battle.
#   - At least eight unique durative command types are used across the characters.
#   - The characters' commands are synced, and the cutscene launches the boss battle.
#
# HOW IT WORKS: the scenario runs ONCE per suite (cached in _observations) because the
# full cutscene takes 20-30 game seconds. gdUnit4's scene runner speeds up game time
# (timers and physics) by TIME_FACTOR. The Player is teleported into the
# BossEncounterTrigger, then every frame the suite samples observable state: the
# Player's bound input commands, each character's cmd_list, and the camera view.
# Each test case asserts one requirement against those samples.
#
# Cutscene boundaries come from the Player's input bindings, set through
# bind_player_input_commands()/unbind_player_input_commands() in player.gd:
#   start = input unbound after entering the trigger; end (handoff) = input bound again.
#
# ASSUMPTIONS (not specified verbatim by the README):
#   - "Input bound" means right_cmd/left_cmd/fire1 are MoveRight/MoveLeft/AttackCommand,
#     as set by bind_player_input_commands(). "Unbound" means none of them is, and
#     up_cmd is not a JumpCommand.
#   - The boss battle is launched when the cutscene ends (as outlined by
#     CutsceneManager.end_cutscene()), so new commands are queued on the Boss's cmd_list
#     within BATTLE_START_WINDOW seconds of the handoff. Commands queued during the
#     cutscene are cutscene commands and must be finished within HANDOFF_TOLERANCE.
#   - Characters are "in the boss room" when they are inside the camera's visible area.
#   - The Follower may use its cmd_list for normal (non-cutscene) behavior, so only the
#     Player and Boss are checked for commands queued before input is disabled.
#   - Durations are measured in sampled game time, so they are accurate to about a frame.
#
# The suite skips until Stage 3 has started (player.gd declares a cmd_list), matching
# the skip pattern of the Stage 1 and 2 suites.
const MAIN_SCENE := "res://main.tscn"
const PLAYER_SCRIPT_PATH := "res://scripts/player.gd"
const NOT_STARTED_REASON := "Stage 3 not started yet (expected a cmd_list member in res://scripts/player.gd)"

const MIN_CUTSCENE_SECONDS := 20.0
const MAX_CUTSCENE_SECONDS := 30.0
const MIN_UNIQUE_DURATIVE_TYPES := 8

# gdUnit4 caps the time factor at 9; 5 keeps the physics steps per frame manageable.
const TIME_FACTOR := 5.0
const SETTLE_SECONDS := 0.5
const CUTSCENE_START_TIMEOUT := 2.0
const HANDOFF_TOLERANCE := 1.0
const BATTLE_START_WINDOW := 2.0
const OBSERVATION_LIMIT := MAX_CUTSCENE_SECONDS + 10.0

const CHARACTERS: Array[String] = ["Player", "Follower", "Boss"]
const INPUT_GATED_CHARACTERS: Array[String] = ["Player", "Boss"]

enum InputState { BOUND, UNBOUND, PARTIAL }

var _observations: Dictionary = {}


static func _stage3_started() -> bool:
	var script := load(PLAYER_SCRIPT_PATH) as GDScript
	if script == null:
		return false
	for property in script.get_script_property_list():
		if property["name"] == "cmd_list":
			return true
	return false


# --- Test cases -------------------------------------------------------------------

func test_cutscene_starts_when_player_enters_boss_room(do_skip := not _stage3_started(), skip_reason := NOT_STARTED_REASON) -> void:
	var obs := await _observe()

	assert_bool(obs["input_bound_before_encounter"]) \
		.override_failure_message("Player input should be bound during normal play, before the boss room is entered.") \
		.is_true()
	assert_bool(obs["cutscene_started"]) \
		.override_failure_message("Entering the BossEncounterTrigger should disable the Player's input (unbind_player_input_commands()) within %.1f s to start the cutscene." % CUTSCENE_START_TIMEOUT) \
		.is_true()


func test_each_character_has_a_cmd_list(do_skip := not _stage3_started(), skip_reason := NOT_STARTED_REASON) -> void:
	var obs := await _observe()

	for character_name in CHARACTERS:
		assert_bool(obs["characters"][character_name]["has_cmd_list"]) \
			.override_failure_message("%s should have a cmd_list (Array[Command]) for its cutscene actions." % character_name) \
			.is_true()


func test_player_input_disabled_before_and_during_cutscene(do_skip := not _stage3_started(), skip_reason := NOT_STARTED_REASON) -> void:
	var obs := await _observe()

	assert_bool(obs["cutscene_started"]).override_failure_message("The cutscene never started.").is_true()
	assert_array(obs["commands_queued_while_input_bound"]) \
		.override_failure_message("The Player's input must be disabled before the cutscene starts, but these characters had commands queued while input was still bound: %s" % [obs["commands_queued_while_input_bound"]]) \
		.is_empty()
	assert_bool(obs["input_partially_bound_during_cutscene"]) \
		.override_failure_message("Player input should stay fully disabled for the whole cutscene (found a partially bound input state).") \
		.is_false()


func test_cutscene_lasts_between_20_and_30_seconds(do_skip := not _stage3_started(), skip_reason := NOT_STARTED_REASON) -> void:
	var obs := await _observe()

	assert_bool(obs["cutscene_ended"]) \
		.override_failure_message("The cutscene never ended: Player input was not re-enabled (bind_player_input_commands()) within %.0f s." % OBSERVATION_LIMIT) \
		.is_true()
	assert_float(obs["cutscene_seconds"]) \
		.override_failure_message("The cutscene should last between %.0f and %.0f seconds, but lasted %.2f s." % [MIN_CUTSCENE_SECONDS, MAX_CUTSCENE_SECONDS, obs["cutscene_seconds"]]) \
		.is_between(MIN_CUTSCENE_SECONDS, MAX_CUTSCENE_SECONDS)


func test_all_three_characters_act_in_cutscene(do_skip := not _stage3_started(), skip_reason := NOT_STARTED_REASON) -> void:
	var obs := await _observe()

	for character_name in CHARACTERS:
		assert_int(obs["characters"][character_name]["cutscene_command_count"]) \
			.override_failure_message("%s should have at least one command in its cmd_list during the cutscene." % character_name) \
			.is_greater(0)


func test_cutscene_uses_at_least_eight_unique_durative_commands(do_skip := not _stage3_started(), skip_reason := NOT_STARTED_REASON) -> void:
	var obs := await _observe()
	var types: Array = obs["durative_command_types"]

	assert_int(types.size()) \
		.override_failure_message("The cutscene should use at least %d unique DurativeAnimationCommand types across the characters, but used %d: %s" % [MIN_UNIQUE_DURATIVE_TYPES, types.size(), types]) \
		.is_greater_equal(MIN_UNIQUE_DURATIVE_TYPES)


func test_characters_are_staged_in_boss_room(do_skip := not _stage3_started(), skip_reason := NOT_STARTED_REASON) -> void:
	var obs := await _observe()

	for character_name in CHARACTERS:
		assert_bool(obs["characters"][character_name]["seen_on_camera"]) \
			.override_failure_message("%s should be staged in the boss room (inside the camera view) during the cutscene." % character_name) \
			.is_true()


func test_cutscene_commands_finish_together_at_handoff(do_skip := not _stage3_started(), skip_reason := NOT_STARTED_REASON) -> void:
	var obs := await _observe()

	assert_bool(obs["cutscene_ended"]).override_failure_message("The cutscene never ended.").is_true()
	for character_name in CHARACTERS:
		var pending: int = obs["characters"][character_name]["pending_after_handoff"]
		assert_int(pending) \
			.override_failure_message("%s still had %d cutscene command(s) queued %.1f s after the Player regained control; the characters' cutscene commands should be synced to finish together." % [character_name, pending, HANDOFF_TOLERANCE]) \
			.is_equal(0)


func test_player_input_restored_after_cutscene(do_skip := not _stage3_started(), skip_reason := NOT_STARTED_REASON) -> void:
	var obs := await _observe()

	assert_bool(obs["cutscene_ended"]) \
		.override_failure_message("Player input should be re-enabled (bind_player_input_commands()) when the cutscene ends.") \
		.is_true()
	assert_bool(obs["input_stayed_bound_after_handoff"]) \
		.override_failure_message("Player input should stay enabled for the boss battle after the cutscene ends.") \
		.is_true()


func test_boss_battle_starts_after_cutscene(do_skip := not _stage3_started(), skip_reason := NOT_STARTED_REASON) -> void:
	var obs := await _observe()

	assert_bool(obs["cutscene_ended"]).override_failure_message("The cutscene never ended.").is_true()
	assert_bool(obs["boss_battle_started"]) \
		.override_failure_message("The cutscene should launch the boss battle: new commands should be queued on the Boss's cmd_list within %.1f s after the Player regains control." % BATTLE_START_WINDOW) \
		.is_true()


# --- Scenario ---------------------------------------------------------------------

func _observe() -> Dictionary:
	if not _observations.is_empty():
		return _observations

	var obs := {
		"input_bound_before_encounter": false,
		"cutscene_started": false,
		"cutscene_ended": false,
		"cutscene_seconds": 0.0,
		"commands_queued_while_input_bound": [],
		"input_partially_bound_during_cutscene": false,
		"input_stayed_bound_after_handoff": false,
		"boss_battle_started": false,
		"durative_command_types": [],
		"characters": {},
	}

	var runner := scene_runner(MAIN_SCENE)
	runner.set_time_factor(TIME_FACTOR)
	var main := runner.scene()
	# Student code may reach the CutsceneManager through current_scene, which the runner does not set.
	var previous_current_scene := get_tree().current_scene
	get_tree().current_scene = main

	var characters := {}
	for character_name in CHARACTERS:
		var node := main.get_node("%" + character_name) as Node2D
		characters[character_name] = node
		obs["characters"][character_name] = {
			"has_cmd_list": "cmd_list" in node,
			"cutscene_command_count": 0,
			"seen_on_camera": false,
			"pending_after_handoff": -1,
		}
	var player: Node2D = characters["Player"]
	var boss: Node2D = characters["Boss"]
	var camera := main.get_node("%MainCamera") as Camera2D

	await _advance(SETTLE_SECONDS)
	obs["input_bound_before_encounter"] = _input_state(player) == InputState.BOUND

	_enter_boss_room(main, player)

	# Command instances seen in each cmd_list during the cutscene, keyed by instance id.
	var cutscene_commands := {}
	for character_name in CHARACTERS:
		cutscene_commands[character_name] = {}
	var queued_while_bound := {}
	var durative_types := {}

	var elapsed := 0.0
	var cutscene_start := -1.0
	var handoff := -1.0
	var pending_checked := false
	var boss_battle_started := false
	var input_stayed_bound := true

	while elapsed < OBSERVATION_LIMIT:
		await get_tree().process_frame
		elapsed += get_process_delta_time()
		var input_state := _input_state(player)

		if cutscene_start < 0.0:
			if input_state == InputState.UNBOUND:
				cutscene_start = elapsed
			else:
				for character_name in INPUT_GATED_CHARACTERS:
					if not _cmd_list(characters[character_name]).is_empty():
						queued_while_bound[character_name] = true
				if elapsed > CUTSCENE_START_TIMEOUT:
					break
				continue

		if handoff < 0.0:
			if input_state == InputState.BOUND:
				handoff = elapsed
			else:
				if input_state == InputState.PARTIAL:
					obs["input_partially_bound_during_cutscene"] = true
				for character_name in CHARACTERS:
					var node: Node2D = characters[character_name]
					for command in _cmd_list(node):
						cutscene_commands[character_name][command.get_instance_id()] = true
						if command is DurativeAnimationCommand:
							durative_types[_command_type_name(command)] = true
					if _is_on_camera(camera, node):
						obs["characters"][character_name]["seen_on_camera"] = true
				continue

		var since_handoff := elapsed - handoff
		if input_state != InputState.BOUND:
			input_stayed_bound = false
		if not boss_battle_started:
			for command in _cmd_list(boss):
				if not cutscene_commands["Boss"].has(command.get_instance_id()):
					boss_battle_started = true
		if not pending_checked and since_handoff >= HANDOFF_TOLERANCE:
			pending_checked = true
			for character_name in CHARACTERS:
				var pending := 0
				for command in _cmd_list(characters[character_name]):
					if cutscene_commands[character_name].has(command.get_instance_id()):
						pending += 1
				obs["characters"][character_name]["pending_after_handoff"] = pending
		if pending_checked and since_handoff >= BATTLE_START_WINDOW:
			break

	obs["cutscene_started"] = cutscene_start >= 0.0
	obs["cutscene_ended"] = handoff >= 0.0
	if handoff >= 0.0:
		obs["cutscene_seconds"] = handoff - cutscene_start
		obs["input_stayed_bound_after_handoff"] = input_stayed_bound
		obs["boss_battle_started"] = boss_battle_started
	obs["commands_queued_while_input_bound"] = queued_while_bound.keys()
	var types := durative_types.keys()
	types.sort()
	obs["durative_command_types"] = types
	for character_name in CHARACTERS:
		obs["characters"][character_name]["cutscene_command_count"] = cutscene_commands[character_name].size()

	get_tree().current_scene = previous_current_scene
	_observations = obs
	return _observations


func _advance(seconds: float) -> void:
	var elapsed := 0.0
	while elapsed < seconds:
		await get_tree().process_frame
		elapsed += get_process_delta_time()


func _enter_boss_room(main: Node, player: Node2D) -> void:
	var trigger_shape := main.get_node("BossEncounterTrigger/CollisionShape2D") as CollisionShape2D
	player.global_position = trigger_shape.global_position
	(player as CharacterBody2D).velocity = Vector2.ZERO


# --- Helpers ----------------------------------------------------------------------

func _input_state(player: Node) -> InputState:
	var bound := [
		player.right_cmd is MoveRightCommand,
		player.left_cmd is MoveLeftCommand,
		player.fire1 is AttackCommand,
	]
	if not bound.has(false):
		return InputState.BOUND
	if not bound.has(true) and not _is_command_class(player.up_cmd, "JumpCommand"):
		return InputState.UNBOUND
	return InputState.PARTIAL


func _cmd_list(node: Node) -> Array:
	if "cmd_list" in node and node.cmd_list is Array:
		return node.cmd_list
	return []


func _is_on_camera(camera: Camera2D, node: Node2D) -> bool:
	var view_size := Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")) / camera.zoom
	var view := Rect2(camera.get_screen_center_position() - view_size / 2.0, view_size)
	return view.has_point(node.global_position)


func _command_type_name(command: Object) -> String:
	var script := command.get_script() as Script
	if script == null:
		return command.get_class()
	if not script.get_global_name().is_empty():
		return script.get_global_name()
	return script.resource_path.get_file()


func _is_command_class(command: Object, global_name: String) -> bool:
	if command == null:
		return false
	var script := command.get_script() as Script
	while script != null:
		if script.get_global_name() == global_name:
			return true
		script = script.get_base_script()
	return false
