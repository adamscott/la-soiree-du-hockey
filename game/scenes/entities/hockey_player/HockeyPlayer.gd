extends SGKinematicBody2D

const YAFSM: = preload("res://addons/imjp94.yafsm/YAFSM.gd")
const NetworkStateMachinePlayer: = YAFSM.NetworkStateMachinePlayer
const Player: = preload("res://scenes/entities/player/Player.gd")
const HockeyPuck: = preload("res://scenes/entities/hockey_puck/HockeyPuck.gd")

var current_player: Player
var hockey_puck: HockeyPuck
var friction: int
var velocity: SGFixedVector2 = SGFixed.from_float_vector2(Vector2.ZERO)
var acceleration: SGFixedVector2 = SGFixed.from_float_vector2(Vector2.ZERO)
var direction: String = "n"

var move_sm_stack: Array
var play_type_sm_stack: Array
var offense_sm_stack: Array
var offense_sm_active: bool = false

onready var hockey: SGFixedNode2D = $Hockey

onready var puck_position: SGFixedPosition2D = $Hockey/PuckPosition
onready var puck_area: SGArea2D = $PuckArea

onready var move_sm: NetworkStateMachinePlayer = $StateMachines/MoveStateMachine
onready var play_type_sm: NetworkStateMachinePlayer = $StateMachines/PlayTypeStateMachine
onready var offense_sm: NetworkStateMachinePlayer = $StateMachines/OffenseStateMachine

onready var pass_timer: NetworkTimer = $Timers/PassTimer

onready var animation_player: NetworkAnimationPlayer = $NetworkAnimationPlayer


func _on_MoveStateMachine_transited(from, to) -> void:
	match to:
		"Idle":
			pass
		"Active":
			pass


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
			hockey_puck.velocity = velocity.mul(SGFixed.from_int(3))


func _on_PassTimer_timeout() -> void:
	hockey_puck = null


func _ready() -> void:
	friction = ProjectSettings["game/physics/ice/friction"]
	move_sm.update()
	play_type_sm.update()


func _network_process(input: Dictionary) -> void:
	update_position()
	update_overlapping_bodies()
	update_puck()
	
	if get_input().has("pass"):
		offense_sm.set_trigger("pass")
	
	update_state_machines()


func _save_state() -> Dictionary:
	var state: = {
		"fixed_position_x": fixed_position_x,
		"fixed_position_y": fixed_position_y,
		"velocity_x": velocity.x,
		"velocity_y": velocity.y,
		"direction": direction
	}
	
	
	if velocity != SGFixed.from_float_vector2(Vector2.ZERO):
		state["velocity_x"] = velocity.x
		state["velocity_y"] = velocity.y
	
	if acceleration != SGFixed.from_float_vector2(Vector2.ZERO):
		state["acceleration_x"] = acceleration.x
		state["acceleration_y"] = acceleration.y
	
	if current_player:
		state["current_player"] = current_player.get_path()
	
	if hockey_puck:
		state["hockey_puck"] = hockey_puck.get_path()
	
	return state


func _load_state(state: Dictionary) -> void:
	fixed_position = SGFixed.vector2(state["fixed_position_x"], state["fixed_position_y"])
	hockey.update_float_transform()
	direction = state["direction"]
	
	if state.has("velocity_x"):
		velocity = SGFixed.vector2(state["velocity_x"], state["velocity_y"])
	else:
		velocity = SGFixed.from_float_vector2(Vector2.ZERO)
	
	if state.has("acceleration_x"):
		acceleration = SGFixed.vector2(state["acceleration_x"], state["acceleration_y"])
	else:
		acceleration = SGFixed.from_float_vector2(Vector2.ZERO)
	
	if state.has("current_player"):
		current_player = get_node(state["current_player"]) as Player
	else:
		current_player = null
	
	if state.has("hockey_puck"):
		hockey_puck = get_node(state["hockey_puck"]) as HockeyPuck
	else:
		hockey_puck = null
	
	update_state_machines()
	
	sync_to_physics()


func update_state_machines() -> void:
	move_sm.set_param("velocity_length_squared", velocity.length_squared())
	move_sm.update()
	
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
	
	var current_vector: SGFixedVector2
	if velocity.normalized().length_squared() > 0:
		current_vector = velocity.normalized()
	else:
		var up: = SGFixed.vector2(SGFixed.from_int(0), SGFixed.from_int(1))
		
		match direction:
			"n":
				current_vector = up
			"ne":
				current_vector = up.rotated(SGFixed.PI_DIV_4)
			"nw":
				current_vector = up.rotated(-SGFixed.PI_DIV_4)
			"e":
				current_vector = up.rotated(SGFixed.PI_DIV_2)
			"w":
				current_vector = up.rotated(-SGFixed.PI_DIV_2)
			"se":
				current_vector = up.rotated(SGFixed.PI_DIV_2 + SGFixed.PI_DIV_4)
			"sw":
				current_vector = up.rotated(-SGFixed.PI_DIV_2 - SGFixed.PI_DIV_4)
			"s", _:
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
	
	if abs(angle_to_y) < SGFixed.PI_DIV_4 / 2:
		# new_direction = "north"
		direction = "s"
	elif abs(angle_to_y) < SGFixed.PI_DIV_4 + (SGFixed.PI_DIV_4 / 2):
		if angle_to_y > 0:
			# new_direction = "north_east"
			direction = "sw"
		else:
			#new_direction = "north_west"
			direction = "se"
	elif abs(angle_to_y) < SGFixed.PI_DIV_2 + (SGFixed.PI_DIV_4 / 2):
		if angle_to_y > 0:
			# new_direction = "east"
			direction = "w"
		else:
			# new_direction = "west"
			direction = "e"
	elif abs(angle_to_y) < SGFixed.PI_DIV_2 + SGFixed.PI_DIV_4 + (SGFixed.PI_DIV_4 / 2):
		if angle_to_y > 0:
			# new_direction = "south_east"
			direction = "nw"
		else:
			# new_direction = "south_west"
			direction = "ne"
	else:
		# new_direction = "south"
		direction = "n"
	
	update_animation()
	
	acceleration = player_input["input_vector"].mul(SGFixed.from_int(2))
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
				puck_position.get_global_fixed_position(),
				32770  # 0.5
			)
		)


func update_overlapping_bodies() -> void:
	puck_area.sync_to_physics_engine()
	
	var overlapping_bodies: = puck_area.get_overlapping_bodies()
	for overlapping_body in overlapping_bodies:
		if overlapping_body is HockeyPuck:
			if offense_sm.active and offense_sm.get_current() == "Pass":
				break
			overlapping_body.current_hockey_player = self
			hockey_puck = overlapping_body


func update_puck() -> void:
	if hockey_puck:
		if hockey_puck.current_hockey_player != self:
			hockey_puck = null


func update_animation() -> void:
	var prefix: String
	match move_sm.get_current():
		"Moving":
			prefix = "moving"
		"Idle", _:
			prefix = "idle"
			
	match play_type_sm.get_current():
		"Defense":
			var target_animation: String = "%s_defense_%s" % [prefix, direction]
			if animation_player.current_animation != target_animation:
				animation_player.play(target_animation)
		"Offense":
			match offense_sm.get_current():
				"Idle":
					var target_animation: String = "%s_offense_%s" % [prefix, direction]
					if animation_player.current_animation != target_animation:
						animation_player.play(target_animation)
				"Pass":
					var target_animation: String = "pass_%s" % [direction]
					if animation_player.current_animation != target_animation:
						animation_player.play(target_animation)


func normalize_angle(radians: int) -> int:
	if abs(radians) > (SGFixed.PI_DIV_2):
		return SGFixed.TAU - radians
	return radians


func sync_to_physics() -> void:
	sync_to_physics_engine()
	puck_area.sync_to_physics_engine()


func get_input() -> Dictionary:
	return SyncManager.get_input_frame(SyncManager.current_tick)\
		.get_player_input(current_player.get_network_master())\
		.get(str(current_player.get_path()), {})
