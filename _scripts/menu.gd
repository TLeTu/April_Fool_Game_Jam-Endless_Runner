extends Control

const SAVE_FILE_PATH := "user://highscore.save"
var high_score : int = 0
@onready var high_score_label = $ColorRect/Highscore
@onready var instruction = $ColorRect/Label

func _ready() -> void:
	load_high_score()
	instruction.enable_blinking()
	high_score_label.text = "High score: " + str(high_score)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_scene.tscn")

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings.tscn")

func load_high_score() -> void:
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		high_score = int(file.get_as_text().strip_edges())
		file.close()
