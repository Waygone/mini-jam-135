extends Node2D

@export var next_scene : PackedScene

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		body.change_level(next_scene)
