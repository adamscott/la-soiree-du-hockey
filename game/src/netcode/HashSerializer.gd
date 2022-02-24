extends "res://addons/godot-rollback-netcode/HashSerializer.gd"


func serialize_object(value: Object):
	if value is SGFixedVector2:
		return {x = value.x, y = value.y}
	elif value is SGFixedTransform2D:
		return {
			x = {x = value.x.x, y = value.x.y},
			y = {x = value.y.x, y = value.y.y},
			origin = {x = value.origin.x, y = value.origin.y},
		}
	return .serialize_object(value)
