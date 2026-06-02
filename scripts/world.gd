extends Node3D

func _ready():
	pass
	
func set_sunset():
	var mat = ProceduralSkyMaterial.new()
	mat.sky_horizon_color = Color("#ff4fd8")
	mat.ground_horizon_color = Color("#ff4fd8")
	mat.ground_bottom_color = Color("#1a0033")
	
	var sky = Sky.new()
	sky.sky_material = mat
	
	var env = $"WorldEnvironment".environment
	env.sky = sky

func set_night():
	var mat = ProceduralSkyMaterial.new()
	mat.sky_horizon_color = Color("#0b1026")
	mat.sky_top_color = Color("#05010f")
	mat.ground_horizon_color = Color("#0a0a1a")
	mat.ground_bottom_color = Color("#000000")
	
	var sky = Sky.new()
	sky.sky_material = mat
	
	var env = $"/WorldEnvironment".environment
	env.sky = sky
	env.ambient_light_energy = 0.15
	env.ambient_light_color = Color("#2a2a3a")
	
	var sun = $"/DirectionalLight3D"
	sun.light_energy = 0.0
	sun.shadow_enabled = false
