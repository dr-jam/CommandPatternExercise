class_name DurativeDialogueCommand
extends DurativeAnimationCommand

var _script:String = ""
var _duration:float

func _init(script:String, duration:float = 1.0):
	_script = script
	_duration = duration
	
func execute(character:Character) -> Command.Status:
	if _timer == null:
		character.dialogue_box.label.text = _script
		character.dialogue_box.visible = true
		_timer = Timer.new()
		character.add_child(_timer)
		_timer.one_shot = true
		_timer.start(_duration)
		return Status.ACTIVE
	
	if !_timer.is_stopped():
		return Status.ACTIVE
	else:
		character.dialogue_box.visible = false
		return Status.DONE
