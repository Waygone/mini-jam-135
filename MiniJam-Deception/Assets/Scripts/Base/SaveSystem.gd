extends Node

@export var level = 0

func _ready():
	if level == 0:
		Scoring.s_score = 0
		Scoring.s_gold = 0
		Scoring.s_enemies = 0
		Scoring.s_time = 0.0
#		var save_dict = {
#			"level" : 0,
#		}
#		var json_string = JSON.stringify(save_act)
#		save_data(json_string)aa



func save_data(json : String):
	var save_file = FileAccess.open("user://save_game.dat", FileAccess.WRITE)
	save_file.store_line(json)
	save_file.close()

func load_data(to_load: String) -> Dictionary:
	var save_game = FileAccess.open("user://save_game.dat", FileAccess.READ)
	while save_game.get_position() < save_game.get_lengths():
		var json_string = save_game.get_line()

		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		var data = json.get_data()
		if data["level"] == to_load:
			return data
		
	return {}
