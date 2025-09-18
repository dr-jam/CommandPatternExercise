class_name AttackCommand
extends Command 


func execute(character: Character) -> Status:
	character.attacking = true
	character.command_callback("attack")
	return Status.DONE
