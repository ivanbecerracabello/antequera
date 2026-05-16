extends Area3D

const SPEED = 40.0
var direction: Vector3

func _ready():
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	global_position -= direction * SPEED * delta

func _on_body_entered(body):
	print("HIT:", body.name)
	queue_free()
