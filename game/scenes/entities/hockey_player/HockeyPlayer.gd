extends SGKinematicBody2D

const YAFSM: = preload("res://addons/imjp94.yafsm/YAFSM.gd")
const StateMachinePlayer: = YAFSM.StateMachinePlayer
const Player: = preload("res://scenes/entities/player/Player.gd")
const HockeyPuck: = preload("res://scenes/entities/hockey_puck/HockeyPuck.gd")

var current_player: Player
var hockey_puck: HockeyPuck
var friction: int
var velocity: SGFixedVector2 = SGFixed.from_float_vector2(Vector2.ZERO)
var direction: String = "north"

var active: = true

onready var hockey: SGFixedNode2D = $Hockey
onready var hockey_area: SGArea2D = $Hockey/Area

onready var main_sm: StateMachinePlayer = $StateMachines/MainStateMachine
onready var play_type_sm: StateMachinePlayer = $StateMachines/PlayTypeStateMachine
onready var offense_sm: StateMachinePlayer = $StateMachines/OffenseStateMachine

onready var pass_timer: NetworkTimer = $Timers/PassTimer

onready var nat: NetworkAnimationPlayer = $NetworkAnimationPlayer


func _on_MainStateMachine_transited(from, to) -> void:
	match to:
		"Idle":
			pass
		"Active":
			play_type_sm.restart()


func _on_PlayTypeStateMachine_transited(from, to) -> void:
	match to:
		"Offense":
			offense_sm.restart()
		"Defense":
			offense_sm.active = false


func _on_OffenseStateMachine_transited(from, to) -> void:
	match to:
		"Pass":
			pass_timer.start()
			hockey_puck.current_hockey_player = null
			hockey_puck.velocity = velocity


func _on_PassTimer_timeout() -> void:
	hockey_puck = null


func _ready() -> void:
	friction = ProjectSettings["game/physics/ice/friction"]


func _network_process(input: Dictionary) -> void:
	match main_sm.get_current():
		"Active":
			update_position()
		"Idle":
			pass
	
	update_overlapping_bodies()
	
	if get_input().has("pass"):
		prints("offense_sm.active", offense_sm.active)
		offense_sm.set_trigger("pass")
		
	update_state_machines()


func _save_state() -> Dictionary:
	var state: = {
		"fixed_position_x": fixed_position_x,
		"fixed_position_y": fixed_position_y,
		"velocity_x": velocity.x,
		"velocity_y": velocity.y,
		"direction": direction,
		"main_stack": main_sm.stack,
		"active": active
	}
	
	if current_player:
		state["current_player"] = current_player.get_path()
	
	if hockey_puck:
		state["hockey_puck"] = hockey_puck.get_path()
	
	if play_type_sm.active:
		state["play_type_stack"] = play_type_sm.stack
	
	if offense_sm.active:
		state["offense_stack"] = offense_sm.stack
	
	return state


func _load_state(state: Dictionary) -> void:
	fixed_position = SGFixed.vector2(state["fixed_position_x"], state["fixed_position_y"])
	hockey.update_float_transform()
	direction = state["direction"]
	velocity = SGFixed.vector2(state["velocity_x"], state["velocity_y"])
	
	if state.has("current_player"):
		current_player = get_node(state["current_player"]) as Player
	else:
		current_player = null
	
	if state.has("hockey_puck"):
		hockey_puck = get_node(state["hockey_puck"]) as HockeyPuck
	else:
		hockey_puck = null
	
	if state.has("play_type_stack"):
		play_type_sm.stack = state["play_type_stack"]
		play_type_sm.active = true
	else:
		play_type_sm.active = false
	
	if state.has("offense_stack"):
		offense_sm.stack = state["offense_stack"]
	else:
		offense_sm.active = false
	
	active = state["active"]
	
	update_state_machines()
	
	sync_to_physics_engine()
	hockey_area.sync_to_physics_engine()


func update_state_machines() -> void:
	if not main_sm.active:
		main_sm.restart()
		main_sm.update()
		
	main_sm.set_param("active", active)
	main_sm.update()
	
	play_type_sm.set_param("has_puck", hockey_puck != null)
	play_type_sm.update()
	
	offense_sm.update()


func update_position() -> void:
	if not current_player:
		return
	
	var player_input: = get_input()
	
	if not player_input.has("input_vector"):
		Console.write_line("player input has not input_vector")
		return
	
	# var current_vector = hockey.fixed_transform.x.normalized()
	# prints("current_vector", current_vector.x, current_vector.y)
	
	var current_vector: SGFixedVector2
	if velocity.normalized().length_squared() > 0:
		current_vector = velocity.normalized()
	else:
		var up: = SGFixed.vector2(SGFixed.from_int(0), SGFixed.from_int(1))
		
		match direction:
			"north":
				current_vector = up
			"north_east":
				current_vector = up.rotated(SGFixed.PI_DIV_4)
			"north_west":
				current_vector = up.rotated(-SGFixed.PI_DIV_4)
			"east":
				current_vector = up.rotated(SGFixed.PI_DIV_2)
			"west":
				current_vector = up.rotated(-SGFixed.PI_DIV_2)
			"south_east":
				current_vector = up.rotated(SGFixed.PI_DIV_2 + SGFixed.PI_DIV_4)
			"south_west":
				current_vector = up.rotated(-SGFixed.PI_DIV_2 - SGFixed.PI_DIV_4)
			"south":
				current_vector = up.rotated(SGFixed.PI)
		
		current_vector = current_vector.rotated(SGFixed.PI)
	
	
	var desired_vector: = player_input["input_vector"] as SGFixedVector2
	desired_vector = desired_vector.normalized()
		
	var angle_to: int = current_vector.angle_to(desired_vector)
	# angle_to = normalize_angle(angle_to)
	
	# 6554 = 0.1
	if abs(angle_to) > 6554:
		if angle_to < 0:
			angle_to = -6554
		elif angle_to > 0:
			angle_to = 6554
	
	var target_vector: = current_vector.rotated(angle_to)
	var angle_to_y: = SGFixed.vector2(SGFixed.from_int(0), SGFixed.from_int(1)).angle_to(target_vector)
	
	# angle_to_y = normalize_angle(angle_to_y)
	
	if abs(angle_to_y) > SGFixed.PI:
		angle_to_y = SGFixed.PI - angle_to_y
	
	var new_direction: String
	if abs(angle_to_y) < SGFixed.PI_DIV_4 / 2:
		# new_direction = "north"
		new_direction = "south"
	elif abs(angle_to_y) < SGFixed.PI_DIV_4 + (SGFixed.PI_DIV_4 / 2):
		if angle_to_y > 0:
			# new_direction = "north_east"
			new_direction = "south_west"
		else:
			#new_direction = "north_west"
			new_direction = "south_east"
	elif abs(angle_to_y) < SGFixed.PI_DIV_2 + (SGFixed.PI_DIV_4 / 2):
		if angle_to_y > 0:
			# new_direction = "east"
			new_direction = "west"
		else:
			# new_direction = "west"
			new_direction = "east"
	elif abs(angle_to_y) < SGFixed.PI_DIV_2 + SGFixed.PI_DIV_4 + (SGFixed.PI_DIV_4 / 2):
		if angle_to_y > 0:
			# new_direction = "south_east"
			new_direction = "north_west"
		else:
			# new_direction = "south_west"
			new_direction = "north_east"
	else:
		# new_direction = "south"
		new_direction = "north"
	
	if new_direction != direction:
		nat.play(new_direction)
		direction = new_direction
	
	var acceleration: SGFixedVector2 = player_input["input_vector"].mul(SGFixed.from_int(2))
	velocity = velocity.add(acceleration)
	
	var new_length: = velocity.length()
	new_length -= friction
	if new_length < 0:
		new_length = 0
	
	velocity = velocity.normalized().mul(new_length)
	velocity = move_and_slide(velocity)
	
	if hockey_puck and hockey_puck.current_hockey_player == self:
		hockey_puck.set_global_fixed_position(
			hockey_puck.get_global_fixed_position().linear_interpolate(
				hockey_area.get_global_fixed_position(),
				32770  # 0.5
			)
		)


func update_overlapping_bodies() -> void:
	hockey_area.sync_to_physics_engine()
	
	var overlapping_bodies: = hockey_area.get_overlapping_bodies()
	for overlapping_body in overlapping_bodies:
		if overlapping_body is HockeyPuck:
			if offense_sm.active and offense_sm.get_current() == "Pass":
				break
			overlapping_body.current_hockey_player = self
			hockey_puck = overlapping_body


func normalize_angle(radians: int) -> int:
	if abs(radians) > (SGFixed.PI_DIV_2):
		return SGFixed.TAU - radians
	return radians


func get_input() -> Dictionary:
	return SyncManager.get_input_frame(SyncManager.current_tick)\
		.get_player_input(current_player.get_network_master())\
		.get(str(current_player.get_path()), {})
