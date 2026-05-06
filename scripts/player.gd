extends CharacterBody3D

var is_active := true

# Camera.
@onready var pivot = $Pivot
@onready var spring_arm = $Pivot/SpringArm3D
@onready var armature = $Body

# Movement.
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const LERP_VAL = .15
const VOID = -10

# Commands.
@onready var command_input = $"../LineEdit"
@onready var texts = $"../Label"
var message_log: Array[String] = []
const MAX_MESSAGES := 5
var command_mode = false

func _ready():
	if not is_multiplayer_authority():
		spring_arm.get_node("Camera3D").current = false
		return

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_message("Welcome to Antequera Role Play.")

func _physics_process(delta: float) -> void:
	if not is_active or command_mode:
		return
	
	apply_gravity(delta)
	void_check()
	apply_jump()
	apply_movement()
	
	move_and_slide()

func _input(event):
	if not is_multiplayer_authority():
		return
		
	if command_mode:
		if event.is_action_pressed("enter"):
			submit_command()
			get_viewport().set_input_as_handled() # 👈 IMPORTANT
	else:
		if event.is_action_pressed("text"):
			open_command()
			get_viewport().set_input_as_handled() # optional

func handle_input():
	pass
			
func _unhandled_input(event):
	if not is_multiplayer_authority():
		return
	if Input.is_action_just_pressed("ui_cancel"):
		#get_tree().quit()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			pivot.rotate_y(-event.relative.x * 0.005)
			spring_arm.rotate_x(-event.relative.y * 0.005)
			spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/4, PI/4)

func apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

func void_check():
	if self.position.y < VOID:
		self.position = Vector3(0, 10, 0)

func apply_jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

func apply_movement():
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = direction.rotated(Vector3.UP, pivot.rotation.y)
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		armature.rotation.y = lerp_angle(armature.rotation.y, atan2(-velocity.x, -velocity.z), LERP_VAL)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

func open_command():
	command_mode = true
	command_input.visible = true
	await get_tree().process_frame
	command_input.grab_focus()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func submit_command():
	var text = command_input.text.strip_edges()
	command_input.text = ""
	command_input.visible = false
	command_mode = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	parse_command(text)

func add_message(message: String):
	message_log.append(message)
	if message_log.size() > MAX_MESSAGES:
		message_log.pop_front()
	texts.text = "\n".join(message_log)

func parse_command(cmd: String):
	var args = cmd.split(" ")
	var base = args[0].to_lower()
	
	if not base.begins_with("/"):
			add_message("Player says: %s" % cmd)
			return
	
	match base:
		"/help":
			add_message("List of commands:")
			add_message("/gate")
		"/gate":
			var open = $"../Buildings/Gates/ArenaGate".toggle()
			if open:
				add_message("* You have opened the gate.")
			else:
				add_message("* You have closed the gate.")
		"/miami":
			var mat = ProceduralSkyMaterial.new()
			mat.sky_horizon_color = Color("#ff4fd8")
			mat.ground_horizon_color = Color("#ff4fd8")
			mat.ground_bottom_color = Color("#1a0033")
			
			var sky = Sky.new()
			sky.sky_material = mat
			
			var env = $"../WorldEnvironment".environment
			env.sky = sky
		"/night":
			var mat = ProceduralSkyMaterial.new()
			mat.sky_horizon_color = Color("#0b1026")
			mat.sky_top_color = Color("#05010f")
			mat.ground_horizon_color = Color("#0a0a1a")
			mat.ground_bottom_color = Color("#000000")
			
			var sky = Sky.new()
			sky.sky_material = mat
			
			var env = $"../WorldEnvironment".environment
			env.sky = sky
			env.ambient_light_energy = 0.15
			env.ambient_light_color = Color("#2a2a3a")
			
			var sun = $"../DirectionalLight3D"
			sun.light_energy = 0.05
			sun.shadow_enabled = false
		_:
			add_message("Unknown command.")
			print("This command does NOT exist: ", args.slice(0))
