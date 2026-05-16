extends Node3D

@onready var asset = $Asset

var pistol_asset = preload("res://assets/inventory/pistol.blend")
var beer_asset = preload("res://assets/inventory/beer.blend")
var mollete_asset = preload("res://assets/inventory/mollete.blend")

@onready var animation = $AnimationPlayer

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
