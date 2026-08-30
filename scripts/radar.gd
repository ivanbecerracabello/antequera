extends CanvasLayer

# Radar configuration - set these with your proportions
@export var radar_size := 256  # Size of the radar circle in pixels
@export var map_width := 2000.0  # Total map width in pixels
@export var map_height := 1000.0  # Total map height in pixels
@export var game_scale := 1.0  # Game units per pixel (e.g., 0.5 = 2 pixels per game unit)

# Game world coordinates that correspond to map corners
# Calibrated: image pixel 550,460 = world -24,-24
# Scale: 8 meters = 20 pixels (2.5 pixels per meter)
@export var world_min_x := -244.0  # Game X coordinate at pixel 0 of map
@export var world_max_x := 556.0   # Game X coordinate at pixel 2000 of map
@export var world_min_z := -208.0  # Game Z coordinate at pixel 0 of map
@export var world_max_z := 192.0   # Game Z coordinate at pixel 1000 of map

@onready var texture_rect = $Control/MapContainer/TextureRect
@onready var map_container = $Control/MapContainer
@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	# Ensure the TextureRect uses the map image
	if texture_rect and not texture_rect.texture:
		texture_rect.texture = load("res://miscellaneous/antequeland.png")
	
	if texture_rect:
		print("Radar TextureRect found: ", texture_rect)
		print("Radar TextureRect texture: ", texture_rect.texture)
		print("Radar TextureRect material: ", texture_rect.material)
	else:
		print("ERROR: TextureRect not found!")

func _process(_delta):
	if not player:
		player = get_tree().get_first_node_in_group("player")
		return
	
	update_radar_position()

func update_radar_position():
	"""Calculate and update the texture position based on player position"""
	if not map_container:
		return
		
	var player_pos = player.global_position
	var player_x = player_pos.x
	var player_z = player_pos.z
	
	# Convert game world coordinates to map pixel coordinates
	var map_x = world_to_map_x(player_x)
	var map_z = world_to_map_z(player_z)
	
	# Calculate offset to keep player centered in radar
	# The radar displays a portion of the map, centered on the player
	var offset_x = map_x - (radar_size / 2.0)
	var offset_z = map_z - (radar_size / 2.0)
	
	# Apply the offset to the MapContainer position
	# Negative because moving the map opposite to center the player
	map_container.position = Vector2(-offset_x, -offset_z)

func world_to_map_x(world_x: float) -> float:
	"""Convert game world X coordinate to map pixel X coordinate"""
	var normalized = (world_x - world_min_x) / (world_max_x - world_min_x)
	return clamp(normalized * map_width, 0, map_width)

func world_to_map_z(world_z: float) -> float:
	"""Convert game world Z coordinate to map pixel Z coordinate"""
	var normalized = (world_z - world_min_z) / (world_max_z - world_min_z)
	return clamp(normalized * map_height, 0, map_height)

func set_calibration(map_corner_1: Vector2i, world_pos_1: Vector2, map_corner_2: Vector2i, world_pos_2: Vector2):
	"""
	Calibrate the radar with two known points
	map_corner_1: pixel position on map image
	world_pos_1: corresponding world position (Vector2 with x and z)
	map_corner_2: another pixel position on map image
	world_pos_2: corresponding world position
	"""
	world_min_x = world_pos_1.x
	world_min_z = world_pos_1.y
	world_max_x = world_pos_2.x
	world_max_z = world_pos_2.y
	
	map_width = float(map_corner_2.x - map_corner_1.x)
	map_height = float(map_corner_2.y - map_corner_1.y)
