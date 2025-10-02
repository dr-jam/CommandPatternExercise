@abstract class_name Command

enum Status {
	ACTIVE,
	DONE,
	ERROR,
}

@abstract func execute(_character: Character) -> Status
