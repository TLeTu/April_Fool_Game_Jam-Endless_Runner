extends Node

#region Signal
signal game_state_changed(new_state)
signal play_cutscene(cutscene)
signal clean_all_obstacles
#endregion

#region Scene References
@onready var obstacles_manager = $ObstacleManager
@onready var time_manager = $TimeManager
@onready var player = $Player
@onready var ground = $Ground
@onready var camera = $Camera2D
@onready var UI = $UI
@onready var background = $ParallaxBackground
@onready var score_label = $UI/Control/ScoreLabel
@onready var cutscene_player = $"../CutScene1"
#endregion

#region Constants
const CAMERA_START_POS := Vector2i(579, 324)
const PLAYER_START_POS := Vector2i(994, 468)
const START_SPEED : float = 10.0
const SPEED_MODIFIER : int = 5000
#endregion

#region Game Variables
enum GameState { RUNNING, PAUSED, GAMEOVER }
var game_state
var score : float = 0
var speed_score : int = 0
var game_level = 1
var speed : float
var max_speed : float = 15.0
var cutscene : int = 0
var temp_camera_position : Vector2
var temp_player_position : Vector2
#endregion

var temp_speed : float

func _ready() -> void:
	set_visibile(false)
	set_game_state(GameState.PAUSED)
	obstacles_manager.connect("player_hit", self._on_player_hit)
	time_manager.connect("period_change", self._on_period_change)
	cutscene_player.connect("animation_done", self._on_cutscene_done)
	
	# Reset position and velocity
	temp_camera_position = CAMERA_START_POS
	temp_player_position = PLAYER_START_POS
	player.position = PLAYER_START_POS
	player.velocity = Vector2i.ZERO
	ground.position = Vector2i.ZERO
	camera.position = CAMERA_START_POS
	
	# Reset variables
	speed_score = 0
	score = 0
	game_level = 1
	temp_speed = speed

func _process(delta: float) -> void:
	if !game_state == GameState.RUNNING: return
	update_score(delta)
	update_speed_score()
	update_speed()
	update_positions()
	if speed != temp_speed:
		print("speed: ", speed)
		temp_speed = speed

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
	speed_score = 0
	game_level = 1

func pause_game() -> void:
	set_game_state(GameState.PAUSED)
	#set_visibile(false)
	emit_signal("clean_all_obstacles")

func set_game_state(new_state):
	if game_state != new_state:
		game_state = new_state
		emit_signal("game_state_changed", game_state)  # Emit the signal

func set_visibile(visible: bool) -> void:
	self.visible = visible
	UI.visible = visible
	background.visible = visible

func set_temp_position() -> void:
		temp_camera_position = camera.position
		temp_player_position = player.position
		camera.position = CAMERA_START_POS
		player.position.x = PLAYER_START_POS.x

func update_speed() -> void:
	if speed < max_speed:
		speed = START_SPEED + speed_score / SPEED_MODIFIER
		speed = min(speed, max_speed)
	else: speed = max_speed

func update_score(delta: float) -> void:
	score += 0.1
	var score_int = int(score)
	score_label.text = str(score_int)

func update_speed_score() -> void:
	if speed == max_speed: return
	speed_score += speed

func update_positions() -> void:
	player.position.x -= speed
	camera.position.x -= speed
	ground.position.x -= speed

func update_game_level(level: int) -> void:
	game_level = level

func _on_player_hit():
	set_game_state(GameState.GAMEOVER)

func _on_period_change(new_period) -> void:
	#if new_period == 2:
		#set_game_state(GameState.PAUSED)
	match new_period:
		5:
			max_speed = 20
		3:
			max_speed = 25
		4:
			max_speed = 30
		2: 
			max_speed = 35
			pause_game()
			cutscene = 2
			set_temp_position() 
			emit_signal("play_cutscene", cutscene)
		6: 
			max_speed = 40
			pause_game()
			cutscene = 3
			set_temp_position() 
			emit_signal("play_cutscene", cutscene)
		_:
			return

func _on_cutscene_done() -> void:
	camera.position = temp_camera_position
	player.position.x = temp_player_position.x
	set_visibile(true)
	set_game_state(GameState.RUNNING)
