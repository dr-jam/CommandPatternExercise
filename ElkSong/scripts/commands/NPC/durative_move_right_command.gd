class_name DurativeMoveRightCommand
extends DurativeAnimationCommand

var _duration:float

func _init(duration:float):
	_duration = duration


func execute(character:Character) -> Status:
	character.velocity.x = character.movement_speed
	var status:Command.Status = _manage_durative_animation_command(character, "move", _duration)
	if status == Status.DONE:
		character.velocity.x = 0
	return status
