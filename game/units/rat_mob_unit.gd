extends Unit

const ATTACK_RANGE = 15
const SPEED = 50

var target: Node2D
@onready var animation_player = $AnimationPlayer
@onready var static_body_2d = $Pivot/StaticBody2D

func _ready():
	sprite_2d = $Pivot/Sprite2D
	super._ready()

func do_attack():
	target.hit(damage)

func _physics_process(delta):
	if target and not animation_player.is_playing():
		var direction = target.global_position - global_position
		if direction.length() < ATTACK_RANGE:
			animation_player.play("attack")
		else:
			direction = direction.normalized()
			var motion = delta * direction * SPEED
			var collision = static_body_2d.move_and_collide(motion, true)
			if not collision:
				global_position += motion
		
func _on_detection_range_body_entered(body):
	target = body
