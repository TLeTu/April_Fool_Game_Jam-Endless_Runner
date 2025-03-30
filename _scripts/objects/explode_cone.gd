extends Area2D

signal player_exploded

@export var death_particle : PackedScene
@export var explode_radius : int = 50

@onready var sprite = $Sprite2D
@onready var detection_area = $DetectionArea
@onready var detection_shape = $DetectionArea/DetectionShape
@onready var explode_sound = $ExplodeSound

var has_explode : bool = false

func _ready():
	has_explode = false
	detection_shape.shape.radius = explode_radius

func _process(delta: float) -> void:
	detect_player()

func detect_player() -> void:
	# Explode if player is in range
	for body in detection_area.get_overlapping_bodies():
		if body.name == "Player":
			explode()

func explode_animation() -> void:
	# Instantiate the explode partical at the srpite location
	explode_sound.play()
	var _particle = death_particle.instantiate()
	_particle.position = sprite.global_position
	_particle.rotation = sprite.global_rotation
	_particle.emitting = true
	sprite.queue_free()
	add_child(_particle)
	_particle.finished.connect(_on_particle_finished)

func explode() -> void:
	if has_explode: return
	has_explode = true
	
	explode_animation()
	emit_signal("player_exploded")

func _on_particle_finished() -> void:
	if get_parent():  # Ensure the parent exists before calling
		get_parent().remove_obstacle(self)  # Let obstacle_manager handle cleanup
