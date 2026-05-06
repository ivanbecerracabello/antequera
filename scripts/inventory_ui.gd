extends CanvasLayer

@onready var player = $"../Player"

func _ready():
	$Panel/Slot1.pressed.connect(func(): player.try_equip(0))
	$Panel/Slot2.pressed.connect(func(): player.try_equip(1))
