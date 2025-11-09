extends CharacterBody2D


# -------------------------------------
# 1. MOVEMENT CONSTANTS & VARIABLES
# -------------------------------------

const SPEED = 140.0
const JUMP_VELOCITY = -280.0
const DOUBLE_JUMP_VELOCITY = -180 
const MAX_JUMPS = 2 

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jumps_available = MAX_JUMPS 

# -------------------------------------
# 2. DART CONSTANTS & VARIABLES
# -------------------------------------

const DART_SCENE = preload("res://Scene/dart_projectile.tscn") # <--- UPDATE THIS PATH!
var dart_cooldown = 0.5 
var can_throw = true 


# -------------------------------------
# 3. ONREADY REFERENCES
# -------------------------------------

@onready var animated_sprite = $AnimatedSprite2D
@onready var jump_sfx = $jump_sfx
@onready var throw_point = $ThrowPoint        # References the new ThrowPoint node
@onready var cooldown_timer = $CooldownTimer  # References the new CooldownTimer node


# -------------------------------------
# 4. INITIALIZATION
# -------------------------------------

func _ready():
	# Set the timer properties and connect the timeout signal (Godot 4 Syntax)
	cooldown_timer.wait_time = dart_cooldown
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_CooldownTimer_timeout)


# -------------------------------------
# 5. CORE GAME LOOP
# -------------------------------------

func _physics_process(delta):
	# Apply gravity and reset jumps
	if not is_on_floor():
		velocity.y += gravity * delta
	if is_on_floor():
		jumps_available = MAX_JUMPS

	# Handle jump (existing logic)
	if Input.is_action_just_pressed("jump") and jumps_available > 0:
		if jumps_available == 1:
			velocity.y = DOUBLE_JUMP_VELOCITY
		else:
			velocity.y = JUMP_VELOCITY
			
		jumps_available -= 1 
		jump_sfx.play()

	handle_input()
	
	move_and_slide()

# -------------------------------------
# 6. INPUT AND ANIMATION
# -------------------------------------

func handle_input():
	var direction = Input.get_axis("move_left", "move_right")
	
	# Sprite Flipping (existing logic)
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
	# Animation (existing logic)
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("running")
	else:
		animated_sprite.play("jumping")
		
	# Apply Movement (existing logic)
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# DART THROW CHECK (Requires "shoot_dart" action in Project Settings > Input Map)
	if Input.is_action_just_pressed("shoot_dart"):
		try_throw_dart()

# -------------------------------------
# 7. DART THROW LOGIC
# -------------------------------------

func try_throw_dart():
	# Cooldown check
	if not can_throw:
		return
		
	# Start Cooldown
	can_throw = false
	cooldown_timer.start()
	
	# Spawn the dart
	shoot_dart() 


func shoot_dart():
	var dart = DART_SCENE.instantiate() 
	
	# Add dart to the level root
	get_parent().add_child(dart) 
	
	# Set Position to the ThrowPoint
	dart.global_position = throw_point.global_position
	
	# Determine Direction based on sprite facing
	var direction = -1 if animated_sprite.flip_h else 1
	
	# Launch dart using the function defined in Dart.gd
	dart.launch(direction) 


func _on_CooldownTimer_timeout():
	# Resets the flag, allowing the player to shoot again
	can_throw = true
