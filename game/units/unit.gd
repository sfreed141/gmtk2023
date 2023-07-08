extends Node2D
class_name Unit

@export var unit_data: UnitData:
	set = set_unit_data

@onready var sprite_2d: Sprite2D = $Sprite2D

func set_unit_data(value: UnitData):
	unit_data = value
	if unit_data and sprite_2d:
		sprite_2d.texture = unit_data.texture

func _ready() -> void:
	set_unit_data(unit_data)
