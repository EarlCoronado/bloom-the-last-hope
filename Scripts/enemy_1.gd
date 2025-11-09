extends Node2D

const speed = 60

var direction = 1
# Timer is a direct child of enemy1
@onready var timer = $Timer 
@onready var right = $right
@onready var left = $left
@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	# Only connect the signal if you didn't do it in the Godot editor
	if is_instance_valid(timer):
		timer.timeout.connect(_on_timer_timeout)

func _process(delta):
	# Movement logic with null-instance safety checks (fixes the crashing error)
	if is_instance_valid(right) and right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if is_instance_valid(left) and left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	position.x += direction * speed * delta


# NOTE: This function is connected to your Enemy's Area2D signal
func _on_area_2d_body_entered(body):
	# Check for "Player" (Capital P) to match your confirmed group name setup
	if body.is_in_group("Player"):
		
		# --- STOMP/BOUNCE LOGIC ---
		# Check if the player is moving downwards (velocity.y > 0)
		if body.velocity.y > 0:
			
			# Player Bounces: Set player's vertical velocity to a negative value
			body.velocity.y = -200 # Adjust bounce strength as needed
			
			# Enemy Dies
			queue_free()
		
		# --- PLAYER HIT LOGIC ---
		else:
			# PLAYER DIES (Hit side/bottom)
			Engine.time_scale = 0.5
			
			# Safely get and remove the player's collision shape
			var player_collision_shape = body.get_node_or_null("CollisionShape2D")
			if player_collision_shape:
				player_collision_shape.queue_free()
				
			timer.start() # Start the delay timer to reload the scene
			
func _on_timer_timeout():	
	Engine.time_scale = 1
	# Defer the scene reload for safety
	get_tree().call_deferred("reload_current_scene")
