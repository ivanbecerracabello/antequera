extends Node3D

const CHUNK_SIZE := 64.0
const ACTIVE_CHUNK_DISTANCE := 1
const GRID_CELL_1_ORIGIN := Vector2(-64.0, 0.0)
const CHUNK_GRID_POSITIONS := {
	"Paseo": Vector2i(1, 1),
	"Arch": Vector2i(2, 1),
	"Estepa": Vector2i(3, 1),
}

@onready var chunks: Node3D = $Chunks

var player: Node3D
var chunk_nodes: Array[Node3D] = []
var last_player_chunk := Vector2i.ZERO
var has_last_player_chunk := false

func _ready():
	var player_node = get_tree().get_first_node_in_group("player")
	if player_node == null:
		push_error("World chunk streaming requires a node in the 'player' group.")
		set_physics_process(false)
		return

	player = player_node as Node3D
	if player == null:
		push_error("The node in the 'player' group must be a Node3D.")
		set_physics_process(false)
		return

	for chunk_name in CHUNK_GRID_POSITIONS:
		var chunk: Node3D = chunks.get_node_or_null(NodePath(str(chunk_name))) as Node3D
		if chunk == null:
			push_error("Chunk '%s' is missing or is not a Node3D." % chunk_name)
			continue
		chunk_nodes.append(chunk)

	update_chunk_visibility()

func _physics_process(_delta: float) -> void:
	update_chunk_visibility()

func update_chunk_visibility() -> void:
	var player_chunk := get_player_grid_coordinates(player.global_position)
	if has_last_player_chunk and player_chunk == last_player_chunk:
		return

	last_player_chunk = player_chunk
	has_last_player_chunk = true

	for chunk in chunk_nodes:
		var chunk_coordinates: Vector2i = CHUNK_GRID_POSITIONS[str(chunk.name)]
		var in_range: bool = (
			abs(chunk_coordinates.x - player_chunk.x) <= ACTIVE_CHUNK_DISTANCE
			and abs(chunk_coordinates.y - player_chunk.y) <= ACTIVE_CHUNK_DISTANCE
		)
		chunk.visible = in_range
		set_chunk_collisions_enabled(chunk, in_range)

func get_player_grid_coordinates(world_position: Vector3) -> Vector2i:
	return Vector2i(
		floori((world_position.x - GRID_CELL_1_ORIGIN.x) / CHUNK_SIZE) + 1,
		floori((world_position.z - GRID_CELL_1_ORIGIN.y) / CHUNK_SIZE) + 1
	)

func set_chunk_collisions_enabled(node: Node, enabled: bool) -> void:
	if node is CollisionShape3D:
		node.disabled = not enabled
	elif node is CollisionPolygon3D:
		node.disabled = not enabled

	for child in node.get_children():
		set_chunk_collisions_enabled(child, enabled)

func set_sunset():
	var mat = ProceduralSkyMaterial.new()
	mat.sky_horizon_color = Color("#ff4fd8")
	mat.ground_horizon_color = Color("#ff4fd8")
	mat.ground_bottom_color = Color("#1a0033")
	
	var sky = Sky.new()
	sky.sky_material = mat
	
	var env = $WorldEnvironment.environment
	env.sky = sky

func set_night():
	var mat = ProceduralSkyMaterial.new()
	mat.sky_horizon_color = Color("#0b1026")
	mat.sky_top_color = Color("#05010f")
	mat.ground_horizon_color = Color("#0a0a1a")
	mat.ground_bottom_color = Color("#000000")
	
	var sky = Sky.new()
	sky.sky_material = mat
	
	var env = $WorldEnvironment.environment
	env.sky = sky
	env.ambient_light_energy = 0.15
	env.ambient_light_color = Color("#2a2a3a")
	
	var sun = $DirectionalLight3D
	sun.light_energy = 0.0
	sun.shadow_enabled = false
