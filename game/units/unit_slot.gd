extends PanelContainer

signal slot_clicked(index: int, button: int)

@export var unit_data: UnitData: set = set_unit_data

@onready var _texture_rect: TextureRect = $MarginContainer/TextureRect

func _ready():
	# this ensures any unit_data that was set before this node was ready is applied
	set_unit_data(unit_data)
	
	var zoom_level = get_viewport().get_camera_2d().zoom
	custom_minimum_size *= zoom_level

func set_unit_data(data: UnitData):
	unit_data = data
	if unit_data and _texture_rect:
		_texture_rect.texture = unit_data.texture
		_texture_rect.tooltip_text = unit_data.description

func _gui_input(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton
		and (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT)
		and event.is_pressed()
	):
		slot_clicked.emit(get_index(), event.button_index)
