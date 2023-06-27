extends Node2D


func open():
	$CollisionShape2D.set_deferred("disabled", true)
