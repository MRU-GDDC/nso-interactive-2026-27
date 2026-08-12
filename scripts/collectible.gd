extends Area2D

signal collected


func _on_body_entered(body: Node2D) -> void:
	if body == Globals.player:
		collected.emit()
		hide()
		set_deferred("monitoring", false)


func reset() -> void:
	show()
	set_deferred("monitoring", true)
