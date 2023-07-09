extends Unit


const ROTATION_SPEED_SCALE = 3

@onready var pivot: Node2D = $Pivot

func _ready() -> void:
	sprite_2d = $Pivot/Sprite2D
	super._ready()

func _process(delta: float) -> void:
	pivot.rotate(delta * ROTATION_SPEED_SCALE)


func _on_hurt_box_body_entered(body: Node2D) -> void:
	if body.has_method("hit"):
		body.hit(damage)
