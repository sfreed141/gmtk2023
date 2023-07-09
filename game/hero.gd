extends CharacterBody2D
class_name Hero

signal path_finished
signal health_changed(hp)
signal xp_changed(xp)

var health = 100
const required_xp = [100, 300, 600, 1000, 1500]  # this is total xp required, not xp required per level
const SPEED = 100.0
const ATTACK_RANGE = 15

var level = 1
var xp = 0: set = set_xp
var display_xp = 0
var next_lv_xp = 0
var attack_damage = 20  # TODO increase on level up

@export var path: Path2D
var _path_index := 0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var navigation_agent_2d = $NavigationAgent2D

var target_unit: Node2D

func set_xp(a_value):
	xp = a_value
	if level > 1:
		display_xp = xp - required_xp[level - 2]
	else:
		display_xp = xp
	xp_changed.emit(xp, display_xp)

func _ready() -> void:
	animated_sprite_2d.speed_scale = 2

	$Line2D.add_point(global_position)
	set_physics_process(false)
	nav_setup.call_deferred()


func apply_level_stats():
	const health_per_level = [100, 100, 100, 100, 100]
	const damage_per_level = [20, 30, 40, 50, 60]
	level = 1
	while level - 1 < required_xp.size() and xp >= required_xp[level - 1]:
		level += 1
	
	if level > 1:
		display_xp = xp - required_xp[level - 2]
		next_lv_xp = required_xp[level - 1] - required_xp[level - 2]
	else:
		display_xp = xp
		next_lv_xp = required_xp[level - 1]
	level = min(required_xp.size(), level)
	health = health_per_level[level - 1]
	attack_damage = damage_per_level[level - 1]


func nav_setup():
	await get_tree().physics_frame
	var target_position = path.curve.get_point_position(path.curve.point_count - 1)
	navigation_agent_2d.target_position = target_position
	set_physics_process(true)


func do_attack():
	print("WACK")
	target_unit.hit(attack_damage)
	$AttackSfx.play()
	if target_unit.health <= 0:
		xp += target_unit.xp_granted
		target_unit.queue_free()
		target_unit = null


func _physics_process(delta: float) -> void:
	if $AnimationPlayer.is_playing():
		return

	if target_unit:
		if target_unit.global_position.distance_to(global_position) < ATTACK_RANGE:
			# todo attack. on defeat, gain xp and clear target_unit
			$AnimationPlayer.play("attack")
		else:
			move_towards(target_unit.global_position)
	elif navigation_agent_2d.target_position.distance_to(global_position) < 50:
		path_finished.emit()
		set_physics_process(false)
	else:
		var next_position = navigation_agent_2d.get_next_path_position()
		$Line2D.add_point(next_position)

		if navigation_agent_2d.is_target_reachable():
			move_towards(next_position)
		else:
			# if path is blocked (units in the way) and we're at the final position,
			# spin attack until the way is clear
			var final_position = navigation_agent_2d.get_final_position()
			if final_position.distance_to(next_position) < 10:
				print("blocked! spin attack")


func move_towards(next_position):
	var direction = next_position - global_position

	direction = direction.normalized()
	if direction.y > 0:
		animated_sprite_2d.play("fwd")
	else:
		animated_sprite_2d.play("bkd")

	velocity = direction * SPEED
	move_and_slide()


func hit(amount):
	var rng = randi_range(-2, 2)
	health -= amount * (1 + 0.2 * rng)
	if health <= 0:
		$DeathOofSfx.play()
	else:
		$OofSfx.play()
	health_changed.emit(health)


func _on_aggro_range_area_entered(area):
	print("target acquired")
	target_unit = area.owner
