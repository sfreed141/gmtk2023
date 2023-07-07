extends CharacterBody2D
class_name Player

const SPEED = 300.0

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction.normalized() * SPEED
	move_and_slide()
