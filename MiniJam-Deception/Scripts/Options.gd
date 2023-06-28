extends CanvasLayer

var is_paused = false:
	set(value):
		is_paused = value
	get:
		return is_paused


func _unhandled_input(event):
	if event.is_action_pressed("options"):
		self.is_paused = !is_paused
		visible = is_paused
		get_tree().paused = is_paused




func _on_back_pressed():
	visible = false
	get_tree().paused = false
