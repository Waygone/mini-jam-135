extends Node2D

@export var amount = 100.0

func _ready():
	$AnimationPlayer.play("Default")

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		body.add_gold(amount)
		queue_free()
