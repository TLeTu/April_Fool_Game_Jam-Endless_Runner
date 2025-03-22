extends Node2D

const cameraPos := Vector2i(579, 324)
const playerPos := Vector2i(994, 468)
const groundPos := Vector2i(514, 636)

var speed : float
const startSpeed : float = 10.0
const maxSpeed : float = 25.0

func _ready() -> void:
	new_game()

func new_game():
	$Player.position = playerPos
	$Player.velocity = Vector2i(0, 0)
	$Ground.position = groundPos
	$Camera2D.position = cameraPos
	
func _physics_process(delta: float) -> void:
	speed = startSpeed
	
	$Player.position.x -= speed
	$Camera2D.position.x -= speed
	$Ground.position.x -= speed
