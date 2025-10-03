extends Area2D



func _on_body_entered(body):
	print("You Died!")
	get_tree().change_scene_to_file("res://Scene/died.tscn")
