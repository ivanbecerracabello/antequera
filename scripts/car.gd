extends VehicleBody3D

var driver : CharacterBody3D = null

@export var MAX_STEER = 0.9
@export var ENGINE_POWER = 100

# Rear lights when braking
@onready var brake_light = $LeftBrakeLight
@onready var reverse_light = $LeftReverseLight

func _ready() -> void:
	pass

func _physics_process(delta):
	if driver == null:
		engine_force = 0
		steering = 0
		return
	
	steering = move_toward(steering, Input.get_axis("right", "left") * MAX_STEER, delta * 10)
	engine_force = Input.get_axis("backward", "forward") * ENGINE_POWER
	
	apply_braking_lights()
	apply_reverse_lights()

func apply_braking_lights():
	if driver == null:
		return

	var lights = brake_light.get_active_material(0)
	
	var throttle = Input.get_axis("backward", "forward")
	var forward_speed = transform.basis.z.dot(linear_velocity)
	var braking = throttle < 0 and forward_speed > 1.0
	if braking:
		lights.albedo_color = Color8(220, 40, 40)
		lights.emission_enabled = true
		lights.emission = Color(0.8, 0.05, 0.05)
		lights.emission_energy_multiplier = 1.5
		
	else:
		lights.albedo_color = Color8(129, 5, 5)
		lights.emission_enabled = false

func apply_reverse_lights():
	if driver == null:
		return
	var lights = reverse_light.get_active_material(0)

	var throttle = Input.get_axis("backward", "forward")
	var forward_speed = transform.basis.z.dot(linear_velocity)

	var pressing_reverse = throttle < -0.2
	var moving_backward = forward_speed < -1.0

	var is_reversing = pressing_reverse and moving_backward

	if is_reversing:
		lights.albedo_color = Color("#A8C8FF")
		lights.emission_enabled = true
		lights.emission = Color(0.5, 0.6, 1.0)
		lights.emission_energy_multiplier = 1.2
	else:
		lights.albedo_color = Color("#6C6C6C")
		lights.emission_enabled = false


func _on_area_3d_body_entered(body: Node3D) -> void:
	print(body.name)
	if body.is_in_group("player"):
		body.nearby_vehicle = self

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.nearby_vehicle = null
