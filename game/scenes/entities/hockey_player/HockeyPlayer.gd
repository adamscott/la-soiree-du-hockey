extends SGKinematicBody2D

const Player: = preload("res://scenes/entities/player/Player.gd")

export (int) var player_id: int = 1


func get_player() -> Player:
	return Players.get_player_by_id(player_id)


func _get_local_input() -> Dictionary:
	var input_vector: = SGFixed.from_float_vector2(Input.get_vector("move_left", "move_right", "move_up", "move_down"))
	
	var input: = {}
	
	if input_vector != SGFixed.vector2(SGFixed.from_int(0), SGFixed.from_int(0)):
		input["input_vector"] = input_vector
	
	return input


func _network_process(input: Dictionary) -> void:
	var input_vector: SGFixedVector2 = input.get("input_vector", SGFixed.from_float_vector2(Vector2.ZERO))
	
	fixed_position = fixed_position.add(
		input["input_vector"].mul(SGFixed.from_float(8.0))
	)


func _save_state() -> Dictionary:
	return {
		"fixed_position_x": fixed_position_x,
		"fixed_position_y": fixed_position_y
	}


func _load_state(state: Dictionary) -> void:
	fixed_position = SGFixed.vector2(state["fixed_position_x"], state["fixed_position_y"])
