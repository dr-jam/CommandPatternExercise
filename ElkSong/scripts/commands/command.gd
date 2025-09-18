class_name Command

enum Status {
	ACTIVE,
	DONE,
	ERROR,
}

func execute(_character: Character) -> Status:
	return Status.DONE
