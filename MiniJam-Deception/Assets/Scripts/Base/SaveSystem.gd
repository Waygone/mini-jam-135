extends Node

func save_points(level_name: String, points: int):
	var save_file = FileAccess.open("user://save_game.dat", FileAccess.WRITE)
	save_file.store_line(level_name + "=" + str(points))
	save_file.close()

func load_points(level_name: String) -> int:
	var save_file = FileAccess.open("user://save_game.dat", FileAccess.READ)
	
	if FileAccess.file_exists("user://save_game.dat"):
		save_file.open("user://save_game.dat", FileAccess.READ)
		while !save_file.eof_reached():
			var line = save_file.get_line().strip_edges()
			print(line)
			if line.begins_with(level_name + "="):
				var points_str = line.split("=")[1]
				save_file.close()
				return points_str.to_int()
		save_file.close()

	return 0
