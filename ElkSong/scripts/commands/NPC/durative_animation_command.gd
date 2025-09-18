class_name DurativeAnimationCommand
extends Command

var _timer:Timer

func execute(character:Character) -> Status:
	return Status.ERROR


func _manage_durative_animation_command(character:Character, animation:String, duration:float = 0.0) -> Status:
	if _timer == null:
		character.animation_player.play(animation)
		_timer = Timer.new()
		character.add_child(_timer)
		_timer.one_shot = true
		character.command_callback(animation)

		if !is_zero_approx(duration):
			_timer.start(duration)
		else:
			_timer.start(character.animation_player.current_animation_length)
		return Status.ACTIVE
	
	if !_timer.is_stopped():
		return Status.ACTIVE
	else:
		return Status.DONE
