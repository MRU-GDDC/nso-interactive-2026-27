extends Area2D

signal completed

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var win_timer: Timer = $WinTimer

var is_open: bool = false
var player_inside: bool = false


func _ready() -> void:
	set_open(false)


func set_open(open: bool) -> void:
	is_open = open

	if is_open:
		sprite.animation = &"open"

		if player_inside:
			win_timer.start()
	else:
		sprite.animation = &"closed"
		win_timer.stop()


func _on_body_entered(body: Node2D) -> void:
	if body != Globals.player:
		return

	player_inside = true

	if is_open:
		win_timer.start()


func _on_body_exited(body: Node2D) -> void:
	if body != Globals.player:
		return

	player_inside = false
	win_timer.stop()


func _on_win_timer_timeout() -> void:
	if is_open and player_inside:
		completed.emit()
