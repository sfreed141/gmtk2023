extends Unit

var attack_target: Node2D
const ATTACK_COOLDOWN = 1
var attack_cooldown_timer = 0

const PROJECTILE_SPEED = 100
@onready var projectile = $MagicTurretProjectile

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	projectile.visible = false

func _physics_process(delta):
	if projectile.visible:
		var direction = (attack_target.global_position - projectile.global_position).normalized()
		projectile.global_position += delta * direction * PROJECTILE_SPEED
		var bodies = projectile.get_node("HitBox").get_overlapping_bodies()
		if not bodies.is_empty():
			var body = bodies[0]
			assert(body == attack_target)	# pretty sure we'll only ever have the hero for both here
			body.hit(damage)
			projectile.visible = false
	elif attack_target:
		attack_cooldown_timer -= delta
		if attack_cooldown_timer <= 0:
			$AnimatedSprite2D.play("attack")
			projectile.global_position = global_position
			projectile.visible = true
			$AudioStreamPlayer.play()
			attack_cooldown_timer = ATTACK_COOLDOWN

func _on_attack_range_body_entered(body):
	attack_target = body

