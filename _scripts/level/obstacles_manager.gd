extends Node

#region Signal
signal player_hit
#endregion

#region Scene References
@onready var ground = $"../Ground"
@onready var camera = $"../Camera2D"
@onready var game_manager = $".."
@onready var time_manager = $"../TimeManager"
#endregion

#region Preloaded scene
var cone_scene := preload("res://scenes/game/obstacles/cone.tscn")
var truck_scene := preload("res://scenes/game/obstacles/truck.tscn")
var walking_truck_scene := preload("res://scenes/game/obstacles/walking_truck.tscn")
var exploding_cone_scene := preload("res://scenes/game/obstacles/exploding_cone.tscn")
var exploding_walking_car := preload("res://scenes/game/obstacles/explode_walking_truck.tscn")
#endregion

#region Table and array
var obstacles_table = WeightedTable.new()
var obstacles : Array = []
#endregion

#region Spawner helps
var last_obstacle
var obstacle_timer: Timer
var screen_size: Vector2i
var ground_height: int
var ground_scale: Vector2i
#endregion

#region Game State
enum GameState { RUNNING, PAUSED, GAMEOVER }
var game_state
#endregion

func _ready() -> void:
	reset()
	time_manager.connect("period_change", self._on_period_change)
	screen_size = get_window().size
	ground_height = ground.get_node("Sprite2D").texture.get_height()
	ground_scale = ground.get_node("Sprite2D").scale
	game_manager.connect("game_state_changed", self._on_game_state_changed)
	game_manager.connect("clean_all_obstacles", self.clean_all_obstacles)

func _process(delta: float) -> void:
	clean_up_obstacles()

func reset() -> void:
	# Setup timer
	obstacle_timer = Timer.new()
	obstacle_timer.wait_time = 2
	obstacle_timer.one_shot = false
	obstacle_timer.autostart = true
	add_child(obstacle_timer)
	obstacle_timer.timeout.connect(_on_obstacle_timer_timeout)
	
	# Setup table and array
	obstacles.clear()
	obstacles_table.reset()
	obstacles_table.add_item(cone_scene, 100)

func generate_obstacle() -> void:
	var obstacle_scene = obstacles_table.get_random()
	if obstacle_scene:
		var obstacle = obstacle_scene.instantiate()
		var obstacle_sprite = obstacle.get_node("Sprite2D")
		
		var obstacle_width = obstacle_sprite.texture.get_width()
		var obstacle_height = obstacle_sprite.texture.get_height()
		
		var obstacle_scale = obstacle_sprite.scale
		
		#var spawn_x = -screen_size.x - game_manager.score - 100
		var spawn_x = -screen_size.x - (-camera.position.x - camera.get_window().size.x/2) - 500
		var spawn_y = screen_size.y - ground_height * ground_scale.y - (obstacle_height * obstacle_scale.y / 2) +40
		
		last_obstacle = obstacle_scene
		obstacle.position = Vector2i(spawn_x, spawn_y)
		
		if obstacle.has_signal("player_exploded"):
			obstacle.player_exploded.connect(_on_player_exploded)
		
		if obstacle.has_signal("explode_car"):
			obstacle.get_node("DeadArea").body_entered.connect(_on_obstacle_hit)
		else: obstacle.body_entered.connect(_on_obstacle_hit)
		add_child(obstacle)
		obstacles.append(obstacle)
		# Randomize next obstacle spawn time
		if last_obstacle == truck_scene:
			obstacle_timer.wait_time = randf_range(2.5, 3.0)
		else: obstacle_timer.wait_time = randf_range(0.8, 2.0)

func clean_up_obstacles() -> void:
	if obstacles.is_empty(): return
	for obstacle in obstacles:
		if obstacle.position.x > (camera.position.x + screen_size.x):
			remove_obstacle(obstacle)

func clean_all_obstacles() -> void:
	if obstacles.is_empty(): return
	for obstacle in obstacles:
			remove_obstacle(obstacle)

func remove_obstacle(obstacle) -> void:
	obstacle.queue_free()
	obstacles.erase(obstacle)

func _on_obstacle_hit(body) -> void:
	if body.name == "Player":
		game_state = GameState.GAMEOVER
		emit_signal("player_hit")

func _on_player_exploded() -> void:
	print("explodeed")
	game_state = GameState.GAMEOVER
	emit_signal("player_hit")


func _on_obstacle_timer_timeout():
	if game_state == GameState.RUNNING:
		generate_obstacle()

func _on_game_state_changed(new_state):
	game_state = new_state
	

func _on_period_change(new_period):
	match new_period:
		2:
			obstacles_table.change_weight(cone_scene, 60)
			obstacles_table.add_item(truck_scene, 40)
		3:
			obstacles_table.change_weight(cone_scene, 45)
			obstacles_table.change_weight(truck_scene, 35)
			obstacles_table.add_item(walking_truck_scene, 20)
		4:
			obstacles_table.change_weight(cone_scene, 35)
			obstacles_table.change_weight(truck_scene, 30)
			obstacles_table.change_weight(walking_truck_scene, 35)
		5:
			obstacles_table.change_weight(cone_scene, 25)
			obstacles_table.change_weight(truck_scene, 25)
			obstacles_table.change_weight(walking_truck_scene, 30)
			obstacles_table.add_item(exploding_cone_scene, 20)
		6:
			obstacles_table.change_weight(cone_scene, 20)
			obstacles_table.change_weight(truck_scene, 20)
			obstacles_table.change_weight(walking_truck_scene, 20)
			obstacles_table.change_weight(exploding_cone_scene, 25)
			obstacles_table.add_item(exploding_walking_car, 15)
		_:
			return
