extends CharacterBody2D
class_name Hero

signal path_finished()

const SPEED = 100.0

@export var path: Path2D
var _path_index := 0

func _physics_process(delta: float) -> void:
	var direction = path.curve.get_point_position(_path_index) - global_position
	if direction.length() < 10:
		_path_index += 1
		if _path_index == path.curve.point_count:
			path_finished.emit()
			set_physics_process(false)
	direction = direction.normalized()
	velocity = direction * SPEED
	move_and_slide()
	