extends VehicleBody3D

var MAX_STEER := 0.6
var ARRIVAL_DISTANCE := 2.0

var BUS_STOPS = [
	Vector3(-13, 0, -136),
	Vector3(-13, 0, -112), # Roundabout
	Vector3(-22, 0, -100),
	Vector3(-14, 0, -88),
	Vector3(-14, 0, -24), # Roundabout
	Vector3(-27, 0, -22),
	Vector3(-150, 0, -22),
	Vector3(-162, 0, -30),
	Vector3(-162, 0, -106),
	Vector3(-121, 0, -110),
	Vector3(-118, 0, -176),
	Vector3(-59, 0, -180)
]

var current_target_index: int = 0

func _physics_process(_delta):
	var engine_power := 18
	var target_position = BUS_STOPS[current_target_index]
	var to_target = target_position - global_transform.origin
	to_target.y = 0
	var distance = to_target.length()

	# Get the forward direction of the bus (negative Z)
	var forward = global_transform.basis.z
	forward.y = 0
	forward = forward.normalized()
	var target_dir = to_target.normalized()

	# Calculate steering angle
	var angle_to_target = forward.signed_angle_to(target_dir, Vector3.UP)
	steering = clamp(angle_to_target * 2.0, -MAX_STEER, MAX_STEER)
	
	# Apply engine force (always moving forward)
	engine_force = engine_power

	# Switch to the next waypoint when close enough
	if distance < ARRIVAL_DISTANCE:
		current_target_index = (current_target_index + 1) % BUS_STOPS.size()
