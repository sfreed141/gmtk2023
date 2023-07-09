extends Control

signal place_unit(unit_data: UnitData, unit_local_position: Vector2)

@onready var _grid_container: GridContainer = $MarginContainer/GridContainer
@onready var _selected_unit: PanelContainer = $SelectedUnit

const TILE_DIMENSION = Vector2(16, 16)

var _world: Node2D

var is_broke = false


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

func clear_selected_unit():
	_selected_unit.unit_data = null
	_selected_unit.visible = false

func _get_snapped_world_local_mouse_position():
	var world_position = _world.get_local_mouse_position()
	return world_position.snapped(TILE_DIMENSION)


func is_unit_placement_valid(world_local_position: Vector2):
	var query := PhysicsPointQueryParameters2D.new()
	query.collision_mask = 1
	query.position = world_local_position
	var space_state := _world.get_world_2d().direct_space_state
	var query_result = space_state.intersect_point(query)
	return query_result.is_empty()


func _physics_process(delta: float) -> void:
	if _selected_unit.visible:
		var world_position = _get_snapped_world_local_mouse_position()
		var viewport_position = _world.get_global_transform_with_canvas() * world_position
		_selected_unit.global_position = get_canvas_transform().inverse() * viewport_position

		if is_unit_placement_valid(world_position) and not is_broke:
			_selected_unit.modulate = Color.WHITE
		else:
			_selected_unit.modulate = Color.RED


func _gui_input(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.is_pressed()
		and _selected_unit.unit_data
	):
		var world_position = _get_snapped_world_local_mouse_position()
		if is_unit_placement_valid(world_position):
			place_unit.emit(_selected_unit.unit_data, world_position)
