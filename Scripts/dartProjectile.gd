extends Area2D

# 1. Variables and Setup
const SPEED = 500  
var velocity = Vector2.ZERO
var damage = 1 

@onready var lifetime_timer = $LifetimeTimer 


func _ready():
	# Connect the Lifetime Timer
	lifetime_timer.timeout.connect(queue_free) 
	lifetime_timer.start(0.8) 
	
	# Connect collision signal
	body_entered.connect(_on_Dart_Projectile_body_entered)


func _physics_process(delta):
	position += velocity * delta


func launch(direction):
	velocity = Vector2.RIGHT * direction * SPEED
	scale.x = direction


# Collision Detection Function
func _on_Dart_Projectile_body_entered(body):
	
	# Check for Enemy (Assuming "Enemy" or "enemies" - use the one that works for you!)
	if body.is_in_group("Enemy") or body.is_in_group("enemies"): 
		
		# --- NEW LOGIC: DEFERRED DEATH ---
		# Call_deferred ensures the engine finishes the collision check before destroying the body.
		body.call_deferred("queue_free") 
		
		# Dart is destroyed after hitting the enemy
		queue_free()
		
	# Ignore collision with the Player
	elif not body.is_in_group("Player"): 
		# Destroy dart if it hits anything that is NOT the player (e.g., a wall)
		queue_free()
