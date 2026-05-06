extends VehicleBody3D

var is_active := false

@export var MAX_STEER = 0.9
@export var ENGINE_POWER = 100

var mouse_sensitivity := 0.001
var twist_input := 0.0
var pitch_input := 0.0

# Rear lights when braking
@onready var rear_left_light = $BrakeLight

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	if not is_active:
		engine_force = 0
		steering = 0
		return
	
	steering = move_toward(steering, Input.get_axis("right", "left") * MAX_STEER, delta * 10)
	engine_force = Input.get_axis("backward", "forward") * ENGINE_POWER
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	apply_camera()
	apply_braking_lights()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = - event.relative.x * mouse_sensitivity
			pitch_input = - event.relative.y * mouse_sensitivity

func apply_camera():
	# Horizontal rotation.
	$TwistPivot.rotate_y(twist_input)
	
	# Vertical rotation.
	$TwistPivot/PitchPivot.rotate_x(pitch_input)
	$TwistPivot/PitchPivot.rotation.x = clamp(
		$TwistPivot/PitchPivot.rotation.x,
		-0.5,
		0.5
	)
	twist_input = 0.0
	pitch_input = 0.0

func apply_braking_lights():
	var throttle = Input.get_axis("backward", "forward")
	var forward_speed = transform.basis.z.dot(linear_velocity)

	var braking = throttle < 0 and forward_speed > 2.0
	if braking:
		rear_left_light.light_energy = 2
	else:
		rear_left_light.light_energy = 0.0
