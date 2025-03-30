extends Node2D

signal animation_done

@onready var animation_player = $AnimationPlayer
@onready var game = $"../Game"
@onready var background = $ParallaxBackground
@onready var UI = $UI
@onready var UI_control = $UI/Control

func _ready() -> void:
	set_visibile(true)
	animation_player.animation_finished.connect(_on_animation_finished)
	game.connect("play_cutscene", self._on_play)
	animation_player.play("cut_scene_1")

func set_visibile(visible: bool) -> void:
	self.visible = visible
	UI.visible = visible
	background.visible = visible
	UI_control.visible = visible

func _on_animation_finished(anim_name: String) -> void:
	emit_signal("animation_done")
	set_visibile(false)

func _on_play(cutscene) -> void:
	set_visibile(true)
	match cutscene:
		int(2):
			animation_player.play("cut_scene_2")
		int(3):
			animation_player.play("cut_scene_3")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):  # Default space key in Godot
		skip_animation()

func skip_animation() -> void:
	if animation_player.is_playing():
		animation_player.stop()
		_on_animation_finished(animation_player.current_animation)
