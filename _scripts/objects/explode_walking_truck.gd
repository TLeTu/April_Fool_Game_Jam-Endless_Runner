extends RigidBody2D

@onready var body_legged_sprite = $BodyAndFrontLeg
@onready var back_leg_sprite = $BackLeg
@onready var legless_sprite = $LeglessSprite
@onready var detection_area = $DetectionArea
@onready var detection_shape = $DetectionArea/DetectionShape

@export var detection_range : int = 100
@export var gravity : int = 1
@export var death_particle : PackedScene

func _ready() -> void:
	self.gravity_scale = 0

func _process(delta: float) -> void:
	detect_player()

func detect_player() -> void:
	for body in detection_area.get_overlapping_bodies():
		if body.name == "Player":
			explode()

func explode_animation() -> void:
	# Instantiate the explode partical at the srpite location
	var _particle = death_particle.instantiate()
	_particle.position = body_legged_sprite.global_position
	_particle.rotation = body_legged_sprite.global_rotation
	_particle.emitting = true
	add_child(_particle)

func explode() -> void:
	explode_animation()
	detection_area.monitoring = false
	body_legged_sprite.set_visible(false)
	back_leg_sprite.set_visible(false)
	legless_sprite.set_visible(true)
	self.gravity_scale = gravity
