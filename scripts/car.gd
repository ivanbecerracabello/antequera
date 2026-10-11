extends VehicleBody3D

var driver: CharacterBody3D = null

@export var MAX_STEER = 0.9
@export var ENGINE_POWER = 100

@onready var brake_light = $LeftBrakeLight
@onready var right_brake_light = $RightBrakeLight
@onready var reverse_light = $LeftReverseLight
@onready var right_reverse_light = $RightReverseLight
@onready var asset = $Asset
@onready var driver_door = $Asset/Driver

var brake_mat: StandardMaterial3D
var right_brake_mat: StandardMaterial3D

var reverse_mat: StandardMaterial3D
var right_reverse_mat: StandardMaterial3D

var door_closed := true
var door_closed_rotation_y: float = 0.0
var door_open_rotation_y: float = 0.0


func _ready() -> void:
	# --- BRAKE LIGHT MATERIAL ---
	# var mat = brake_light.get_active_material(0)
	# if mat:
	# 	brake_mat = mat.duplicate()
	# 	brake_light.set_surface_override_material(0, brake_mat)
	# 
	# mat = right_brake_light.get_active_material(0)
	# if mat:
	# 	right_brake_mat = mat.duplicate()
	# 	right_brake_light.set_surface_override_material(0, right_brake_mat)

	# --- REVERSE LIGHT MATERIAL ---
	# var rmat = reverse_light.get_active_material(0)
	# if rmat:
	# 	reverse_mat = rmat.duplicate()
	# 	reverse_light.set_surface_override_material(0, reverse_mat)
	# rmat = right_reverse_light.get_active_material(0)
	# if rmat:
	# 	right_reverse_mat = rmat.duplicate()
	# 	right_reverse_light.set_surface_override_material(0, right_reverse_mat)

	brake_light.visible = false
	right_brake_light.visible = false
	reverse_light.visible = false
	right_reverse_light.visible = false

	if driver_door:
		door_closed_rotation_y = driver_door.rotation.y
		door_open_rotation_y = driver_door.rotation.y + deg_to_rad(-70)
		driver_door.rotation.y = door_closed_rotation_y


func _physics_process(delta):
	if driver == null:
		engine_force = 0
		steering = 0
		# update_light_mesh_visibility()
		return

	if driver.command_mode:
		engine_force = 0
		steering = 0
		# update_light_mesh_visibility()
		return
		
	steering = move_toward(
		steering,
		Input.get_axis("right", "left") * MAX_STEER,
		delta * 10
	)

	engine_force = Input.get_axis("backward", "forward") * ENGINE_POWER
	# update_light_mesh_visibility()


# func calculate_braking():
# 	if driver == null or brake_mat == null:
# 		return
#
# 	var throttle = Input.get_axis("backward", "forward")
# 	var forward_speed = transform.basis.z.dot(linear_velocity)
# 	var braking = throttle < 0 and forward_speed > 1.0
#
# 	if braking:
# 		apply_braking_lights(brake_mat)
# 		apply_braking_lights(right_brake_mat)
# 	else:
# 		brake_mat.albedo_color = Color8(129, 5, 5)
# 		brake_mat.emission_enabled = false
# 		right_brake_mat.albedo_color = Color8(129, 5, 5)
# 		right_brake_mat.emission_enabled = false
#
# func apply_braking_lights(material: StandardMaterial3D):
# 	material.albedo_color = Color8(220, 40, 40)
# 	material.emission_enabled = true
# 	material.emission = Color(0.8, 0.05, 0.05)
# 	material.emission_energy_multiplier = 1.5
#
# func calculate_reversing():
# 	if driver == null or reverse_mat == null:
# 		return
#
# 	var throttle = Input.get_axis("backward", "forward")
# 	var forward_speed = transform.basis.z.dot(linear_velocity)
#
# 	var is_reversing = throttle < -0.2 and forward_speed < -1.0
#
# 	if is_reversing:
# 		apply_reverse_lights(reverse_mat)
# 		apply_reverse_lights(right_reverse_mat)
# 	else:
# 		reverse_mat.albedo_color = Color("#6C6C6C")
# 		reverse_mat.emission_enabled = false
# 		
# 		right_reverse_mat.albedo_color = Color("#6C6C6C")
# 		right_reverse_mat.emission_enabled = false
#
# func apply_reverse_lights(material: StandardMaterial3D):
# 	material.albedo_color = Color("#A8C8FF")
# 	material.emission_enabled = true
# 	material.emission = Color(0.5, 0.6, 1.0)
# 	material.emission_energy_multiplier = 1.2

func update_light_mesh_visibility() -> void:
	var throttle = Input.get_axis("backward", "forward")
	var forward_speed = transform.basis.z.dot(linear_velocity)
	var braking = throttle < 0 and forward_speed > 1.0
	var is_reversing = throttle < -0.2 and forward_speed < -1.0

	# brake_light.visible = braking
	# right_brake_light.visible = braking
	# reverse_light.visible = is_reversing
	# right_reverse_light.visible = is_reversing
	brake_light.visible = false
	right_brake_light.visible = false
	reverse_light.visible = false
	right_reverse_light.visible = false

func set_lights(brake_on: bool, reverse_on: bool):
	# brake_light.visible = brake_on
	# right_brake_light.visible = brake_on
	# reverse_light.visible = reverse_on
	# right_reverse_light.visible = reverse_on
	brake_light.visible = false
	right_brake_light.visible = false
	reverse_light.visible = false
	right_reverse_light.visible = false

func toggle_door() -> void:
	if not driver_door:
		return
	
	var target_y = door_closed_rotation_y
	if door_closed:
		target_y = door_open_rotation_y
	
	var tween = create_tween()
	tween.tween_property(driver_door, "rotation:y", target_y, 0.35)
	door_closed = !door_closed

func open_door() -> void:
	if not driver_door or not door_closed:
		return
	toggle_door()

func close_door() -> void:
	if not driver_door or door_closed:
		return
	toggle_door()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.nearby_vehicle = self


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.nearby_vehicle = null
