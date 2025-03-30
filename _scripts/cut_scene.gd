extends Node2D

signal animation_done
const SAVE_FILE_PATH := "user://highscore.save"
var high_score : int = 0
@onready var animation_player = $AnimationPlayer
@onready var game = $"../Game"
@onready var background = $ParallaxBackground
@onready var UI = $UI
@onready var UI_control = $UI/Control
@onready var skip_label = $UI/skip_label

func _ready() -> void:
	load_high_score()
		# Enable skip only if there's a high score
	if high_score > 0:
		skip_label.visible = true
		skip_label.enable_blinking()
	else:
		skip_label.disable_blinking()
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
	load_high_score()
	if high_score > 0:
		skip_label.visible = true
		skip_label.disable_blinking()
	set_visibile(true)
	match cutscene:
		int(2):
			animation_player.play("cut_scene_2")
		int(3):
			animation_player.play("cut_scene_3")
		int(4):
			animation_player.play("end")

func _input(event: InputEvent) -> void:
	if high_score > 0 and event.is_action_pressed("ui_accept"):  # Allow skipping only if high score exists
		skip_animation()

func skip_animation() -> void:
	if animation_player.is_playing():
		animation_player.stop()
		_on_animation_finished(animation_player.current_animation)

func load_high_score() -> void:
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		high_score = int(file.get_as_text().strip_edges())
		file.close()
