extends Control

func _on_Back_pressed():
	visible = false


func _on_Next_pressed():
	$"Credits pg1".visible = false
	$pg1.visible = false
	$"Credits pg2".visible = true
	$pg2.visible = true


func _on_Previous_pressed():
	$"Credits pg1".visible = true
	$pg1.visible = true
	$"Credits pg2".visible = false
	$pg2.visible = false
