extends Node2D

var coneScene := preload("res://scenes/game/cone.tscn")
var obstacles : Array
var lastObs

const cameraPos := Vector2i(579, 324)
const playerPos := Vector2i(994, 468)

var speed : float
const startSpeed : float = 10.0
const maxSpeed : float = 50
const speedModifier : int = 5000

var groundHeight : int
var groundScale
var screenSize : Vector2i

var score : int
var obsTimer: Timer

var countdown_time : int = 0  # 23:59 in minutes
var countdown_speed : float = 2  # 1 real-time second = 1 minute decrease
var elapsed_time : float = 0.0  # Tracks time passed for countdown

@onready var time_label = $CanvasLayer/Control/Time # Your Label node

var game_running := false

func _ready() -> void:
	score = 0
	screenSize = get_window().size
	groundHeight = $Ground.get_node("Sprite2D").texture.get_height()
	groundScale = $Ground.get_node("Sprite2D").scale
	
		# Set up obstacle spawn timer
	obsTimer = Timer.new()
	obsTimer.wait_time = randf_range(1.0, 3.0)  # Randomize spawn interval
	obsTimer.one_shot = false
	obsTimer.autostart = true
	add_child(obsTimer)
	obsTimer.timeout.connect(generate_obs)
	
	new_game()

func new_game():
	$Player.position = playerPos
	$Player.velocity = Vector2i(0, 0)
	$Ground.position = Vector2i(0, 0)
	$Camera2D.position = cameraPos
	
	game_running = true

func generate_obs():
	var obs = coneScene.instantiate()
	var obsHeight = obs.get_node("Sprite2D").texture.get_height()
	var obsScale = obs.get_node("Sprite2D").scale
	var obsX = -screenSize.x - score - 100
	var obsY = screenSize.y - groundHeight * groundScale.y - (obsHeight * obsScale.y / 2) + 5
	lastObs = obs
	obs.position = Vector2i(obsX, obsY)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)
	# Randomize next obstacle spawn time
	obsTimer.wait_time = randf_range(1.0, 3.0)

func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)

func update_label():
	if countdown_time < 0:
		countdown_time = 24 * 60 - 1
	
	var hours = (countdown_time / 60) % 12  # Convert to 12-hour format
	var minutes = countdown_time % 60
	var period = "AM" if (countdown_time / 60) < 12 else "PM"

	# Ensure hour is at least 1 (12-hour clock fix)
	hours = 12 if hours == 0 else hours
	
	# Update label with formatted time
	time_label.text = "%02d:%02d %s" % [hours, minutes, period]
 
func hit_obs(body):
	if body.name == "Player":
		print("game over")
		game_running = false

func _process(delta: float) -> void:
	if !game_running:
		return
	score += speed
	elapsed_time += delta * countdown_speed  # Adjust speed of countdown

	if elapsed_time >= 1.0:  # Decrease time once per second
		countdown_time -= 1
		elapsed_time = 0.0
		update_label()

	for obs in obstacles:
		if obs.position.x > ($Camera2D.position.x + screenSize.x):
				remove_obs(obs)

func _physics_process(delta: float) -> void:
	if !game_running:
		return
	speed = startSpeed + score / speedModifier
	if speed > maxSpeed:
		speed = maxSpeed
	
	$Player.position.x -= speed
	$Camera2D.position.x -= speed
	$Ground.position.x -= speed
