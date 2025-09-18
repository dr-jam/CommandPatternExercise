extends Node2D

@onready var player:Player = owner as Player

func _ready() -> void:
	pass # Replace with function body.


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("cheat1"):
		player.resurrect()
	if Input.is_action_just_pressed("cheat2"):
		player.global_position += Vector2(200,-100)
