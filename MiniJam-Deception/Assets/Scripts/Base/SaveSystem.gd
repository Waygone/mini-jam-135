extends Node

var config
var PBA : PackedByteArray

func _ready():
	config = ConfigFile.new()
	config.load("user://points_save.cfg")  # Load the save file

func save_points(level_name: String, points: int):
	config.set_value(level_name, points)
	config.save("user://points_save.cfg") #Save changes to file

func load_points(level_name: String) -> int:
	return config.get_value(level_name, 0)
