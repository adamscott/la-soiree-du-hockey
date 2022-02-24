extends SGKinematicBody2D

const YAFSM: = preload("res://addons/imjp94.yafsm/YAFSM.gd")
const StateMachinePlayer: = YAFSM.StateMachinePlayer
const Player: = preload("res://scenes/entities/player/Player.gd")

var current_player: Player
var friction: int
var velocity: SGFixedVector2 = SGFixed.from_float_vector2(Vector2.ZERO)

var active: = true
var has_puck: = false

onready var main_sm: StateMachinePlayer = $StateMachines/MainStateMachine
onready var play_type_sm: StateMachinePlayer = $StateMachines/PlayTypeStateMachine


func _ready() -> void:
	friction = ProjectSettings["game/physics/ice/friction"]


func _network_process(input: Dictionary) -> void:
	Console.write_line("network process start")
	if not current_player:
		Console.write_line("current_player is null")
		return
	
	var player_input: Dictionary = SyncManager.get_input_frame(SyncManager.current_tick)\
		.get_player_input(current_player.get_network_master())\
		.get(str(current_player.get_path()), {})
	
	if not player_input.has("input_vector"):
		Console.write_line("player input has not input_vector")
		return
	
	var acceleration: SGFixedVector2 = player_input["input_vector"].mul(SGFixed.from_int(2))
	velocity = velocity.add(acceleration)
	
	var new_length: = velocity.length()
	new_length -= friction
	if new_length < 0:
		new_length = 0
	
	velocity = velocity.normalized().mul(new_length)
	
	# Does not work
	#velocity = move_and_slide(velocity)
	# Or
	#move_and_collide(velocity)
	
	# Does work
	fixed_position = fixed_position.add(velocity)
	sync_to_physics_engine()
	
	
	update_state_machines()
	Console.write_line("network process end")


func _save_state() -> Dictionary:
	Console.write_line("save state")
	var state: = {
		"fixed_position_x": fixed_position_x,
		"fixed_position_y": fixed_position_y,
		"velocity_x": velocity.x,
		"velocity_y": velocity.y,
		
		"main_state": main_sm.get_current(),
		"play_type_state": play_type_sm.get_current(),
		"active": active,
		"has_puck": has_puck
	}
	
	if current_player:
		state["current_player"] = current_player.get_path()
	
	return state


func _load_state(state: Dictionary) -> void:
	Console.write_line("load state")
	# prints("loading state", state)
	fixed_position = SGFixed.vector2(state["fixed_position_x"], state["fixed_position_y"])
	velocity = SGFixed.vector2(state["velocity_x"], state["velocity_y"])
	
	if state.has("current_player"):
		current_player = get_node(state["current_player"]) as Player
	else:
		current_player = null
	
	active = state["active"]
	has_puck = state["has_puck"]
	
	reset_state_machines(state)


func update_state_machines() -> void:
	main_sm.set_param("active", active)
	main_sm.update()
	
	play_type_sm.set_param("has_puck", has_puck)
	play_type_sm.update()


func reset_state_machines(state) -> void:
	main_sm.restart(false, false)
	main_sm.push(state["main_state"])
	main_sm.active = true
	
	play_type_sm.restart(false, false)
	play_type_sm.push(state["play_type_state"])
	play_type_sm.active = true
	
	update_state_machines()
