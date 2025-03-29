extends Node

#region Signal
signal game_state_changed(new_state)
#endregion

#region Scene References
@onready var obstacles_manager = $ObstacleManager
@onready var time_manager = $TimeManager
@onready var player = $Player
@onready var ground = $Ground
@onready var camera = $Camera2D
#endregion

#region Constants
const CAMERA_START_POS := Vector2i(579, 324)
const PLAYER_START_POS := Vector2i(994, 468)
const START_SPEED : float = 10.0
const MAX_SPEED : float = 50
const SPEED_MODIFIER : int = 5000
#endregion

#region Game Variables
enum GameState { RUNNING, PAUSED, GAMEOVER }
var game_state
var score : int = 0
var game_level = 1
var speed : float
#endregion

func _ready() -> void:
	set_game_state(GameState.RUNNING)
	obstacles_manager.connect("player_hit", self._on_player_hit)
	
	# Reset position and velocity
	player.position = PLAYER_START_POS
	player.velocity = Vector2i.ZERO
	ground.position = Vector2i.ZERO
	camera.position = CAMERA_START_POS
	
	# Reset variables
	score = 0
	game_level = 1

func _process(delta: float) -> void:
	if !game_state == GameState.RUNNING: return
	score += speed
	update_speed()
	update_positions()

func new_game():
	set_game_state(GameState.RUNNING)
	obstacles_manager.reset()
	time_manager.reset()
	
	# Reset position and velocity
	player.position = PLAYER_START_POS
	player.velocity = Vector2i.ZERO
	ground.position = Vector2i.ZERO
	camera.position = CAMERA_START_POS
	
	# Reset variables
	score = 0
	game_level = 1

func set_game_state(new_state):
	if game_state != new_state:
		game_state = new_state
		emit_signal("game_state_changed", game_state)  # Emit the signal

func update_speed() -> void:
	speed = START_SPEED + score / SPEED_MODIFIER
	speed = min(speed, MAX_SPEED)

func update_positions() -> void:
	player.position.x -= speed
	camera.position.x -= speed
	ground.position.x -= speed

func update_game_level(level: int) -> void:
	game_level = level

func _on_player_hit():
	set_game_state(GameState.GAMEOVER)
