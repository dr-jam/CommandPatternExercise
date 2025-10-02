class_name Player
extends Character 

@export var health:int = 100

var _damaged:bool = false
var _dead:bool = false

@onready var animation_tree:AnimationTree = $AnimationTree

func _ready():
	animation_tree.active = true
	bind_player_input_commands()
	command_callback("undeath")


func _physics_process(delta: float):
	if _dead:
		return

	var move_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")

	#Stage1 - handle jump input and commands here.


	if Input.is_action_just_pressed("attack"):
		fire1.execute(self)
	
	if move_input > 0.1:
		right_cmd.execute(self)
	elif move_input < -0.1:
		left_cmd.execute(self)
	else:
		idle.execute(self)
	
	super(delta)
	
	_manage_animation_tree_state()


func take_damage(damage:int) -> void:
	health -= damage
	_damaged = true
	if 0 >= health:
		_play($Audio/defeat)
		_dead = true
		animation_tree.active = false
		animation_player.play("death")
	else:
		_play($Audio/hurt)


func bind_player_input_commands():
	right_cmd = MoveRightCommand.new()
	left_cmd = MoveLeftCommand.new()
	up_cmd = IdleCommand.new()
	fire1 = AttackCommand.new()
	idle = IdleCommand.new()


func unbind_player_input_commands():
	right_cmd = IdleCommand.new()
	left_cmd = IdleCommand.new()
	up_cmd = IdleCommand.new()
	fire1 = IdleCommand.new()
	idle = IdleCommand.new()


func resurrect() -> void:
	_dead = false
	health = 100
	animation_tree.active = true
	var sm:AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
	command_callback("undeath")
	sm.travel("summon")


func command_callback(cmd_name:String) -> void:
	if "attack" == cmd_name:
		_play($Audio/attack)
		
	if "jump" == cmd_name:
		_play($Audio/jump)
		
	if "engage" == cmd_name:
		_play($Audio/engage)
		
	if "undeath" == cmd_name:
		_play($Audio/undeath)


#Logic to support the state machine in the AnimationTree
func _manage_animation_tree_state() -> void:
	if !is_zero_approx(velocity.x):
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/moving"] = true
	else:
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/moving"] = false
	
	if is_on_floor():
		animation_tree["parameters/conditions/jumping"] = false
		animation_tree["parameters/conditions/on_floor"] = true
	else:
		animation_tree["parameters/conditions/jumping"] = true
		animation_tree["parameters/conditions/on_floor"] = false
	
	#toggles
	if attacking:
		animation_tree["parameters/conditions/attacking"] = true
		attacking = false
	else:
		animation_tree["parameters/conditions/attacking"] = false
		
	if _damaged:
		animation_tree["parameters/conditions/damaged"] = true
		_damaged = false
	else:
		animation_tree["parameters/conditions/damaged"] = false


func _play(player:AudioStreamPlayer2D) -> void:
	if !player.playing:
		player.play()
