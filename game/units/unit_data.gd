extends Resource
class_name UnitData

@export var name: String
@export var description: String
@export var texture: Texture2D
@export var unit_scene: PackedScene
@export var cost: int

# stats per level
@export var health: Array[int]
@export var xp_granted: Array[int]
@export var damage: Array[int]
