# Programming Excercise 1: Command Pattern

## Competency Claims
(insert your competency claims here)  
## Description

The goals behind this project are 1) to allow for meaningful gameplay gameplay programming inside a Godot project, and 2) 
to provide working experience with the command software design pattern. This project is filled with examples of using Unity 
to construct basic game systems including health, hit/hurt boxes, player movement, non-player character behavior,
parallax scrolling, character movement, a camera that follows the player, animated sprites, boss fights, 
and commands using the Command software design pattern.


### The Command Pattern ###
	
Knowing the command software design pattern is critical to completing this assignment. Please consult the class recordings and readings to refresh yourself on the basic implementation details and use case for the pattern.  

For this project, the core of the command pattern can be found in [command.gd](ElkSong/scripts/commands/command.gd). The two most important items to note are the structure of the `execute(character:Character) -> Status` function and the `enum Status`. The `execute()` function is the common interface that all commands in the project rely on. The return values of the commands are regularized with the `ACTIVE`, `DONE`, and `ERROR` values with the `Status` `enum`. 

```gdscript
class_name Command

enum Status {
	ACTIVE,
	DONE,
	ERROR,
}

func execute(_character: Character) -> Status:
	return Status.DONE
```

There are two main categories of `Commands` used by the Characters. One is used by `Player` to handle the player's input in real time. It relies on the physics system, the `AnimationTree` in the `Player` scene, and a state machine embedded in the `AnimationTree.`  
The second category is commands with durations. NPCs use these to ensure character actions are correctly timed. They are also used in command lists (seen as `cmd_list` in [boss.gd](ElkSong/scripts/boss.gd) to sequence actions for use in cutscenes and scripted boss battles. The following code fragment shows the processing engine of command lists and how they interact with `Command.Status` `enum` values.  

```gdscript
	if len(cmd_list)>0:
		var command_status:Command.Status = cmd_list.front().execute(self)
		#if command_status == Command.Status.ACTIVE:
			#Useful for debugging and sending status updates to other nodes.
		if Command.Status.DONE == command_status:
			cmd_list.pop_front()
	else:
		animation_player.play("idle")
```

## Stage 1: Jump to it
Create a `JumpCommand` class that extends the `Command` class. This command should properly check to see if the `Player` `is_on_floor()` before initiating the jump. You need to provide an appropriate jump velocity that is consistent with the `Player` class so that the `Player` can jump over the obstacle in the level. Additionally, you are required to create a "jump" action in the project's `Input Map` that triggers when the `space`, `up`, or `W` is pressed.  
Note: to make sure the jump sound effects are linked, include `character.command_callback("jump")` when you initiate the jump.  
Note: Look for comments like `#stage1` to see key code areas.  

## Stage 2: A Best Friend  
In this stage, you will create a controller and commands for the follower. 
- A `FollowerController` class that is the brains behind your `Follower`. Through `extend Character`, it contains basic functionality for physics and rendering. It should also have the following functionality:
  - A `_physics_process()` function where the basic logic of the controller is implemented. Be sure to call `super(delta)` to call the movement and rendering code implemented in `character.gd`'s `Character` class.
  - A `_ready()` function where the follower's `movement_speed` and `jump_velocity` are set.
  - When the `Player` is within 5 units of the `Follower`, the follower should initiate a `FollowCommand` (see below) to stay near the `Player`.
  - When the player is higher (i.e., `Player` has a more negative `position.y` than the `Follower`), the `Follower` should use your `JumpCommand` to help reach the player.
- A `FollowCommand` class that enables your `Follower` to be near the player. This class should `extend Command` and include a `leash` member variable representing a maximum distance between the `Follower` and the `Player`. When the two are greater than `leash` units apart, the command should end and `return Status.DONE`.

You may wish to look at `boss.gd` for inspiration. Here is an outline to help you get started:  
```gdscript
class_name FollowerController
extends Character 

#useful data structure for sequentially enacting commands
var cmd_list : Array[Command]

#A reference to the Player
@onready var player:Player = %Player

func _ready():
	#set movement and jump velocities

func _physics_process(delta: float) -> void:
	#controller logic
	super(delta)
```

## Stage 3: Death by a Thousand Cutscenes
This game prototype needs some narrative design. Your task is to create a cutscene just before the boss battle to tell the current story to the player. This cutscene should be between 20 and 30 seconds long and include each of the three characters. 
- Stage the characters in positions in the boss room. It is fine to teleport them to where they need to be.
- The `Player`, `Follower`, and `Boss` should each have `cmd_list` that contains their actions during the cutscene. Please be aware that actions taken by cutscene-controlled characters need to have a duration (most of the `Player`s commands did not have to account for duration). Please consult the classes that `extend DurativeAnimationCommand` to see how to create and use commands with durations.
- Be sure to disable the `Player`'s input before the cutscene starts and enable it before the boss battle. See `bind_player_input_commands()` and `unbind_player_input_commands()` in the `player.gd`.

For examples of how the command lists work, see the paired `BossEncounterTrigger` (in [boss_encounter_trigger.gd](ElkSong/scripts/boss_encounter_trigger.gd)) and `Boss` classes. The `BossEncounterTrigger` is attached to the `Area2D` trigger named `BossEncounterTrigger` in the `Main` scene. It is responsible for detecting when the `Player` is in the `Boss`s room and configuring the user interface for the boss encounter (e.g., the cutscene followed by the boss battle).

Your work will be assessed on the following criteria:
- The number of unique durative commands across the characters. Less than eight types may result in a point deduction.
- How well synced the three characters' commands are to one another.
- Are the transitions to the cutscene and from the cutscene to the boss battle technically sound.
- **Bonus**: Telling an interesting tale.

To help coordinate these commands, you may wish to use the [cutscene_manager.gd](ElkSong/scripts/cutscene_manager.gd) as a central control mechanism.

## Stage 4: Boss Mechanics

Make your own boss battle. This is your opportunity to perform self-directed, design-driven gameplay programming. You can implement something as simple as a boss that moves, jumps, and attacks. Or you could make something as elaborate as special moves, life regeneration, damage-absorbing shields made of bone, or a dialogue system to negotiate with the spirit to solve the conflict without violence. Be sure that your boss battle logic uses command lists, is winnable by the player, and follows one of the most essential rules for NPCs: it should always be doing something! Describe your boss battle in a comment near your implementation. This description is for your peer reviewer, so make it clear and communicative.

- The boss should always be acting.
- The boss should be competent. This could mean dynamic targeting or some additional scripted and threatening behavior.
- Visual and auditory effects. 

Good luck!


## Competency Assessment

This exercise uses the course competency system instead of points. Completing the required stages gives you a default set of competencies. You may also make up to three additional claims at the Developed or Mastery level.

### Default Competencies

| Stage | Competencies |
|---|---|
| **Stage 1: Jump to It** | **Engine Usage — Unlocked**; **Design Patterns — Unlocked** |
| **Stage 2: A Best Friend** | **Game Systems — Unlocked**; |
| **Stage 3: Death by a Thousand Cutscenes** | **Interaction Design — Unlocked** |
| **Stage 4: Boss Mechanics** | **Game Systems — Developed**; **Interaction Loops — Unlocked** |

These levels assume the stage works as required, the relevant tests pass, and the requested architecture is actually used.

### Additional Claims

You may claim up to three additional competencie at Developed or Mastery. Point to specific files, tests, commits, or features. Say what you changed, why it matters, and how it goes beyond the default stage requirements. For each claim, add:

```text
Competency:
Level: Developed or Mastery
Evidence:
Explanation:
```

Add your claims to [the Competency Claims section](#competency-claims) near the top if this document.  

### Developed

A Developed claim should show that you can use the competency in a changed or less-guided situation:
- make a meaningful implementation or design decision
- go beyond the supplied example or required minimum
- verify that the result works
- deal with at least one nontrivial case
- explain why you chose your approach

### Mastery

A Mastery claim should show independent technical judgment:
- identify a real problem or limitation yourself
- design and implement your own solution
- discuss the merits and drawbacks of alternative approaches
- test normal and failure cases
- explain the tradeoffs of your approach

More code does not automatically mean Mastery.

### Likely Competencies for This Exercise

**Design Patterns: Developed**  
Adapt the Command pattern to a new gameplay problem. Do not just add another command that follows the same template.

**Design Patterns: Mastery**  
Change or extend the command architecture in a substantial way and explain why your version is a better fit for the problem you are solving.

**Debugging and Testing: Developed**  
Add tests or diagnostics beyond the supplied checks. Good evidence would catch a lifecycle bug, queue problem, invalid target, interruption, or similar failure.

**Debugging and Testing: Mastery**  
Build a testing or diagnostic setup that lets you reason about the command system as a whole, not just one feature at a time.

**Engine Usage: Developed**  
Use Godot systems deliberately to solve a new problem. Signals, input handling, node lifecycle, scene structure, animation, and physics are all reasonable places to look.

**Engine Usage: Mastery**  
Make a larger architectural decision about how Godot should manage ownership, lifecycle, communication, or reuse, and justify it from the behavior of your project.

**Game Systems: Developed**  
Add or substantially revise rules, state, or behavior so that the game plays differently as a result.

**Game Systems: Mastery**  
Build a system with enough interacting rules that changing one part has consequences elsewhere (i.e., attack selection, state, player response, and feedback meaningfully interact), then explain those consequences. It should feel like a legitimate boss battle in a platformer.

**System Interrelations: Developed**  
Show that commands, player control, follower behavior, cutscenes, and boss logic cooperate correctly at their boundaries.

**System Interrelations: Mastery**  
Restructure or extend those interactions without making the responsibilities muddy. Interruptions, invalid state, or recovery behavior are especially good evidence.

**Interaction Design: Developed**  
Improve timing, controls, feedback, staging, or responsiveness in a way the player can notice.

**Interaction Design: Mastery**  
Make a substantial interaction change, observe what it does in play, and revise it based on what you find.

**Interaction Loops: Developed**  
Create or substantially change a repeated cycle of player action and game response.

**Interaction Loops: Mastery**  
Build a boss interaction with enough state and feedback that the player has to read the system and respond, not just survive another attack.

### Tests and Competency Levels

Passing the supplied tests shows that the required behavior works. Higher-level claims should come from work you added: adaptations, tests, diagnostics, design decisions, or extensions that go beyond the guided path.
