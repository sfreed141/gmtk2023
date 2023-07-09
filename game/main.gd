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

const LEVELS = [
	preload("res://game/level0.tscn"),
	preload("res://game/level_2.tscn"),
	preload("res://game/level_1.tscn"),
	preload("res://game/level_3.tscn")
]

var hero: Hero
var hero_xp := 0  # used to persist the xp between rounds
var level: Node
var round_level = 1
const CURRENCY_PER_LEVEL = [ 100, 200, 300, 400, 500 ]
const CHEAPEST_UNIT_COST = 25
var currency

@export var startup_level: PackedScene
@export var start_at_main_menu := true


func _ready():
	if start_at_main_menu:
		world.hide()
		hud.hide()
		main_menu.show()
		$MainMenuMusic.play()
	else:
		start_game()


func _init_hp_bar():
	healthbar.max_value = get_tree().get_first_node_in_group(HERO_GROUPNAME).health
	healthbar.value = get_tree().get_first_node_in_group(HERO_GROUPNAME).health

func _init_xp_bar():
	xpbar.max_value = get_tree().get_first_node_in_group(HERO_GROUPNAME).next_lv_xp
	xpbar.value = get_tree().get_first_node_in_group(HERO_GROUPNAME).display_xp


func start_game():
	$MainMenuMusic.stop()
	$BackgroundMusic.stop()
	$BackgroundMusic2.stop()
	$SuccessJingle.stop()
	$FailJingle.stop()
	if round_level <= 2:
		$BackgroundMusic.play()
	else:
		$BackgroundMusic2.play()
	main_menu.hide()
	world.show()
	hud.show()

	update_round_label()
	current_round_label.show()

	startup_level = LEVELS[round_level - 1]

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

		hero = get_tree().get_first_node_in_group(HERO_GROUPNAME)
		hero.xp = hero_xp
		print("hero xp: %d" % hero_xp)
		hero.apply_level_stats()
		print("hero next_lv_xp %d" % hero.next_lv_xp)
		_init_xp_bar()
		update_hero_label()
		hero.path_finished.connect(_on_hero_path_finished)
		hero.health_changed.connect(_on_hero_health_changed)
		hero.xp_changed.connect(_on_hero_xp_changed)
		
		currency = CURRENCY_PER_LEVEL[round_level - 1]
		$UI/HUD/UnitBar.is_broke = false
		update_currency_label()
		
#		refresh_unit_bar()
	else:
		push_error("No startup_level specified!")

func refresh_unit_bar():
	const UNIT_DATA = [
		preload("res://game/units/data/spinny_axe.tres"),
		preload("res://game/units/data/rat_mob.tres"),
		preload("res://game/units/data/magic_turret.tres"),
	]
	
	var unit_bar = $UI/HUD/UnitBar
	var grid_container = $UI/HUD/UnitBar/MarginContainer/GridContainer
	for c in grid_container.get_children():
		c.free()
	
	for unit_data in UNIT_DATA:
		var slot = preload("res://game/units/unit_slot.tscn").instantiate()
		slot.unit_data = unit_data
		# TODO labels for cost, unit stats
		grid_container.add_child(slot)
	
	unit_bar.clear_selected_unit()

func _on_hero_path_finished():
	end_round(true)


func update_round_label():
	current_round_label.text = "Round %d" % round_level


func update_hero_label():
	hero_level_label.text = "Hero Level: %d" % hero.level


func end_round(success: bool):
	$BackgroundMusic.stop()
	$BackgroundMusic2.stop()
	
	var go_to_main_menu = false
	if success:
		$SuccessJingle.play()
		round_level += 1
		hero_xp = hero.xp
		if round_level == LEVELS.size() + 1:
			round_over_label.text = "YOU WIN!"
			round_level = 1
			hero_xp = 0
			go_to_main_menu = true
		else:
			round_over_label.text = "Dungeon Cleared!"
	else:
		$FailJingle.play()
		round_over_label.text = "Hero wasn't strong enough, back to round 1 :("
		round_level = 1
		hero_xp = 0


	round_over_label.show()
#	get_tree().paused = true
	for c in world.get_children():
		c.set_process(false)
		c.set_physics_process(false)
	await get_tree().create_timer(5).timeout
#	get_tree().paused = false
	round_over_label.hide()

	for c in world.get_children():
		c.free()

	if go_to_main_menu:
		$SuccessJingle.stop()
		$FailJingle.stop()
		world.hide()
		hud.hide()
		main_menu.show()
		$MainMenuMusic.play()
	else:
		start_game.call_deferred()


func _on_hero_health_changed(hp):
	print("Hero has %d health" % hp)
	healthbar.value = hp
	if hp <= 0:
		end_round(false)

func _on_hero_xp_changed(xp, display_xp):
	print("Hero has %d xp" % xp)
	print("Hero has %d display_xp" % display_xp)
	xpbar.value = display_xp
	if xp < 0:
		print("Fuck do I know")

func _on_unit_bar_place_unit(unit_data: UnitData, unit_local_position) -> void:
	if currency >= unit_data.cost:
		currency -= unit_data.cost
		
		var scene = unit_data.unit_scene if unit_data.unit_scene else UNIT_SCENE
		var unit = scene.instantiate()
		unit.unit_level = round_level
		unit.unit_data = unit_data
		unit.position = unit_local_position
		world.add_child(unit)

	if currency < CHEAPEST_UNIT_COST:
		$UI/HUD/UnitBar.is_broke = true
	
	update_currency_label()

func update_currency_label():
	$UI/HUD/CurrencyLabel.text = "Currency: %d" % currency
	if $UI/HUD/UnitBar.is_broke:
		$UI/HUD/CurrencyLabel.add_theme_color_override("font_color", Color.RED)
	else:
		$UI/HUD/CurrencyLabel.remove_theme_color_override("font_color")

func _on_main_menu_start_button_pressed() -> void:
	start_game()


func _on_main_menu_quit_button_pressed() -> void:
	get_tree().quit()
