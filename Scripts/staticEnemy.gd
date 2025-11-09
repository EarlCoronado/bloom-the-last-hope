extends RigidBody2D

@onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect the Timer signal
	timer.timeout.connect(_on_timer_timeout)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	# Check for the confirmed group name
	if body.is_in_group("Player"):
		
		# Determine if the player is landing from above (stomp check)
		# Using body.velocity.y > 0 is much more reliable than comparing positions.
		if body.velocity.y > 0:
			
			# --- STOMP KILL LOGIC ---
			
			# 1. ENEMY DIES
			queue_free()
			
			# 2. PLAYER BOUNCE FIX: Directly set the player's velocity (fixes the 'jump' error)
			# Use BOUNCE_VELOCITY constant (or just a negative number like -200)
			body.velocity.y = -200 
			
			
		# Player hits side/bottom (Player dies)
		else:
			# --- PLAYER DEATH LOGIC ---
			
			Engine.time_scale = 0.5
			
			# Safely remove the player's collision shape using deferred call
			var player_collision_shape = body.get_node_or_null("CollisionShape2D")
			if player_collision_shape:
				player_collision_shape.queue_free()
				
			timer.start() 
			
			
func _on_timer_timeout():	
	Engine.time_scale = 1
	get_tree().reload_current_scene()
