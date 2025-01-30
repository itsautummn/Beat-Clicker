extends Node

enum LEVELS_ENUM
{
	Tutorial = 0,
	LevelOne = 1,
}

var GameLoaded = false

# Dictionary that's used to load levels
var LevelSelect = {
	"level": null,
	"song": null,
	"midi": "" # Gets converted to a midi file in the level
}

# Dictionary that keeps track of each levels stats
var Scores = {
	# Subdictionary to keep track of Tutorial level stats
	"Tutorial" = {
		"total_score" = 0,
		"max_combo" = 0,
		"percentage" = 0.0
	},
	
	# Subdictionary to keep track of Level One stats
	"LevelOne" = {
		"total_score" = 0,
		"max_combo" = 0,
		"percentage" = 0.0
	}
}

# Dictionary thats used to keep track of settings
var Settings = {
	# Volume Settings
	"Volume" = {
		"Master" = 1,
		"Music" = 1,
		"SFX" = 1
	},
	
	# Score display settings
	"Score Display" = {
		"Score" = true,
		"Hit Type" = true
	},
	
	# Modifier Settings
	"Modifiers" = {
		"Health" = false
	}
}

func _ready():
	if GameLoaded == false:
		LoadGame()
		GameLoaded = true

func SaveGame():
	var file = FileAccess.open("user://save_data.save", FileAccess.WRITE)
	# Score data
	file.store_var(Scores['Tutorial']['total_score'])
	file.store_var(Scores['LevelOne']['total_score'])
	file.store_var(Scores['Tutorial']['max_combo'])
	file.store_var(Scores['LevelOne']['max_combo'])
	# Volume data
	file.store_var(Settings['Volume']['Master'])
	file.store_var(Settings['Volume']['Music'])
	file.store_var(Settings['Volume']['SFX'])
	# Display data
	file.store_var(Settings['Score Display']['Score'])
	file.store_var(Settings['Score Display']['Hit Type'])
	# Modifier data
	file.store_var(Settings['Modifiers']['Health'])

func LoadGame():
	if FileAccess.file_exists("user://save_data.save"):
		var file = FileAccess.open("user://save_data.save", FileAccess.READ)
		# Score data
		Scores['Tutorial']['total_score'] = file.get_var()
		Scores['LevelOne']['total_score'] = file.get_var()
		Scores['Tutorial']['max_combo'] = file.get_var()
		Scores['LevelOne']['max_combo'] = file.get_var()
		# Volume data
		Settings['Volume']['Master'] = file.get_var()
		Settings['Volume']['Music'] = file.get_var()
		Settings['Volume']['SFX'] = file.get_var()
		# Display data
		Settings['Score Display']['Score'] = file.get_var()
		Settings['Score Display']['Hit Type'] = file.get_var()
		# Modifier data
		Settings['Modifiers']['Health'] = file.get_var()
