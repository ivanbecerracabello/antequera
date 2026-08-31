extends CanvasLayer

@export var radar_size := 180
@export var map_width := 2000.0
@export var map_height := 1000.0

@export var game_scale := 1.0

@export var world_min_x := -244.0
@export var world_max_x := 556.0
@export var world_min_z := -208.0
@export var world_max_z := 192.0

@onready var texture_rect = $SubViewport/MapContainer/TextureRect
@onready var map_container = $SubViewport/MapContainer
@onready var player = get_tree().get_first_node_in_group("player")


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

	var radar_center = Vector2(radar_size * 0.5, radar_size * 0.5)
	var map_center = Vector2(map_x, map_z)

	map_container.position = radar_center - map_center


func world_to_map_x(world_x: float) -> float:
	var normalized = (world_x - world_min_x) / (world_max_x - world_min_x)
	return clamp(normalized * map_width, 0, map_width)


func world_to_map_z(world_z: float) -> float:
	var normalized = (world_z - world_min_z) / (world_max_z - world_min_z)
	return clamp(normalized * map_height, 0, map_height)
