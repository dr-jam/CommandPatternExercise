class_name BossEncounterTrigger
extends Area2D

@export var camera_location:Node2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(_body:Player) -> void:
	#position the camer for the boss fight
	%MainCamera.subject = camera_location
	
	_body.command_callback("engage")

	#make the boss's body visible
	%Boss.sprite.visible = true

	#This is a good place for entering your Stage 3 cutscene. 
	#Your cutscene should then launch the boss battle.

	#A simple boss fight that does not loop. 
	#This would be considered an incorrect implementation for Stage 4.	
	
	%Boss.cmd_list.push_back(SummonCommand.new())
	%Boss.cmd_list.push_back(DurativeIdleCommand.new(1))
	%Boss.cmd_list.push_back(DurativeJumpCommand.new(-300))
	%Boss.cmd_list.push_back(DurativeJumpCommand.new(200))
	%Boss.cmd_list.push_back(DurativeJumpCommand.new(-200))
	%Boss.cmd_list.push_back(DurativeAttackCommand.new())
	%Boss.cmd_list.push_back(DurativeJumpCommand.new())
	%Boss.cmd_list.push_back(DurativeAttackCommand.new())
	%Boss.cmd_list.push_back(DurativeMoveLeftCommand.new(0.66))
	%Boss.cmd_list.push_back(DurativeMoveRightCommand.new(0.66))
	%Boss.cmd_list.push_back(DurativeMoveLeftCommand.new(0.66))
	%Boss.cmd_list.push_back(DurativeMoveRightCommand.new(0.66))
	%Boss.cmd_list.push_back(DurativeAttackCommand.new())
	%Boss.cmd_list.push_back(DurativeMoveLeftCommand.new(0.66))
	%Boss.cmd_list.push_back(DurativeMoveRightCommand.new(0.66))
	%Boss.cmd_list.push_back(DurativeMoveLeftCommand.new(0.66))
	%Boss.cmd_list.push_back(DurativeMoveRightCommand.new(0.66))
	%Boss.cmd_list.push_back(DurativeAttackCommand.new())
	%Boss.cmd_list.push_back(DurativeDialogueCommand.new("Boss: rut ruuuttt RRRRRRUUUUUUUUUTTTTT!", 2.0))
	
	#remove this trigger node
	queue_free()
