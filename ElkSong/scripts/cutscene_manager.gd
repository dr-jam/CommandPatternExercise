class_name CutsceneManager
extends Node

@onready var _player:= %Player
#comment these in when you're ready to use them
#@onready var _follower:= %Follower
#@onready var _boss:= %Boss

var moveLeft := MoveLeftCommand.new()

func start_cutscene() -> void:
	#Bind the cutscene commands so the user cannnot move the player. 
	_player.unbind_player_input_commands()
	#Move the characters to the correct position
	#Fill the cmd_lists of the three Characters and author the cutscene
	

func end_cutscene() -> void:
	#Bind the player commands so the user can control the player character again.
	_player.bind_player_input_commands()
	#restore normal control to the Follower
	#initiate the boss battle
