extends Control


func _on_start_pressed():
	get_tree().change_scene_to_file("res://Assets/Scenes/Level.tscn")


func _on_options_pressed():
	$Options.visible = true


func _on_credits_pressed():
	get_tree().change_scene_to_file("res://Scenes/Credits.tscn")
