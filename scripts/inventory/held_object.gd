extends Node3D

@onready var asset = $Asset

var pistol_asset = preload("res://assets/inventory/pistol.blend")
var beer_asset = preload("res://assets/inventory/beer.blend")
var mollete_asset = preload("res://assets/inventory/mollete.blend")

@onready var animation = $AnimationPlayer

var bullet = load("res://scenes/inventory/bullet.tscn")
@onready var weapon_barrel = $RayCast3D

func use(object_name, amount):
	if object_name == "Beer":
		animation.play("drink")
		amount -= 1
	elif object_name == "Mollete":
		animation.play("drink")
		amount -= 1
	
	if amount < 1:
		update_asset(null)
	
	return amount

func update_asset(object_name):
	for child in asset.get_children():
		child.queue_free()

	if object_name == null:
		return

	var new_asset

	if object_name == "Beer":
		new_asset = beer_asset
	elif object_name == "Mollete":
		new_asset = mollete_asset
	elif object_name == "Pistol":
		new_asset = pistol_asset
	else:
		return

	var instance = new_asset.instantiate()
	asset.add_child(instance)

func shoot():
	animation.play("shoot")
	'instance = bullet.instantiate()
	instance.position = weapon_barrel.global_position
	instance.transform.basis = weapon_barrel.global_transform.basis

	get_tree().current_scene.add_child(instance)'
	
	var instance = bullet.instantiate()
	instance.global_transform = weapon_barrel.global_transform
	instance.direction = -weapon_barrel.global_transform.basis.z
	get_tree().current_scene.add_child(instance)
