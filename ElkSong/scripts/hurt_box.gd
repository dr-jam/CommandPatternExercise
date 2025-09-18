class_name HurtBox
extends Area2D

var damage:int

func _init() -> void:
	collision_layer = 8
	collision_mask = 0
	area_entered.connect(_on_area_entered)
	
func _on_area_entered(hitbox:HitBox) -> void:
	if owner.has_method("take_damage"):
		owner.take_damage(damage)
