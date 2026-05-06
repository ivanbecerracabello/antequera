extends StaticBody3D

var closed
var current_rotation

func _ready():
	closed = true
	current_rotation = rad_to_deg(rotation.y)

func toggle() -> bool:
	var tween = create_tween()
	
	if closed:
		tween.tween_property(self, "rotation:y", deg_to_rad(current_rotation - 90), 3)
		closed = false
		return true
	else:
		tween.tween_property(self, "rotation:y", deg_to_rad(current_rotation), 3)
		closed = true
		return false
