extends CharacterBody2D

signal died

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _ready() -> void:
	Globals.player = self

func _exit_tree() -> void:
	if Globals.player == self:
		Globals.player = null
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("wasd_w") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("wasd_a", "wasd_d")
	if direction:
		$AnimatedSprite2D.play()
		velocity.x = direction * SPEED
		$AnimatedSprite2D.flip_h = direction < 0
	else:
		$AnimatedSprite2D.stop()
		velocity.x = move_toward(velocity.x, 0, SPEED)
		

	move_and_slide()
	position.x = clamp(position.x, 8, 472)

func die() -> void:
	died.emit()
