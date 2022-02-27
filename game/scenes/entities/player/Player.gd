extends Node

enum InputType {
	KEYBOARD,
	JOYSTICK,
	DISABLED
}

export (InputType) var input_type: int
export (int) var joystick_id: int


func _get_local_input() -> Dictionary:
	var input: = {}
	
	var left: = "move_left"
	var right: = "move_right"
	var up: = "move_up"
	var down: = "move_down"
	var ac_pass: = "pass"
	
	match input_type:
		InputType.DISABLED:
			return input
		InputType.KEYBOARD:
			left = "move_left_kb"
			right = "move_right_kb"
			up = "move_up_kb"
			down = "move_down_kb"
			ac_pass = "pass_kb"
		InputType.JOYSTICK:
			match joystick_id:
				0:
					left = "move_left_joy0"
					right = "move_right_joy0"
					up = "move_up_joy0"
					down = "move_down_joy0"
					ac_pass = "pass_joy0"
				1:
					left = "move_left_joy1"
					right = "move_right_joy1"
					up = "move_up_joy1"
					down = "move_down_joy1"
					ac_pass = "pass_joy1"
				2:
					left = "move_left_joy2"
					right = "move_right_joy2"
					up = "move_up_joy2"
					down = "move_down_joy2"
					ac_pass = "pass_joy2"
				3:
					left = "move_left_joy3"
					right = "move_right_joy3"
					up = "move_up_joy3"
					down = "move_down_joy3"
					ac_pass = "pass_joy3"
				4:
					left = "move_left_joy4"
					right = "move_right_joy4"
					up = "move_up_joy4"
					down = "move_down_joy4"
					ac_pass = "pass_joy4"
				5:
					left = "move_left_joy5"
					right = "move_right_joy5"
					up = "move_up_joy5"
					down = "move_down_joy5"
					ac_pass = "pass_joy5"
				6:
					left = "move_left_joy6"
					right = "move_right_joy6"
					up = "move_up_joy6"
					down = "move_down_joy6"
					ac_pass = "pass_joy6"
				7:
					left = "move_left_joy7"
					right = "move_right_joy7"
					up = "move_up_joy7"
					down = "move_down_joy7"
					ac_pass = "pass_joy7"
	
	var input_vector: = SGFixed.from_float_vector2(Input.get_vector(left, right, up, down))
	
	if input_vector != SGFixed.from_float_vector2(Vector2.ZERO):
		input["input_vector"] = input_vector
	
	if Input.is_action_just_pressed(ac_pass):
		input["pass"] = true
	
	return input


func _network_process(input: Dictionary) -> void:
	pass


func _save_state() -> Dictionary:
	return {}


func _load_state(state: Dictionary) -> void:
	pass
