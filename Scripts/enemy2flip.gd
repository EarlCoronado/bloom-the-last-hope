extends AnimatedSprite2D

var previous_x = 0

func _ready():
	previous_x = global_position.x

func _process(delta):
	var current_x = global_position.x
	
	# Flip based on movement direction
	if current_x > previous_x:    # Moving right
		flip_h = false
	elif current_x < previous_x:  # Moving left
		flip_h = true
	
	previous_x = current_x
