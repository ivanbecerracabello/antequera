extends Control

var current_username = ""
var mode = "username"  # "username", "login", "register"

func _ready():
	$Panel/VBoxContainer/PasswordInput.visible = false

func _on_continue_button_pressed() -> void:
	var username = $Panel/VBoxContainer/UsernameInput.text
	var password_input = $Panel/VBoxContainer/PasswordInput

	# -------------------------
	# STEP 1: Username phase
	# -------------------------
	if mode == "username":
		if username == "":
			return

		current_username = username

		if UserManager.users.has(username):
			mode = "login"
			password_input.visible = true
			print("User exists → enter password")
		else:
			mode = "register"
			password_input.visible = true
			print("New user → create password")

		return

	# -------------------------
	# STEP 2: Login / Register phase
	# -------------------------
	var password = password_input.text

	if password == "":
		return

	# REGISTER
	if mode == "register":
		UserManager.users[current_username] = {
			"password": password
		}
		UserManager.save_users()

		print("User registered!")

	# LOGIN
	elif mode == "login":
		var stored_password = UserManager.users[current_username]["password"]

		if password != stored_password:
			print("Wrong password")
			return

		print("Login successful!")

	# GO TO GAME
	get_tree().change_scene_to_file("res://scenes/world.tscn")
