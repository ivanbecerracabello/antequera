extends Node

var users = {}

const SAVE_PATH = "user://users.json"
# /home/ivanbecerra/.local/share/godot/app_userdata/Antequera

func _ready():
	load_users()

func save_users():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(users))

func load_users():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var result = JSON.parse_string(file.get_as_text())

		if typeof(result) == TYPE_DICTIONARY:
			users = result
		else:
			users = {}
