extends Node

#region Scene References
@onready var time_label = $"../UI/Control/TimeLabel"
@onready var game_manager = $".."
#endregion

#region Time Variables
var countdown_time : int = 23 * 60 + 59  # 23:59 in minutes
var countdown_speed : float = 1  # 1 real-time second = 1 minute decrease
var elapsed_time : float = 0.0  # Tracks time passed for countdown
#endregion

#region Game State
enum GameState { RUNNING, PAUSED, GAMEOVER }
var game_state
#endregion

func _ready() -> void:
	reset()
	game_manager.connect("game_state_changed", self._on_game_state_changed)

func _process(delta: float) -> void:
	if !game_state == GameState.RUNNING:
		return
	update_countdown(delta)

func reset() -> void:
	countdown_time = 23 * 60 + 59
	elapsed_time = 0.0
	update_time_label()

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

func _on_game_state_changed(new_state):
	game_state = new_state
