class_name CameraController
extends Camera2D

@export var floating_offset:Vector2 = Vector2.ZERO

@export var subject:Node2D :
	set(value):
		subject = value
		global_position = subject.global_position + floating_offset

func _ready() -> void:
	global_position = subject.global_position + floating_offset


func _process(_delta: float) -> void:
	global_position.x = subject.global_position.x + floating_offset.x
