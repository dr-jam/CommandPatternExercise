class_name DurativeIdleCommand
extends DurativeAnimationCommand

var _duration:float

func _init(duration:float = 0.0):
	_duration = duration
	
func execute(character:Character) -> Command.Status:
	return _manage_durative_animation_command(character, "idle", _duration)
