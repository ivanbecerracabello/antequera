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

# Inventory UI.
@onready var inventory_ui = $"../InventoryUI"
var inventory_open := false

# Inventory.
@onready var held_item = $Body/HeldObject
var inventory: Array = [null, null, null, null, null]
var held_item_name: String = ""
var amount: int = 0
#@onready var held_item_asset = $Body/HeldItem


# Aiming with weapons.
var aiming := false
var aim_sensitivity := 0.003
var aim_offset := Vector3(0.4, 0.0, 0.0)
var default_offset := Vector3(0.0, 0.0, 0.0)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_message("Welcome to Antequera Role Play.")
	
	inventory = [
		{ "name": "Beer", "amount": 5 },
		{ "name": "Mollete", "amount": 5 },
		{ "name": "Pistol", "amount": 7},
		null, null
	]
	held_item_name = ""

func _physics_process(delta: float):
	if not is_active:
		return
	
	apply_gravity(delta)
	void_check()
	
	if not command_mode and not inventory_open:
		apply_jump()
		apply_movement()
	
	move_and_slide()
	
	if aiming:
		spring_arm.position = spring_arm.position.lerp(aim_offset, 10 * delta)
	else:
		spring_arm.position = spring_arm.position.lerp(default_offset, 10 * delta)

func _input(event):
	if event.is_action_pressed("enter") and command_mode:
		submit_command()
		get_viewport().set_input_as_handled()
		return
	
	if event.is_action_pressed("text") and not command_mode and not inventory_open:
		open_command()
		
	if event.is_action_pressed("escape") and command_mode:
		command_input.visible = false
		command_mode = false
		command_input.text = ""
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event.is_action_pressed("escape") and inventory_open:
		close_inventory()
	
	if event.is_action_pressed("right_click") and held_item_name == "Pistol":
		aiming = true
		armature.rotation.y = pivot.rotation.y
		held_item.rotation.x = -spring_arm.rotation.x
	if event.is_action_released("right_click") and aiming:
		aiming = false
		held_item.rotation_degrees.x = 90
	if event.is_action_pressed("left_click") and held_item_name == "Pistol":
		held_item.shoot()
		
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			spring_arm.rotate_x(-event.relative.y * 0.005)
			spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/4, PI/4)
			pivot.rotate_y(-event.relative.x * 0.005)
			if not aiming:
				pass
			else:
				# Rotate body horizontally when aiming:
				armature.rotate_y(-event.relative.x * 0.005)
				# Rotate weapon vertically:
				held_item.rotation.x = -spring_arm.rotation.x

func apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

func void_check():
	if self.position.y < VOID:
		self.position = Vector3(0, 10, 0)

func apply_jump():
	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = JUMP_VELOCITY

func apply_movement():
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = direction.rotated(Vector3.UP, pivot.rotation.y)
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		if not aiming:
			armature.rotation.y = lerp_angle(armature.rotation.y, atan2(
				-velocity.x,
				-velocity.z),
				LERP_VAL
			)
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
			if held_item_name != "":
				add_to_inventory(held_item_name)
			else:
				add_message("Error: your hands are empty!")
		"/use":
			if held_item_name == "":
				add_message("Error: your hands are empty!")
			else:
				amount = held_item.use(held_item_name, amount)
				if amount < 1:
					held_item_name = ""
		"/test":
			pass
		_:
			add_message("Unknown command.")
			print("This command does NOT exist: ", args.slice(0))

func update_inventory_ui():
	if held_item_name != "":
		inventory_ui.get_node("Panel/Hand").text = "Hand: %s (%d)" % [ held_item_name, amount ]
	
	for i in range(5):
		var slot = inventory_ui.get_node("Panel/Slot%d" % (i + 1))
		if i < inventory.size():
			var item = inventory[i]
			if item != null:
				slot.text = "%s (%d)" % [item["name"], item["amount"]]
			else:
				slot.text = "     "
		else:
			slot.text = " "

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
		if inventory[i] == null:
			inventory[i] = { "name": hand_item, "amount": amount }
			add_message("* You stash %s in the inventory." % held_item_name)
			held_item_name = ""
			held_item.update_asset(null)
			return true
	add_message("Error: your inventory is full.")
	return false

func try_equip(index: int):
	if held_item_name != "":
		add_message("Error: your hands are busy!")
		return
	if inventory[index] == null:
		add_message("Error: that slot is empty!")
		return
	take_from_inventory(index)

func take_from_inventory(index: int):
	var item = inventory[index]
	held_item_name = item["name"]
	amount = item["amount"]
	inventory[index] = null
	
	add_message("* You take %s from slot %d." % [held_item_name, index+1])
	held_item.update_asset(held_item_name)
	close_inventory()
