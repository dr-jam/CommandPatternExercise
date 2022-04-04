# Programming Excercise 1: Command Pattern

## Description

The goals behind this project are 1) to allow for meaningful gameplay programming inside a Unity project, and 2) 
to provide working experience with the command software design pattern. This project is filled with examples of using Unity 
to construct basic game systems including item collection, scorekeeping, player movement, simple non-player character behavior,
parallax scrolling, character transportation, camera that follows the player, animated sprites, user interface elements, 
and input commands using the game pattern.

Your project will be score according to the following 70 point system:
* [10 points] Stage 1 
* [30 points] Stage 2
* [15 points] Stage 3
* [15 points] Stage 4

The remaining 30 points will be based on your peer review of a classmate's programming exercise submission.

### Due Date and Submission Instructions

Due date: See Canvas.   
Your work will be submitted individually via GitHub Classroom (starting links to be distributed in Canvas). The Unity project in your the master origin branch or your repository as assigned on GitHub Classroom will be graded. Other branches will be ignored. 

## Stage 1: Both legs.
Create a right movement `ICaptainCommand` and use it in the `CaptainController.cs` script.  
Right based on right axis movement. Be sure to `MoveCharacterLeft.cs` as a reference and use the following property of the  `SpriteRenderer` compotnent to make sure the Captain is facing the correct direction when moving:  
`gameObject.GetComponent<SpriteRenderer>().flipX`

## Stage 2: Heave ho!
Create the following IPirateCommands to be used with Cutlass, Pegleg, and Scurvybeard:
* `SlowWorkerPirateCommand.cs`: works for a 20-40 second duration and produces 1 item every 8 seconds. This should be the default command for all Pirates other than the Captain.
* `NormalWorkerPirateCommand.cs`: works for 10-20 seconds and produces an item every 4 seconds
* `FastWorkerPirateCommand.cs`: works for 5-10 seconds and an item every 2 seconds.

Track time with float type variables. `Time.deltaTime` will provide the time since the last call to the Update function 
for `GameObjects`.

If a pirate is effective working (i.e. their work duration has not expired), the `IPirateCommand` returns true. All 
workers are exhausted after their work duration and the IPirateCommand will return false until they have regained 
motivation from Captain.

When an item is produced, a new `GameObject` should be instantiated based on the 2nd argument of the `Execute` function.

## Stage 3: Motivation will continue until work improves.

Change the `Motivate` function in the `PirateController.cs` class so that every time the function is called, it pseudo-randomly assigns a new instance of one of the three work style to the controlled Pirate. You should create a new instance of the `IPirateCommand` with the following code:  
`Object.Instantiate(ScriptableObject.CreateInstance<SlowWorkPirateCommand>());`

Because `ScriptableObjects` have implicit data sharing, you need to use `Object.Instantiate` to create a completely new instance of the `IPirateCommand`.

## Stage 4: 

Make your own `ICaptainCommand` bound to the Captain's "Fire2" input that interacts with the game mechanics in some interesting way. This is your opportunity to perform self-directed, design-driven, gameplay programming. You can implement something as simple as a jumping mechanic or something as elaborate as a resource-driven morale system. Be sure to describe your new `ICaptainCommand` before your class declaration with a paragraph of text. This description is for your peer-reviewer so make it clear and communicative. 
