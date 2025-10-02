extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var player:Player = owner as Player
	text = "<%3d, %3d>" % [player.position.x, player.position.y]
	#text = str(abs(owner.velocity)) + "\n" + str(len(player.animation_player.get_queue()))
