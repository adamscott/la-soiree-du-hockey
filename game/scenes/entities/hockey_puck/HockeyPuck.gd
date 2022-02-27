extends SGKinematicBody2D

var current_hockey_player setget set_current_hockey_player
var friction: int
var velocity: SGFixedVector2 = SGFixed.from_float_vector2(Vector2.ZERO)


func set_current_hockey_player(val) -> void:
	current_hockey_player = val


func _ready() -> void:
	friction = ProjectSettings["game/physics/ice/friction"]


func _network_process(input: Dictionary) -> void:
	if current_hockey_player:
		process_hockey_player()
	else:
		process_no_hockey_player()


func _save_state() -> Dictionary:
	var state: = {
		"fixed_position_x": fixed_position_x,
		"fixed_position_y": fixed_position_y
	}
	
	if current_hockey_player:
		state["current_hockey_player"] = current_hockey_player.get_path()
	
	if not current_hockey_player:
		state["velocity_x"] = velocity.x
		state["velocity_y"] = velocity.y
	
	return state


func _load_state(state: Dictionary) -> void:
	fixed_position_x = state["fixed_position_x"]
	fixed_position_y = state["fixed_position_y"]
	
	if state.has("current_hockey_player"):
		current_hockey_player = get_node(state["current_hockey_player"])
	else:
		current_hockey_player = null
	
	if state.has("velocity_x"):
		velocity = SGFixed.vector2(state["velocity_x"], state["velocity_y"])
	
	sync_to_physics_engine()


func process_hockey_player() -> void:
	set_global_fixed_position(current_hockey_player.hockey_area.get_global_fixed_position())
	sync_to_physics_engine()


func process_no_hockey_player() -> void:
	var new_length: = velocity.length() - friction
	
	if new_length < 0:
		new_length = 0
	
	velocity = velocity.normalized().mul(new_length)
	velocity = move_and_slide(velocity)
