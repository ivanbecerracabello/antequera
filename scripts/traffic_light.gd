extends Node3D

enum Type { MAIN, SECONDARY }
enum Phase { GREEN, AMBER, RED, ALL_RED }

@export var type: Type = Type.MAIN

var phase := Phase.GREEN
var phase_elapsed := 0.0

@onready var red: MeshInstance3D = $Red
@onready var amber: MeshInstance3D = $Amber
@onready var green: MeshInstance3D = $Green


func _ready() -> void:
	if type == Type.SECONDARY:
		phase = Phase.RED

	_apply_phase()


func _process(delta: float) -> void:
	phase_elapsed += delta

	if phase_elapsed >= _phase_duration():
		phase_elapsed = 0.0
		phase = ((phase + 1) % 4) as Phase
		_apply_phase()


func _phase_duration() -> float:
	match type:
		Type.MAIN:
			match phase:
				Phase.GREEN:
					return 10.0
				Phase.AMBER:
					return 2.0
				Phase.RED:
					return 5.0
				Phase.ALL_RED:
					return 2.0

		Type.SECONDARY:
			match phase:
				Phase.GREEN:
					return 5.0
				Phase.AMBER:
					return 2.0
				Phase.RED:
					return 10.0
				Phase.ALL_RED:
					return 2.0

	return 10.0


func _apply_phase() -> void:
	green.visible = phase == Phase.GREEN
	amber.visible = phase == Phase.AMBER
	red.visible = phase == Phase.RED or phase == Phase.ALL_RED
