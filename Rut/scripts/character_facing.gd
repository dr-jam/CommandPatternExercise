extends Node2D

@export var unflipped_position:Vector2
@export var flipped_position:Vector2


func _on_character_body_2d_character_direction_change(facing: Character.Facing) -> void:
	if Character.Facing.LEFT == facing:
		position = flipped_position
	elif Character.Facing.RIGHT == facing:
		position = unflipped_position
