extends VehicleBody3D

var MAX_STEER := 0.6
var ARRIVAL_DISTANCE := 2.0

var BUS_STOPS = [
	Vector3(-14, 0, -133),
	Vector3(-14, 0, -112), # Enter roundabout.
	Vector3(-22, 0, -100),
	Vector3(-14, 0, -90), # Exit roundabount.
	Vector3(-14, 0, -24), # Enter roundabout.
	Vector3(-22, 0, -13),
	Vector3(-11, 0, -2),
	Vector3(-1, 0, -10), # Exit roundabout.
	Vector3(119, 0, -10), # Capitan Moreno.
	Vector3(160, 0, 29), # City Hall.

	Vector3(415, 0, 30) # San Sebastian.
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
