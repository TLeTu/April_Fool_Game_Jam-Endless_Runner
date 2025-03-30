extends GPUParticles2D

@export var modulate_color: Color = Color(1, 1, 1, 1)  # Default to white

func _ready():
	self.self_modulate = modulate_color  # Apply the color when the scene loads
