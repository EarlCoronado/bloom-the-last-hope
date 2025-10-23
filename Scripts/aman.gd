extends CharacterBody2D


const SPEED = 140.0
const JUMP_VELOCITY = -280.0
const DOUBLE_JUMP_VELOCITY = -180 # Define a separate, weaker velocity for the second jump
const MAX_JUMPS = 2 

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jumps_available = MAX_JUMPS 

@onready var animated_sprite = $AnimatedSprite2D
@onready var jump_sfx = $jump_sfx

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Reset jumps_available when the character lands
	if is_on_floor():
		jumps_available = MAX_JUMPS

	# Handle jump (including double jump).
	if Input.is_action_just_pressed("jump") and jumps_available > 0:
		# Check if this is the second jump (jumps_available will be 1 before the jump)
		if jumps_available == 1:
			velocity.y = DOUBLE_JUMP_VELOCITY # Apply the weaker velocity
		# Otherwise, it's the first jump (jumps_available will be 2 before the jump)
		else:
			velocity.y = JUMP_VELOCITY # Apply the standard velocity
			
		jumps_available -= 1 # Decrement available jumps
		jump_sfx.play()

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("move_left", "move_right")
	
	#Sprite Flipping
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
	#Animation
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("running")
	else:
		animated_sprite.play("jumping")
		
	#Apply Movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
