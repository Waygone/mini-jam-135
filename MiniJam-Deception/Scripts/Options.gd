extends CanvasLayer


func _on_back_pressed():
	visible = false
	get_tree().paused = false
