extends Node3D

# Switch between Player and Car.
@onready var player = $Player
@onready var car = $Car
@onready var player_camera = $Player/Pivot/SpringArm3D/Camera3D
@onready var car_camera = $Car/TwistPivot/PitchPivot/Camera3D
var controlling_car := false

func _ready() -> void:
	var mat = ProceduralSkyMaterial.new()
	mat.sky_horizon_color = Color("#0b1026")
	mat.sky_top_color = Color("#05010f")
	mat.ground_horizon_color = Color("#0a0a1a")
	mat.ground_bottom_color = Color("#000000")
	
	var sky = Sky.new()
	sky.sky_material = mat
	
	var env = $"WorldEnvironment".environment
	env.sky = sky
	env.ambient_light_energy = 0.15
	env.ambient_light_color = Color("#2a2a3a")
	
	var sun = $"DirectionalLight3D"
	sun.light_energy = 0.05
	sun.shadow_enabled = false

func _input(event):
	if player.command_mode:
		return
	if event.is_action_pressed("enter"):
		controlling_car = !controlling_car
		
		if controlling_car:
			player.is_active = false
			player.visible = false
			player_camera.current = false
			
			car.is_active = true
			car_camera.current = true
		else:
			player.is_active = true
			player.visible = true
			player_camera.current = true
			
			car.is_active = false
			car_camera.current = false
