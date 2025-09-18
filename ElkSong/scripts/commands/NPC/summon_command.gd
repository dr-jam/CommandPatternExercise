class_name SummonCommand
extends DurativeAnimationCommand


func execute(character:Character) -> Status:
	var status:Command.Status = _manage_durative_animation_command(character, "summon")
	return status
