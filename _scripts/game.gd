extends Node2D

#region Constants
const CAMERA_START_POS := Vector2i(579, 324)
const PLAYER_START_POS := Vector2i(994, 468)
const START_SPEED : float = 10.0
const MAX_SPEED : float = 50
const SPEED_MODIFIER : int = 5000
#endregion

#region Scene References
@onready var time_label = $CanvasLayer/Control/Time
@onready var player = $Player
@onready var ground = $Ground
@onready var camera = $Camera2D
#endregion

#region Obstacles
var cone_scene := preload("res://scenes/game/obstacles/cone.tscn")
var truck_scene := preload("res://scenes/game/obstacles/truck.tscn")
var obstacles_table = WeightedTable.new()
var obstacles : Array = []
var last_obstacle
var obstacle_timer: Timer
#endregion

#region Game Variables
var speed : float
var score : int = 0
var game_running := false
var screen_size : Vector2i
var ground_height : int
var ground_scale : Vector2
var countdown_time : int = 23 * 60 + 59  # 23:59 in minutes
var countdown_speed : float = 1000  # 1 real-time second = 1 minute decrease
var elapsed_time : float = 0.0  # Tracks time passed for countdown
#endregion

var previous_time

func _ready() -> void:
	initialize_game()
	setup_obstacle_timer()
	new_game()

#region Initialization
func initialize_game() -> void:
	screen_size = get_window().size
	ground_height = ground.get_node("Sprite2D").texture.get_height()
	ground_scale = ground.get_node("Sprite2D").scale

func setup_obstacle_timer() -> void:
	obstacle_timer = Timer.new()
	obstacle_timer.wait_time = randf_range(1.0, 3.0)
	obstacle_timer.one_shot = false
	obstacle_timer.autostart = true
	add_child(obstacle_timer)
	obstacle_timer.timeout.connect(_on_obstacle_timer_timeout)

#endregion

#region Game Flow
func new_game() -> void:
	reset_positions()
	reset_game_state()
	game_running = true

func reset_positions() -> void:
	player.position = PLAYER_START_POS
	player.velocity = Vector2i.ZERO
	ground.position = Vector2i.ZERO
	camera.position = CAMERA_START_POS

func reset_game_state() -> void:
	obstacles_table.reset()
	obstacles_table.add_item(cone_scene, 100)
	score = 0
	speed = 0
	obstacles.clear()
	countdown_time = 23 * 60 + 59
	elapsed_time = 0.0
	update_time_label()
#endregion

#region Obstacle Management
func _on_obstacle_timer_timeout() -> void:
	#generate_obstacle()
	pass

func generate_obstacle() -> void:
	var obstacle_scene = obstacles_table.get_random()
	if obstacle_scene:
		var obstacle = obstacle_scene.instantiate()
		var obstacle_sprite = obstacle.get_node("Sprite2D")
		var obstacle_height = obstacle_sprite.texture.get_height()
		var obstacle_scale = obstacle_sprite.scale
		
		var spawn_x = 0
		var spawn_y = 0
		
		spawn_x = -screen_size.x - score - 100
		spawn_y = screen_size.y - ground_height * ground_scale.y - (obstacle_height * obstacle_scale.y / 2) + 5
		
		last_obstacle = obstacle
		obstacle.position = Vector2i(spawn_x, spawn_y)
		obstacle.body_entered.connect(_on_obstacle_hit)
		add_child(obstacle)
		obstacles.append(obstacle)
		
		# Randomize next obstacle spawn time
		obstacle_timer.wait_time = randf_range(1.0, 3.0)

func remove_obstacle(obstacle) -> void:
	obstacle.queue_free()
	obstacles.erase(obstacle)

func _on_obstacle_hit(body) -> void:
	if body.name == "Player":
		game_over()

func game_over() -> void:
	game_running = false
	print("Game Over")
#endregion

#region Countdown System
func get_time_period() -> int:
	var hour = (countdown_time / 60) % 24  # Lấy giờ từ 0 đến 23 (đếm ngược)
	if hour >= 20 or hour == 0:  # 0 AM -> 8 PM
		return 1
	elif hour >= 16:  # 8 PM -> 4 PM
		return 2
	elif hour >= 12:  # 4 PM -> 12 PM
		return 3
	elif hour >= 8:  # 12 PM -> 8 AM
		return 4
	elif hour >= 4:  # 8 AM -> 4 AM
		return 5
	else:  # 4 AM -> 0 AM (ngày hôm trước)
		return 6

func update_time_label() -> void:
	var hours = (countdown_time / 60) % 12  # Chuyển sang 12 giờ
	var minutes = countdown_time % 60
	var period = "AM" if (countdown_time / 60) < 12 else "PM"
	if (countdown_time / 60) < 1:  
		hours = 0  # Show 0 AM when below 1 AM  
	else:
		hours = 12 if hours == 0 else hours  
	time_label.text = "%02d:%02d %s" % [hours, minutes, period]

func update_countdown(delta: float) -> void:
	if countdown_time <= 0:
		return  # Ngừng đếm ngược khi đạt 00:00
	
	elapsed_time += delta * countdown_speed
	if elapsed_time >= 1.0:
		countdown_time -= 1
		elapsed_time = 0.0
		update_time_label()
#endregion

#region Game Loop
func _process(delta: float) -> void:
	if !game_running:
		return
	print(countdown_time)
	update_score()
	update_countdown(delta)
	clean_up_obstacles()

func update_score() -> void:
	score += speed

func clean_up_obstacles() -> void:
	for obstacle in obstacles:
		if obstacle.position.x > (camera.position.x + screen_size.x):
			remove_obstacle(obstacle)

func _physics_process(delta: float) -> void:
	if !game_running:
		return
		
	update_speed()
	update_positions()

func update_speed() -> void:
	speed = START_SPEED + score / SPEED_MODIFIER
	speed = min(speed, MAX_SPEED)

func update_positions() -> void:
	player.position.x -= speed
	camera.position.x -= speed
	ground.position.x -= speed
#endregion
