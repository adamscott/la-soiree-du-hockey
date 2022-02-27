tool
extends "StateMachinePlayer.gd"



func _ready() -> void:
	process_mode = ProcessMode.MANUAL
	add_to_group("network_sync")


func _network_process(input: Dictionary) -> void:
	if active:
		update()


func _save_state() -> Dictionary:
	var state: = {
		"active": active,
		"stack": stack
	}
	return state


func _load_state(state: Dictionary) -> void:
	active = state["active"]
	stack = state["stack"]
