class_name DurativeJumpCommand
extends DurativeAnimationCommand

var _jump_started:bool = false
var _was_above_floor:bool = false
var _x_velocity:float

func _init(x_velocity = 0):
	_x_velocity = x_velocity


func execute(character:Character) -> Status:
	if character.is_on_floor() && !_jump_started:
		character.velocity.y = character.jump_velocity
		character.velocity.x = _x_velocity
		_jump_started = true
		character.animation_player.play("jump")
		character.command_callback("jump")
	elif !character.is_on_floor():
		_was_above_floor = true
	elif character.is_on_floor() && _was_above_floor:
		character.animation_player.play("idle")
		character.velocity.x = 0
		return Status.DONE
	
	return Status.ACTIVE
