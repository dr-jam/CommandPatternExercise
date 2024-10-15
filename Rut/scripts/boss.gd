class_name Boss 
extends Character 

var health:int = 100
var target : Character
var cmd_list : Array[Command]

var _death:bool = false

@onready var audio_player:AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	target = %Player as Player
	jump_velocity = -600
	movement_speed = 400
	$Sprite2D.visible = false


func _process(_delta):
	if _death:
		if !animation_player.is_playing():
			sprite.visible = false
		return
		
	if len(cmd_list)>0:
		var command_status:Command.Status = cmd_list.front().execute(self)
		#if command_status == Command.Status.ACTIVE:
		if Command.Status.DONE == command_status:
			cmd_list.pop_front()
	else:
		animation_player.play("idle")


func take_damage(damage:int):
	health -= damage
	_manage_desperation()
	audio_player.stop()
	audio_player["parameters/switch_to_clip"] = "sadyell"
	audio_player.play()

	if 0 >= health:
		_death = true
		velocity = Vector2.ZERO
		audio_player.stop()
		audio_player["parameters/switch_to_clip"] = "yell3"
		audio_player.play()
		animation_player.play_backwards("summon")


func command_callback(command_name:String) -> void:
	if "summon" == command_name:
		audio_player.stop()
		audio_player["parameters/switch_to_clip"] = "yell1"
		audio_player.play()
	if "jump" == command_name:
		audio_player.stop()
		audio_player["parameters/switch_to_clip"] = "blast"
		audio_player.play()


func _manage_desperation() -> void:
	var pitch_bus_id = AudioServer.get_bus_index("boss")
	var pitch_bus_effect_count = AudioServer.get_bus_effect_count(pitch_bus_id)

	var pitch_shift_effect:AudioEffectPitchShift = null

	for i in pitch_bus_effect_count:
		var effect = AudioServer.get_bus_effect(pitch_bus_id,i)
		if effect is AudioEffectPitchShift:
			pitch_shift_effect = effect

	if pitch_shift_effect != null:
		pitch_shift_effect.pitch_scale = 1.0 + (100.0 - float(health)) / 100.0
