class_name HitBox
extends Area2D

@export var damage:int = 10

func _init() -> void:
	collision_layer = 0
	collision_mask = 8
	area_entered.connect(_on_area_entered)


func _on_area_entered(hurtbox:HurtBox) -> void:
	if hurtbox.get_owner().has_method("take_damage"):
		hurtbox.owner.take_damage(damage)
