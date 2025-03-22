extends CharacterBody2D

@export var gravity: int = 2000
@export var fallGravity: int = 3000
@export var jumpVelocity: int = -850
@export var jumpBufferTime: float = 0.1  # 100ms jump buffer window

@onready var playerSprite := $AnimatedSprite2D
@onready var runCollider := $RunCol
@onready var duckCollider := $DuckCol

var jumpBufferTimer: float = 0.0  # Tracks how long jump was pressed
var is_ducking: bool = false

func _get_gravity(velocity: Vector2) -> int:
	return gravity if velocity.y < 0 else fallGravity

func _physics_process(delta: float) -> void:
	_handle_animation(velocity)
	_handle_colliders()

	# Apply gravity
	if not is_on_floor():
		velocity.y += _get_gravity(velocity) * delta
	
	# Handle jump buffer
	if Input.is_action_just_pressed("ui_accept"):
		jumpBufferTimer = jumpBufferTime  # Store jump input for a short time

	if jumpBufferTimer > 0:
		jumpBufferTimer -= delta  # Decrease timer
	
	# Jumping logic
	if jumpBufferTimer > 0 and is_on_floor() and not is_ducking:
		velocity.y = jumpVelocity
		jumpBufferTimer = 0  # Reset buffer after jumping
	
	# Short hop mechanic
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y = jumpVelocity / 4
	
	# Ducking logic
	is_ducking = Input.is_action_pressed("ui_down") and is_on_floor()
	
	move_and_slide()

func _handle_animation(velocity: Vector2): 
	if is_on_floor():
		if is_ducking:
			playerSprite.play("duck")
		else:
			playerSprite.play("run_fast")
	else:
		if velocity.y < 0:
			playerSprite.play("jump")
		else:
			playerSprite.play("fall")

func _handle_colliders():
	runCollider.disabled = is_ducking
	duckCollider.disabled = not is_ducking
