extends "res://addons/godot-rollback-netcode/MessageSerializer.gd"


enum HeaderFlags {
	HAS_INPUT_VECTOR = 0b00000001
}

func get_input_path_mapping(path: NodePath) -> int:
	# 1 - 8
	if Players.is_player_hockey_player_path(path):
		return Players.get_player_hockey_player_id_by_path(path)
	
	return -1


func get_input_path_mapping_reverse(id: int) -> NodePath:
	if id >= 1 and id <= 8:
		return Players.get_player_hockey_player_path_by_id(id)
	
	return NodePath("")


func _init() -> void:
	pass


func serialize_input(all_input: Dictionary) -> PoolByteArray:
	var buffer: = StreamPeerBuffer.new()
	buffer.resize(16)
	
	# Input hash
	buffer.put_u32(all_input["$"])
	
	# Size
	buffer.put_u8(all_input.size() - 1)
	
	for path in all_input:
		if path == "$":
			continue
		
		buffer.put_u8(get_input_path_mapping(path))
		
		var header: = 0
		var input = all_input[path]
		
		if input.has("input_vector"):
			header |= HeaderFlags.HAS_INPUT_VECTOR
		
		buffer.put_u8(header)
		
		if input.has("input_vector"):
			var input_vector: SGFixedVector2 = input["input_vector"]
			buffer.put_64(input_vector.x)
			buffer.put_64(input_vector.y)
	
	buffer.resize(buffer.get_position())
	return buffer.data_array


func unserialize_input(serialized: PoolByteArray) -> Dictionary:
	var buffer: = StreamPeerBuffer.new()
	buffer.put_data(serialized)
	buffer.seek(0)
	
	var all_input: = {}
	
	all_input["$"] = buffer.get_u32()
	
	var input_count: = buffer.get_u8()
	if input_count == 0:
		return all_input
	
	var path: String = get_input_path_mapping_reverse(buffer.get_u8())
	var input: = {}
	
	var header: = buffer.get_u8()
	if header & HeaderFlags.HAS_INPUT_VECTOR:
		input["input_vector"] = SGFixed.vector2(buffer.get_64(), buffer.get_64())
	
	all_input[path] = input
	
	return all_input
