extends SGKinematicBody2D

const Player: = preload("res://scenes/entities/player/Player.gd")

var current_player: Player


func _network_process(input: Dictionary) -> void:
	if not current_player:
		return
	
	fixed_position = fixed_position.add(
		current_player.input_vector.mul(SGFixed.from_float(8.0))
	)


func _save_state() -> Dictionary:
	var state: = {
		"fixed_position_x": fixed_position_x,
		"fixed_position_y": fixed_position_y,
	}
	
	if current_player:
		state["current_player"] = current_player.get_path()
	
	return state


func _load_state(state: Dictionary) -> void:
	fixed_position = SGFixed.vector2(state["fixed_position_x"], state["fixed_position_y"])
	
	if state.has("current_player"):
		current_player = get_node(state["current_player"]) as Player
	else:
		current_player = null
