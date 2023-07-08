extends CharacterBody2D
class_name Hero

signal path_finished()
signal health_changed(hp)

var health = 100

const SPEED = 100.0

@export var path: Path2D
var _path_index := 0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var navigation_agent_2d = $NavigationAgent2D

func _ready() -> void:
	animated_sprite_2d.speed_scale = 2
	
	$Line2D.add_point(global_position)
	set_physics_process(false)
	nav_setup.call_deferred()

func nav_setup():
	await get_tree().physics_frame
	var target_position = path.curve.get_point_position(path.curve.point_count - 1)
	navigation_agent_2d.target_position = target_position
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	if navigation_agent_2d.target_position.distance_to(global_position) < 50:
		path_finished.emit()
		set_physics_process(false)
	else:
		var next_position = navigation_agent_2d.get_next_path_position()
		$Line2D.add_point(next_position)
		
		if navigation_agent_2d.is_target_reachable():
			var direction = next_position - global_position
			
			direction = direction.normalized()
			if direction.y > 0:
				animated_sprite_2d.play("fwd")
			else:
				animated_sprite_2d.play("bkd")
			
			velocity = direction * SPEED
			move_and_slide()
		else:
			# if path is blocked (units in the way) and we're at the final position,
			# spin attack until the way is clear
			var final_position = navigation_agent_2d.get_final_position()
			if final_position.distance_to(next_position) < 10:
				print("blocked! spin attack")
		
	
func hit(amount):
	health -= amount
	health_changed.emit(health)
