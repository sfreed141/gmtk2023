extends Node

@onready var main_menu: PanelContainer = $UI/MainMenu
@onready var hud: Control = $UI/HUD

@onready var player: Player = $World/Player
@onready var world: Node2D = $World

const UNIT_SCENE = preload("res://game/units/unit.tscn")
const LEVEL_NODE_NAME := "Level"
const PLAYER_SPAWN_GROUPNAME := "player_spawn"
const HERO_SPAWN_GROUPNAME := "hero_spawn"
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
		var level := startup_level.instantiate()
		level.name = LEVEL_NODE_NAME
		world.add_child(level)
		
		var player_spawn: Node2D = get_tree().get_first_node_in_group(PLAYER_SPAWN_GROUPNAME)
		if player_spawn:
			player.global_position = player_spawn.global_position
		else:
			push_error("Level '%s' doesn't have a node in group '%s'" % [startup_level.resource_name, PLAYER_SPAWN_GROUPNAME])
	else:
		push_error("No startup_level specified!")


func _on_main_menu_start_button_pressed() -> void:
	start_game()

func _on_main_menu_quit_button_pressed() -> void:
	get_tree().quit()


func _on_unit_bar_place_unit(unit_data, unit_position) -> void:
	var unit = UNIT_SCENE.instantiate()
	unit.unit_data = unit_data
	unit.global_position = unit_position
	world.add_child(unit)
