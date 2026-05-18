extends Node3D

# Switch between Player and Car.
@onready var player = $Player
@onready var car = $Car
@onready var player_camera = $Player/Pivot/SpringArm3D/Camera3D
@onready var car_camera = $Car/TwistPivot/PitchPivot/Camera3D
var controlling_car := false

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
