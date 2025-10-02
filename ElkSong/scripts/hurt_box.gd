class_name HurtBox
extends Area2D

var damage:int

func _init() -> void:
	collision_layer = 8
	collision_mask = 0
