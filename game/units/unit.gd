extends Node2D
class_name Unit

# main should set unit_level
@export_range(1, 5) var unit_level: int = 1
var health
var xp_granted
var damage

@export var unit_data: UnitData:
	set = set_unit_data

var sprite_2d: Sprite2D

func set_unit_data(value: UnitData):
	unit_data = value
	if unit_data and sprite_2d:
		sprite_2d.texture = unit_data.texture
		
	health = unit_data.health[min(unit_level, unit_data.health.size()) - 1]
	xp_granted = unit_data.xp_granted[min(unit_level, unit_data.xp_granted.size()) - 1]
	damage = unit_data.damage[min(unit_level, unit_data.damage.size()) - 1]


func _ready() -> void:
	if not sprite_2d:
		sprite_2d = $Sprite2D
		assert(sprite_2d)
	set_unit_data(unit_data)


func hit(amount):
	health -= amount
