extends CanvasLayer

@export var radar_size := 180
@export var map_width := 2000.0
@export var map_height := 1000.0

@export var radar_zoom := 0.5

@export var game_scale := 1.0

@export var world_min_x := -244.0
@export var world_max_x := 556.0
@export var world_min_z := -208.0
@export var world_max_z := 192.0

@onready var texture_rect = $SubViewport/MapContainer/TextureRect
@onready var map_container = $SubViewport/MapContainer

@onready var player = get_tree().get_first_node_in_group("player")
@onready var player_pivot = player.get_node("Pivot") if player else null

func _process(_delta):
	if not player:
		player = get_tree().get_first_node_in_group("player")
		return
	
	update_radar_position()

func update_radar_position():
	if not map_container:
		return

	var player_pos = player.global_position

	var map_x = world_to_map_x(player_pos.x)
	var map_z = world_to_map_z(player_pos.z)

	map_container.scale = Vector2(radar_zoom, radar_zoom)

	# Player position inside the scaled map
	var player_map_pos = Vector2(
		map_x * radar_zoom,
		map_z * radar_zoom
	)

	# Radar center
	var radar_center = Vector2(
		radar_size / 2.0,
		radar_size / 2.0
	)

	# Rotate the map according to the camera/pivot
	var rotation = player_pivot.global_rotation.y
	map_container.rotation = rotation

	# Position the map so the player remains at the radar center
	var rotated_player_pos = player_map_pos.rotated(rotation)
	map_container.position = radar_center - rotated_player_pos

func world_to_map_x(world_x: float) -> float:
	var normalized = (world_x - world_min_x) / (world_max_x - world_min_x)
	return clamp(normalized * map_width, 0, map_width)


func world_to_map_z(world_z: float) -> float:
	var normalized = (world_z - world_min_z) / (world_max_z - world_min_z)
	return clamp(normalized * map_height, 0, map_height)
