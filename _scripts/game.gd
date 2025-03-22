extends Node2D

var coneScene := preload("res://scenes/game/cone.tscn")
var obstacles : Array
var lastObs

const cameraPos := Vector2i(579, 324)
const playerPos := Vector2i(994, 468)

var speed : float
const startSpeed : float = 10.0
const maxSpeed : float = 25.0
const speedModifier : int = 5000

var groundHeight : int
var groundScale
var screenSize : Vector2i

var score : int

func _ready() -> void:
	score = 0
	screenSize = get_window().size
	groundHeight = $Ground.get_node("Sprite2D").texture.get_height()
	groundScale = $Ground.get_node("Sprite2D").scale
	new_game()

func new_game():
	$Player.position = playerPos
	$Player.velocity = Vector2i(0, 0)
	$Ground.position = Vector2i(0, 0)
	$Camera2D.position = cameraPos

func generate_obs():
	if obstacles.is_empty():
		var obs = coneScene.instantiate()
		var obsHeight = obs.get_node("Sprite2D").texture.get_height()
		var obsScale = obs.get_node("Sprite2D").scale
		var obsX = -screenSize.x - score - 100
		var obsY = screenSize.y - groundHeight * groundScale.y - (obsHeight * obsScale.y / 2) + 5
		lastObs = obs
		obs.position = Vector2i(obsX, obsY)
		add_child(obs)
		obstacles.append(obs)

func _process(delta: float) -> void:
	score += speed

	generate_obs()
	for obs in obstacles:
		if obs.position.x > ($Camera2D.position.x + screenSize.x):
				remove_obs(obs)

func _physics_process(delta: float) -> void:
	print(speed)
	speed = startSpeed + score / speedModifier
	if speed > maxSpeed:
		speed = maxSpeed
	
	$Player.position.x -= speed
	$Camera2D.position.x -= speed
	$Ground.position.x -= speed

func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)
