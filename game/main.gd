extends Node

@onready var main_menu: PanelContainer = $UI/MainMenu
@onready var hud: Control = $UI/HUD
@onready var round_over_label: Label = $UI/HUD/RoundOverLabel

@onready var player: Player = $World/Player
@onready var world: Node2D = $World

const UNIT_SCENE = preload("res://game/units/unit.tscn")
const LEVEL_NODE_NAME := "Level"
const PLAYER_SPAWN_GROUPNAME := "player_spawn"
const HERO_GROUPNAME := "hero"

var hero: Hero
var level: Node

@export var startup_level: PackedScene
@export var start_at_main_menu := true

func _ready():
	if start_at_main_menu:
		world.hide()
		hud.hide()
		main_menu.show()
	else:
		start_game()

func start_game():
	main_menu.hide()
	world.show()
	hud.show()

	if startup_level:
		level = startup_level.instantiate()
		level.name = LEVEL_NODE_NAME
		world.add_child(level)
		
		var player_spawn: Node2D = get_tree().get_first_node_in_group(PLAYER_SPAWN_GROUPNAME)
		if player_spawn:
			player.global_position = player_spawn.global_position
		else:
			push_error("Level '%s' doesn't have a node in group '%s'" % [startup_level.resource_name, PLAYER_SPAWN_GROUPNAME])
		
		hero = get_tree().get_first_node_in_group(HERO_GROUPNAME)
		hero.path_finished.connect(_on_hero_path_finished)
		hero.health_changed.connect(_on_hero_health_changed)
	else:
		push_error("No startup_level specified!")

func _on_hero_path_finished():
	end_round(true)

func end_round(success: bool):
	if success:
		round_over_label.text = "Dungeon Cleared!"
	else:
		round_over_label.text = "Hero wasn't strong enough :("

	round_over_label.show()
	get_tree().paused = true
	await get_tree().create_timer(3).timeout
	get_tree().paused = false
	round_over_label.hide()
	
	level.queue_free()
	
	# TODO goto next level or back to level0 depending on success
	start_game.call_deferred()

func _on_hero_health_changed(hp):
	print("Hero has %d health" % hp)
	if hp <= 0:
		end_round(false)

func _on_unit_bar_place_unit(unit_data: UnitData, unit_local_position) -> void:
	var scene = unit_data.unit_scene if unit_data.unit_scene else UNIT_SCENE
	var unit = scene.instantiate()
	unit.unit_data = unit_data
	unit.position = unit_local_position
	world.add_child(unit)


func _on_main_menu_start_button_pressed() -> void:
	start_game()

func _on_main_menu_quit_button_pressed() -> void:
	get_tree().quit()
