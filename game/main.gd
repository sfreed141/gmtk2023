extends Node

@onready var main_menu: PanelContainer = $UI/MainMenu
@onready var hud: Control = $UI/HUD
@onready var round_over_label: Label = $UI/HUD/RoundOverLabel
@onready var current_round_label = $UI/HUD/CurrentRoundLabel
@onready var hero_level_label = $UI/HUD/HeroLevelLabel

@onready var world: Node2D = $World

const PLAYER_SCENE = preload("res://game/player.tscn")
@onready var healthbar: ProgressBar = $UI/HUD/HPBar
@onready var xpbar: ProgressBar = $UI/HUD/XPBar

const UNIT_SCENE = preload("res://game/units/unit.tscn")
const PLAYER_SPAWN_GROUPNAME := "player_spawn"
const HERO_GROUPNAME := "hero"

const FINAL_LEVEL = 5
var hero: Hero
var hero_xp := 0  # used to persist the xp between rounds
var level: Node
var round_level = 1

@export var startup_level: PackedScene
@export var start_at_main_menu := true


func _ready():
	if start_at_main_menu:
		world.hide()
		hud.hide()
		main_menu.show()
	else:
		start_game()


func _init_hp_bar():
	healthbar.max_value = get_tree().get_first_node_in_group(HERO_GROUPNAME).health
	healthbar.value = get_tree().get_first_node_in_group(HERO_GROUPNAME).health

func _init_xp_bar():
	xpbar.max_value = get_tree().get_first_node_in_group(HERO_GROUPNAME).next_lv_xp
	xpbar.value = get_tree().get_first_node_in_group(HERO_GROUPNAME).xp


func start_game():
	main_menu.hide()
	world.show()
	hud.show()

	update_round_label()
	current_round_label.show()

	if startup_level:
		level = startup_level.instantiate()
		level.name = "level"
		world.add_child(level, true)

		if not world.has_node("player"):
			var player = PLAYER_SCENE.instantiate()
			player.name = "player"
			player.visible = false
			var player_spawn: Node2D = get_tree().get_first_node_in_group(PLAYER_SPAWN_GROUPNAME)
			if player_spawn:
				player.global_position = player_spawn.global_position
			else:
				push_error(
					(
						"Level '%s' doesn't have a node in group '%s'"
						% [startup_level.resource_name, PLAYER_SPAWN_GROUPNAME]
					)
				)
			world.add_child(player, true)
		_init_hp_bar()
		_init_xp_bar()
		hero = get_tree().get_first_node_in_group(HERO_GROUPNAME)
		hero.xp = hero_xp
		print("hero xp: %d" % hero_xp)
		hero.apply_level_stats()
		update_hero_label()
		hero.path_finished.connect(_on_hero_path_finished)
		hero.health_changed.connect(_on_hero_health_changed)
		hero.xp_changed.connect(_on_hero_xp_changed)
	else:
		push_error("No startup_level specified!")


func _on_hero_path_finished():
	end_round(true)


func update_round_label():
	current_round_label.text = "Round %d" % round_level


func update_hero_label():
	hero_level_label.text = "Hero Level: %d" % hero.level


func end_round(success: bool):
	if success:
		round_level += 1
		hero_xp = hero.xp
		if round_level == FINAL_LEVEL:
			round_over_label.text = "YOU WIN!"
			round_level = 1
			hero_xp = 0
		else:
			round_over_label.text = "Dungeon Cleared!"
	else:
		round_over_label.text = "Hero wasn't strong enough :("
		round_level = 1
		hero_xp = 0


	round_over_label.show()
	get_tree().paused = true
	await get_tree().create_timer(3).timeout
	get_tree().paused = false
	round_over_label.hide()

	for c in world.get_children():
		c.free()

	# TODO goto next level or back to level0 depending on success
	start_game.call_deferred()


func _on_hero_health_changed(hp):
	print("Hero has %d health" % hp)
	healthbar.value = hp
	if hp <= 0:
		end_round(false)

func _on_hero_xp_changed(xp):
	print("Hero has %d xp" % xp)
	xpbar.value = xp
	if xp < 0:
		print("Fuck do I know")

func _on_unit_bar_place_unit(unit_data: UnitData, unit_local_position) -> void:
	var scene = unit_data.unit_scene if unit_data.unit_scene else UNIT_SCENE
	var unit = scene.instantiate()
	unit.unit_level = round_level
	unit.unit_data = unit_data
	unit.position = unit_local_position
	world.add_child(unit)


func _on_main_menu_start_button_pressed() -> void:
	start_game()


func _on_main_menu_quit_button_pressed() -> void:
	get_tree().quit()
