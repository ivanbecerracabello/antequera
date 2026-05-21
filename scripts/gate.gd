extends Node3D

var closed
var full_rotation := {}

func _ready():
	closed = true
	full_rotation.x = rotation.x
	full_rotation.y = rotation.y
	full_rotation.z = rotation.z

func toggle(axis: String) -> bool:
	var tween = create_tween()
	var property = "rotation:" + axis
	var start_rotation = full_rotation[axis]
	
	if closed:
		tween.tween_property(self, property,
			start_rotation - deg_to_rad(90), 3
		)
		closed = false
		return true
	else:
		tween.tween_property(self, property, start_rotation, 3)
		closed = true
		return false
