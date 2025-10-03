extends Node2D

const speed = 60

var direction = 1

@onready var right = $right
@onready var left = $left
@onready var animated_sprite = $AnimatedSprite2D

func _process(delta):
	if right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	position.x += direction * speed * delta
