extends Control

signal brick_selected
signal collectible_selected
signal spike_selected
signal edit_selected
signal play_selected

@onready var edit_button: Button = $TopBar/Edit
@onready var play_button: Button = $TopBar/Play
@onready var build_bar: Control = $BuildBar


func _ready() -> void:
	set_play_mode()


func set_edit_mode() -> void:
	build_bar.show()

	edit_button.self_modulate = Color.GREEN
	play_button.self_modulate = Color.WHITE


func set_play_mode() -> void:
	build_bar.hide()

	edit_button.self_modulate = Color.WHITE
	play_button.self_modulate = Color.GREEN


func _on_edit_pressed() -> void:
	set_edit_mode()
	edit_selected.emit()


func _on_play_pressed() -> void:
	set_play_mode()
	play_selected.emit()


func _on_reset_pressed() -> void:
	get_tree().reload_current_scene()


func _on_brick_pressed() -> void:
	brick_selected.emit()


func _on_collectible_pressed() -> void:
	collectible_selected.emit()


func _on_spike_pressed() -> void:
	spike_selected.emit()
