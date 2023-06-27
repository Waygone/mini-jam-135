extends Control

@export var first_level : PackedScene

@onready var highscore = $MarginContainer/ScoresVContainer/HighscoreContainer/highscore
@onready var score = $MarginContainer/ScoresVContainer/ScoreContainer/score

@onready var score_gold = $MarginContainer/ScoresVContainer/ScoreContainer/HBoxContainer/gold
@onready var highscore_gold = $MarginContainer/ScoresVContainer/HighscoreContainer/HBoxContainer/gold

@onready var score_enemies = $MarginContainer/ScoresVContainer/ScoreContainer/HBoxContainer/enemies
@onready var highscore_enemies = $MarginContainer/ScoresVContainer/HighscoreContainer/HBoxContainer/enemies

@onready var score_time = $MarginContainer/ScoresVContainer/ScoreContainer/HBoxContainer/time
@onready var highscore_time = $MarginContainer/ScoresVContainer/HighscoreContainer/HBoxContainer/time


@onready var black_screen = $ScreenEffects/FadeToBlackScreen
var b_screen_tween : Tween


var texts_dictionary = {}

func _ready():
	
	texts_dictionary[score] = "score"
	texts_dictionary[score_gold] = "score_gold"
	texts_dictionary[score_enemies] = "score_enemies"
	texts_dictionary[score_time] = "score_time"

	texts_dictionary[highscore] = "highscore"
	texts_dictionary[highscore_gold] = "highscore_gold"
	texts_dictionary[highscore_enemies] = "highscore_enemies"
	texts_dictionary[highscore_time] = "highscore_time"
	
	load_texts()

func load_texts():
	var string_score = "%3.2f"
	var string_time = "TIME: %3.3fs"
	var string_gold = "GOLD COLLECTED: x%d"
	var string_enemies = "ENEMIES KILLED: %d"
	
	score.text = string_score % Scoring.s_score
	score_time.text = string_time % Scoring.s_time
	score_gold.text = string_gold % Scoring.s_gold 
	score_enemies.text = string_enemies % Scoring.s_enemies
	
	highscore.text = string_score % Scoring.hs_highscore
	highscore_time.text = string_time % Scoring.hs_time
	highscore_gold.text = string_gold % Scoring.hs_gold
	highscore_enemies.text = string_enemies % Scoring.hs_enemies
#	var save_file
#	if FileAccess.file_exists("user://save_game.dat"):
#		for i in texts_dictionary:
#			save_file = FileAccess.open("user://save_game.dat", FileAccess.READ)
#			while !save_file.eof_reached():
#				var line = save_file.get_line().strip_edges()
#				print(texts_dictionary[i] + " "+line)
#				if line.begins_with(texts_dictionary[i] + "="):
#					var found = line.split("=")[1]
#					print("found")
#					i.text = found
#		save_file.close()



func _on_button_pressed():
	print("first level")
	get_tree().change_scene_to_file("res://Assets/Scenes/Level.tscn")
