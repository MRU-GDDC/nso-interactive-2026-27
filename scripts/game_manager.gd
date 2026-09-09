extends Node2D

@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var counter: Label = $UI/Counter
@onready var win_message: Label = $UI/WinMessage
@onready var level_exit: Area2D = $Exit

var item_collected: int = 0
var max_item: int = 0

func _ready() -> void:
	await get_tree().process_frame
	refresh_collectibles()


func refresh_collectibles() -> void:
	var collectibles: Array[Node] = get_tree().get_nodes_in_group("collectible")
	var callback: Callable = Callable(self, "_on_collectible_collected")

	item_collected = 0
	max_item = collectibles.size()

	for collectible: Node in collectibles:
		if collectible.has_method("reset"):
			collectible.reset()
		if collectible.has_signal("collected"):
			if not collectible.is_connected("collected", callback):
				collectible.connect("collected", callback)

	update_counter()
	win_message.hide()
	update_exit()


func _on_collectible_collected() -> void:
	item_collected += 1
	update_counter()
	update_exit()


func update_exit() -> void:
	level_exit.set_open(item_collected == max_item)


func restart() -> void:
	Globals.player.global_position = player_spawn.global_position
	Globals.player.velocity = Vector2.ZERO

	item_collected = 0

	for collectible: Node in get_tree().get_nodes_in_group("collectible"):
		if collectible.has_method("reset"):
			collectible.reset()

	update_counter()
	win_message.hide()
	update_exit()


func update_counter() -> void:
	counter.text = str(item_collected) + "/" + str(max_item)


func win_game() -> void:
	win_message.show()
	await get_tree().create_timer(2.0).timeout
	restart()


func _on_bottom_boundary_body_entered(body: Node2D) -> void:
	if body == Globals.player:
		_on_player_died()


func _on_player_died() -> void:
	restart()


func _on_level_builder_level_changed() -> void:
	refresh_collectibles()
	

func _on_exit_completed() -> void:
	win_game()
