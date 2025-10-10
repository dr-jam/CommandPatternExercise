class_name DurativeMoveLeftCommand
extends DurativeAnimationCommand

var _duration:float

func _init(duration:float):
	_duration = duration
	
	
func execute(character:Character) -> Status:
	character.velocity.x = -1 * character.movement_speed
	character.change_facing(Character.Facing.LEFT)
	var status:Command.Status = _manage_durative_animation_command(character, "move", _duration)
	if status == Status.DONE:
		character.velocity.x = 0
	return status
