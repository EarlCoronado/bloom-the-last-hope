extends CharacterBody2D
class_name Enemy

# === Node References ===
@onready var timer = $Timer
@onready var animated_sprite = $AnimatedSprite2D 
@onready var edge_ray_cast = $RayCast2D 

# Reference to the child Area2D node for head-stomp detection.
@onready var stomp_area = $Area2D 

# === Movement Properties ===
@export var speed: float = 100.0 
var direction: int = 1 
const GRAVITY = 980.0
const BOUNCE_VELOCITY = -200.0 # Vertical speed for the player bounce after a stomp

# === Initialization and Signal Connection ===
func _ready():
	# Connect the Timer signal
	timer.timeout.connect(_on_timer_timeout)
	
	# Connect the Area2D signal via code to the stomp detection function.
	if is_instance_valid(stomp_area):
		stomp_area.body_entered.connect(_on_stomp_area_body_entered)


# === Physics Processing (Movement Only) ===
func _physics_process(delta):
	
	# 1. Apply Gravity and Movement
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	# Direction change logic (if hitting an edge)
	if is_on_floor() and edge_ray_cast.is_colliding() == false:
		direction *= -1
	
	velocity.x = speed * direction
	
	if is_instance_valid(animated_sprite):
		animated_sprite.flip_h = direction == -1
		# Adjust RayCast position to check the leading edge
		edge_ray_cast.position.x = 10 * direction
	
	move_and_slide()
	
	# NOTE: The side-hit death logic is NOW handled in the _on_stomp_area_body_entered function.


# === Collision Detection (Area2D Signal) ===
func _on_stomp_area_body_entered(body):
	
	# 🔴 This function will trigger whenever the player touches the stomp Area2D.
	if body.is_in_group("Player"):
		
		# 🟢 STOMP KILL CONDITION: Player must be falling downwards 
		if body.velocity.y > 0:
			
			# 1. Player Bounces (modifying player's velocity)
			body.velocity.y = BOUNCE_VELOCITY
			
			# 2. Enemy Dies
			queue_free()
		
		# 💥 PLAYER DEATH CONDITION: Player hits the Area2D from the side or bottom
		# This covers every non-stomp hit, instantly killing the player and restarting.
		else:
			# 1. Slow down the game
			Engine.time_scale = 0.5
			
			# 2. Safely remove the player's collision shape
			var player_collision_shape = body.get_node_or_null("CollisionShape2D")
			if player_collision_shape:
				player_collision_shape.queue_free()
			
			# 3. Start timer for scene reload
			timer.start()
			return # Exit the function immediately


# === Scene Reload Logic (Called by Timer) ===
func _on_timer_timeout():	
	# 1. Reset game speed to normal
	Engine.time_scale = 1
	
	# 2. Reload the current scene to restart the level
	get_tree().reload_current_scene()
