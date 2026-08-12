extends Node

signal level_changed

@onready var tile_map: TileMapLayer = $"../TileMapLayer"
@onready var placement_preview: Sprite2D = $PlacementPreview

@export var brick_texture: Texture2D
@export var collectible_texture: Texture2D
@export var spike_texture: Texture2D

const BRICK_SOURCE: int = 0
const SCENE_SOURCE: int = 1

const COLLECTIBLE_ID: int = 0
const SPIKE_ID: int = 1

const TILE_COORDS := Vector2i(0, 0)

const BUILD_AREA := Rect2(
	Vector2(0, 16),
	Vector2(480, 304)
)

enum BuildItem {
	BRICK,
	COLLECTIBLE,
	SPIKE
}

var selected_item: BuildItem = BuildItem.BRICK
var edit_mode: bool = false

func _ready() -> void:
	update_preview_texture()
	call_deferred("set_edit_mode", false)
	
func _process(_delta: float) -> void:
	update_placement_preview()

func update_preview_texture() -> void:
	match selected_item:
		BuildItem.BRICK: placement_preview.texture = brick_texture
		BuildItem.COLLECTIBLE: placement_preview.texture = collectible_texture
		BuildItem.SPIKE: placement_preview.texture = spike_texture


func update_placement_preview() -> void:
	if not edit_mode:
		placement_preview.hide()
		return
	if not mouse_is_inside_build_area():
		placement_preview.hide()
		return
	if placement_preview.texture == null:
		placement_preview.hide()
		return
	var cell: Vector2i = get_mouse_cell()
	var cell_position: Vector2 = tile_map.map_to_local(cell)
	placement_preview.global_position = tile_map.to_global(cell_position)
	placement_preview.show()


func _on_ui_brick_selected() -> void:
	selected_item = BuildItem.BRICK
	update_preview_texture()
	#print("Brick")


func _on_ui_collectible_selected() -> void:
	selected_item = BuildItem.COLLECTIBLE
	update_preview_texture()
	#print("Collectible")


func _on_ui_spike_selected() -> void:
	selected_item = BuildItem.SPIKE
	update_preview_texture()
	#print("Spike")

func _on_ui_edit_selected() -> void:
	set_edit_mode(true)
	#print("Edit")


func _on_ui_play_selected() -> void:
	set_edit_mode(false)
	#print("Play")

func set_edit_mode(enabled: bool) -> void:
	edit_mode = enabled
	if not edit_mode:
		placement_preview.hide()
	if Globals.player == null:
		return
	Globals.player.velocity = Vector2.ZERO
	if edit_mode:
		Globals.player.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		Globals.player.process_mode = Node.PROCESS_MODE_INHERIT


func get_mouse_cell() -> Vector2i:
	var mouse_position: Vector2 = tile_map.get_local_mouse_position()
	return tile_map.local_to_map(mouse_position)


func mouse_is_inside_build_area() -> bool:
	var mouse_position: Vector2 = tile_map.get_global_mouse_position()
	return BUILD_AREA.has_point(mouse_position)


func place_item() -> void:
	if not edit_mode:
		return
	if not mouse_is_inside_build_area():
		return
	var cell: Vector2i = get_mouse_cell()
	if tile_map.get_cell_source_id(cell) != -1:
		return
	match selected_item:
		BuildItem.BRICK: tile_map.set_cell(cell, BRICK_SOURCE, TILE_COORDS, 0)
		BuildItem.COLLECTIBLE: tile_map.set_cell(cell, SCENE_SOURCE, TILE_COORDS, COLLECTIBLE_ID)
		BuildItem.SPIKE: tile_map.set_cell(cell, SCENE_SOURCE, TILE_COORDS, SPIKE_ID)
	tile_map.update_internals()
	level_changed.emit()

func remove_item() -> void:
	if not edit_mode:
		return
	if not mouse_is_inside_build_area():
		return
	var cell: Vector2i = get_mouse_cell()
	tile_map.erase_cell(cell)
	tile_map.update_internals()
	level_changed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not edit_mode:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			place_item()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			remove_item()
	elif event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			place_item()
		elif event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
			remove_item()
