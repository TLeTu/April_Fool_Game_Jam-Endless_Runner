extends CharacterBody2D

#region Exports
@export var gravity: int = 2000
@export var fall_gravity: int = 3000
@export var jump_velocity: int = -850
@export var jump_buffer_time: float = 0.08  # 100ms jump buffer window
@export var death_particle : PackedScene
#endregion

#region Node References
@onready var player_sprite := $AnimatedSprite2D
@onready var run_collider := $RunCol
@onready var duck_collider := $DuckCol
@onready var game_manager := $".."
@onready var jump_sound := $JumpSound
@onready var dead_sound := $DeadSound
#endregion

#region State Variables
var jump_buffer_timer: float = 0.0  # Tracks how long jump was pressed
var is_ducking: bool = false
#endregion

#region Game State
enum GameState { RUNNING, PAUSED, GAMEOVER }
var game_state
#endregion

func _ready() -> void:
	game_manager.connect("game_state_changed", self._on_game_state_changed)

func _physics_process(delta: float) -> void:
	if !game_state == GameState.RUNNING: return
	_apply_gravity(delta)
	_handle_jump_input()
	_handle_jump_buffer(delta)
	_handle_short_hop()
	_handle_ducking()
	
	move_and_slide()
	
	_update_animations()
	_update_colliders()

func _on_game_state_changed(new_state):
	game_state = new_state
	if new_state == GameState.GAMEOVER:
		var _particle = death_particle.instantiate()
		_particle.position = player_sprite.global_position
		_particle.rotation = player_sprite.global_rotation
		_particle.emitting = true
		player_sprite.queue_free()
		dead_sound.play()
		add_child(_particle)

#region Physics Helpers
func _get_gravity() -> int:
	return gravity if velocity.y < 0 else fall_gravity

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += _get_gravity() * delta
#endregion

#region Input Handling
func _handle_jump_input() -> void:
	if Input.is_action_just_pressed("ui_accept"):
		jump_sound.play()
		jump_buffer_timer = jump_buffer_time  # Store jump input for a short time

func _handle_jump_buffer(delta: float) -> void:
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta  # Decrease timer
		
	# Jump if buffer active and conditions met
	if jump_buffer_timer > 0 and is_on_floor() and not is_ducking:
		velocity.y = jump_velocity
		jump_buffer_timer = 0  # Reset buffer after jumping

func _handle_short_hop() -> void:
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y = jump_velocity / 4  # Reduce jump height for short hop

func _handle_ducking() -> void:
	is_ducking = Input.is_action_pressed("ui_down") and is_on_floor()
#endregion

#region Visuals
func _update_animations() -> void:
	if is_on_floor():
		if is_ducking:
			player_sprite.play("duck")
		else:
			player_sprite.play("run_fast")
	else:
		if velocity.y < 0:
			player_sprite.play("jump")
		else:
			player_sprite.play("fall")

func _stop_animations() -> void:
	player_sprite.stop()
#endregion

#region Collision
func _update_colliders() -> void:
	run_collider.disabled = is_ducking
	duck_collider.disabled = not is_ducking
#endregion
