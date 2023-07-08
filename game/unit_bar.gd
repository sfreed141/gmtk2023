extends Control

signal place_unit(unit_data: UnitData, unit_position: Vector2)

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

func _get_snapped_world_mouse_position():
	var viewport_position = get_viewport().get_mouse_position()
	var world_position = _world.get_canvas_transform().inverse() * viewport_position
	return world_position.snapped(TILE_DIMENSION)

func _get_snapped_global_mouse_position():
	# viewport_position (from get_viewport().get_mouse_position()) is relative to the top-left corner of the window,
	# but we want to snap to the world/level grid.
	# So we transform it relative to the world's canvas, apply the snapping, and then transform back
	var world_position = _get_snapped_world_mouse_position()
	return _world.get_canvas_transform() * world_position

func _physics_process(delta: float) -> void:
	if _selected_unit.visible:
		_selected_unit.global_position = _get_snapped_global_mouse_position()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var world_position = _get_snapped_world_mouse_position()
		place_unit.emit(_selected_unit.unit_data, world_position)
