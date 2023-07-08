extends Control

signal place_unit(unit_data: UnitData, unit_local_position: Vector2)

@onready var _grid_container: GridContainer = $MarginContainer/GridContainer
@onready var _selected_unit: PanelContainer = $SelectedUnit

const TILE_DIMENSION = Vector2(16, 16)

var _world: Node2D

func _ready():
	for slot in _grid_container.get_children():
		slot.slot_clicked.connect(_on_slot_clicked)
	
	_world = get_tree().get_first_node_in_group("world")

func _on_slot_clicked(index: int, button: int):
	var slot = _grid_container.get_child(index)
	var unit_data: UnitData = slot.unit_data
	print("Clicked on %s" % unit_data.name)
	
	_selected_unit.unit_data = unit_data
	_selected_unit.visible = true

func _get_snapped_world_local_mouse_position():
	var world_position = _world.get_local_mouse_position()
	return world_position.snapped(TILE_DIMENSION)

func get_snapped_viewport_mouse_position():
	var world_position = _get_snapped_world_local_mouse_position()
	return _world.get_global_transform_with_canvas() * world_position


func _physics_process(delta: float) -> void:
	if _selected_unit.visible:
		var viewport_position = get_snapped_viewport_mouse_position()
		_selected_unit.global_position = get_canvas_transform().inverse() * viewport_position

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var world_position = _get_snapped_world_local_mouse_position()
		place_unit.emit(_selected_unit.unit_data, world_position)
