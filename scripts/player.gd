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

# Inventory.
@onready var inventory_ui = $"../InventoryUI"
const MAX_ITEMS := 5
var inventory_open := false
var inventory: Array[String] = []
var held_item: String = ""
@onready var held_item_asset = $Body/HeldItem
var pistol_asset = preload("res://assets/inventory/pistol.blend")
var beer_asset = preload("res://assets/inventory/beer.blend")
var mollete_asset = preload("res://assets/inventory/mollete.blend")


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_message("Welcome to Antequera Role Play.")
	
	inventory = ["Beer", "Mollete", "Pistol", "", ""]
	held_item = ""

func _physics_process(delta: float):
	if not is_active:
		return
	
	apply_gravity(delta)
	void_check()
	
	if not command_mode and not inventory_open:
		apply_jump()
		apply_movement()
	
	move_and_slide()

func _input(event):
	if command_mode and event.is_action_pressed("enter"):
		submit_command()
		get_viewport().set_input_as_handled()
		return
	if not command_mode and not inventory_open and event.is_action_pressed("text"):
		open_command()
		get_viewport().set_input_as_handled()
		
	if command_mode and event.is_action_pressed("escape"):
		command_input.visible = false
		command_mode = false
		command_input.text = ""
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
func _unhandled_input(event):
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
			add_message("[INVENTORY] /inv /stash /use")
			add_message("/gate")
			add_message("/quit")
		"/quit":
			get_tree().quit()
		"/gate":
			var open = $"../Buildings/Gates/ArenaGate".toggle()
			if open:
				add_message("* You have opened the gate.")
			else:
				add_message("* You have closed the gate.")
		
		# Inventory system.
		"/inv":
			update_inventory_ui()
			open_inventory()
		"/stash":
			if held_item == "":
				add_message("Error: your hands are empty!")
			else:
				add_to_inventory(held_item)
		"/use":
			use_item()
		# Weather.
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

func update_inventory_ui():
	inventory_ui.get_node("Panel/Hand").text = "Hand: " + (held_item if held_item != "" else "[empty]")
	for i in range(5):
		var slot = inventory_ui.get_node("Panel/Slot%d" % (i + 1))
		if i < inventory.size() and inventory[i] != "":
			slot.text = inventory[i]
		else:
			slot.text = "[empty]"

func open_inventory():
	inventory_open = true
	inventory_ui.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func close_inventory():
	inventory_open = false
	inventory_ui.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func add_to_inventory(hand_item: String) -> bool:
	for i in range(inventory.size()):
		if inventory[i] == "":
			inventory[i] = hand_item
			add_message("* You stash %s in the inventory." % held_item)
			held_item = ""
			update_held_item_visual()
			return true
	add_message("Error: your inventory is full.")
	return false

func try_equip(index: int):
	if held_item != "":
		add_message("Error: your hands are busy!")
		return
	if inventory[index] == "":
		add_message("Error: that slot is empty!")
		return
	take_from_inventory(index)

func take_from_inventory(index: int):
	held_item = inventory[index]
	inventory[index] = ""
	add_message("* You take %s from slot %d." % [held_item, index+1])
	update_held_item_visual()
	close_inventory()

func update_held_item_visual():
	for child in held_item_asset.get_children():
		child.queue_free()
		
	var item_asset = null
		
	match held_item:
		"Pistol":
			item_asset = pistol_asset
		"Beer":
			item_asset = beer_asset
		"Mollete":
			item_asset = mollete_asset
	if item_asset != null:
		var item_instance = item_asset.instantiate()
		held_item_asset.add_child(item_instance)

func use_item():
	match held_item:
		"Beer":
			add_message("You drink beer.")
			held_item = ""
		"Mollete":
			add_message("You eat a mollete.")
			held_item = ""
			
		"Pistol":
			add_message("Bang!")
	update_held_item_visual()
