extends CharacterBody2D 

# Node References
@onready var timer = $Timer

# Removed @onready var edge_ray_cast = $RayCast2D 

# Movement Properties
@export var speed: float = 100.0                   
var direction: int = 1                             
const GRAVITY = 980.0
const PLAYER_BOUNCE_VELOCITY = -400.0 

func _ready():
	# Timer connection (using the standard Godot 4 syntax)
	timer.timeout.connect(_on_timer_timeout) 

func _physics_process(delta):
	# CRASH FIX 1: Exit immediately if the enemy is marked for deletion.
	if is_queued_for_deletion():
		return
		
	# --- Movement Logic (Currently just gravity) ---
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	# NOTE: Your enemy needs horizontal movement code here if it's supposed to move.
	# Since we removed the RayCast, you must re-implement patrol logic if needed.
	# If the enemy stands still, just use: velocity.x = 0
	
	# If you want it to move, you can use the basic horizontal speed from before:
	# velocity.x = speed * direction 
	
	move_and_slide()

# --- Player/Enemy Death Logic ---
func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		
		# Cast the generic 'body' node as CharacterBody2D to access 'velocity'
		var player = body as CharacterBody2D
		
		if player:
			
			# Check 1: Is the player moving downwards (velocity.y > 0)?
			if player.velocity.y > 0:
				# ENEMY DIES (Head-stomp)
				queue_free() # Enemy is marked for deletion
				player.velocity.y = PLAYER_BOUNCE_VELOCITY 
			
			# Check 2: Player hits the side/bottom (Player Dies)
			else:
				Engine.time_scale = 0.5
				player.get_node("CollisionShape2D").queue_free() 
				timer.start() 
			
			
func _on_timer_timeout():	
	Engine.time_scale = 1
	get_tree().reload_current_scene()
