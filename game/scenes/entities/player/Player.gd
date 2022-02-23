extends Node

var input_vector: SGFixedVector2 = SGFixed.from_float_vector2(Vector2.ZERO)

func _get_local_input() -> Dictionary:
	var input_vector: = SGFixed.from_float_vector2(Input.get_vector("move_left", "move_right", "move_up", "move_down"))
	
	var input: = {}
	
	if input_vector != SGFixed.from_float_vector2(Vector2.ZERO):
		input["input_vector"] = input_vector
	
	return input


func _network_process(input: Dictionary) -> void:
	var input_vector: SGFixedVector2 = input.get("input_vector", SGFixed.from_float_vector2(Vector2.ZERO))
	
	self.input_vector = input_vector


func _save_state() -> Dictionary:
	return {}


func _load_state(state: Dictionary) -> void:
	pass
