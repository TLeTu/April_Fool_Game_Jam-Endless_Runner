extends Label

@export var blink_speed: float = 0.5  # Time in seconds between blinks
var blink_on: bool = true
var timer: Timer  # Store timer reference

func _ready():
	# Create and start the timer for blinking
	timer = Timer.new()
	timer.wait_time = blink_speed
	timer.autostart = true
	timer.timeout.connect(_on_blink_timer_timeout)
	add_child(timer)
	disable_blinking()

func _on_blink_timer_timeout():
	if blink_on:
		visible = not visible  # Toggle visibility

# Function to disable blinking and hide the label
func disable_blinking():
	blink_on = false
	visible = false
	if timer:
		timer.stop()

# Function to enable blinking again
func enable_blinking():
	blink_on = true
	visible = true
	if timer:
		timer.start()
