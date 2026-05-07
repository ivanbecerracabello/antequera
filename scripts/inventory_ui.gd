extends CanvasLayer

@onready var player = $"../Player"

func _ready():
	$Panel/Slot1.pressed.connect(func(): player.try_equip(0))
	$Panel/Slot2.pressed.connect(func(): player.try_equip(1))
	$Panel/Slot3.pressed.connect(func(): player.try_equip(2))
	$Panel/Slot4.pressed.connect(func(): player.try_equip(3))
	$Panel/Slot5.pressed.connect(func(): player.try_equip(4))
	$Panel/Close.pressed.connect(func(): player.close_inventory())
