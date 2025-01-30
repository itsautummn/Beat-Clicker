extends TextureButton

enum LEVELS_ENUM
{
	TUTORIAL = 0,
	LEVEL_ONE = 1
}

enum DIFFICULTY_ENUM
{
	EASY = 0,
	MEDIUM = 1,
	HARD = 2,
	INSANE = 3,
	IMPOSSIBLE = 4
}

var CHARTS = {
	"Tutorial" = {
		"Easy" = "res://Charts/Tuteasy.mid",
		"Medium" = "res://Charts/Tutmed.mid",
		"Hard" = "res://Charts/Tuthard.mid"
	},
	
	"Level One" = {
		"Easy" = "res://Charts/VerEASY.mid",
		"Medium" = "res://Charts/Vermid.mid",
		"Hard" = "res://Charts/Vertotal.mid"
	}
}

@export_group("Button Visuals")
@export var level_name: String
@export var track: AudioStream

@export_group("Behind the Scenes")
@export var Level: LEVELS_ENUM

var midi_file: String
var difficulty = DIFFICULTY_ENUM.EASY
var this_level: String

@onready var difficulty_select = $DifficultySelect
@onready var name_label = $Shape/Name/Label
@onready var difficulty_label = $Shape/Difficulty/Label
@onready var time_label = $Shape/Time/Label
@onready var score_label = $Shape/Score/Label
@onready var asp = $AudioStreamPlayer2D
@onready var shape_node = $Shape
@onready var difficulty_rect = $Shape/Difficulty/ColorRect
@onready var level_button = [$Shape/Name/ColorRect, $Shape/Time/ColorRect, $Shape/Score/ColorRect]

var volume_tween: Tween

const REG_COLOR = Color(0.008, 0.094, 0.153, 1)
const HOVER_COLOR = Color(0.091, 0.388, 0.561, 1)
const EASY_COLOR = Color(0.027, 0.106, 0.043, 1)
const EASY_HOVER_COLOR = Color(.135, .325, .176, 1)
const MEDIUM_COLOR = Color(0.173, 0.063, 0.184, 1)
const MEDIUM_HOVER_COLOR = Color(.463, .22, .487, 1)
const HARD_COLOR = Color(0.191, 0.045, 0.029, 1)
const HARD_HOVER_COLOR = Color(.488, .167, .13, 1)

const PATH_TO_LEVEL = "res://Game/Game.tscn"

var current_difficulty_reg_color: Color
var current_difficulty_hover_color: Color

signal playing_sample
signal stopped_sample
signal mouse_entered_sig
signal button_pressed_sig

func _ready():
	change_shape_color(REG_COLOR)
	name_label.text = level_name
	asp.stream = track
	if track != null:
		time_label.text = "Time: " + seconds_to_minutes(asp.stream.get_length())
	match Level:
		LEVELS_ENUM.TUTORIAL:
			this_level = "Tutorial"
			score_label.text = "Score: " + str(GlobalVariables.Scores['Tutorial']['total_score'])
		LEVELS_ENUM.LEVEL_ONE:
			this_level = "Level One"
			score_label.text = "Score: " + str(GlobalVariables.Scores['LevelOne']['total_score'])
	check_difficulty()

func _on_pressed():
	button_pressed_sig.emit()
	GlobalVariables.LevelSelect['level'] = Level
	GlobalVariables.LevelSelect['song'] = asp.stream
	GlobalVariables.LevelSelect['midi'] = midi_file
	get_tree().change_scene_to_file(PATH_TO_LEVEL)

func _on_mouse_entered():
	mouse_entered_sig.emit()
	change_shape_color(HOVER_COLOR)
	if track != null:
		play_sample_song()
	
func _on_mouse_exited():
	stopped_sample.emit()
	change_shape_color(REG_COLOR)
	asp.stop()

func change_shape_color(color: Color):
	for i in level_button:
		i.color = color

func play_sample_song():
	playing_sample.emit()
	if volume_tween != null:
		volume_tween.kill()
	volume_tween = create_tween()
	asp.volume_db = -80
	volume_tween.tween_property(asp, "volume_db", -20, 2)
	asp.play()

func seconds_to_minutes(seconds: float) -> String:
	seconds = floor(seconds)
	var minutes = seconds / 60
	var n_min = floor(minutes)
	var n_sec = (minutes - n_min) * 60
	var r_min = str(n_min) + ":" + str(n_sec)
	return r_min

func check_difficulty():
	match difficulty:
		DIFFICULTY_ENUM.EASY:
			difficulty_label.text = "Easy"
			difficulty_rect.color = EASY_COLOR
			current_difficulty_reg_color = EASY_COLOR
			current_difficulty_hover_color = EASY_HOVER_COLOR
			midi_file = CHARTS[this_level]["Easy"]
		DIFFICULTY_ENUM.MEDIUM:
			difficulty_label.text = "Medium"
			difficulty_rect.color = MEDIUM_COLOR
			current_difficulty_reg_color = MEDIUM_COLOR
			current_difficulty_hover_color = MEDIUM_HOVER_COLOR
			midi_file = CHARTS[this_level]["Medium"]
		DIFFICULTY_ENUM.HARD:
			difficulty_label.text = "Hard"
			difficulty_rect.color = HARD_COLOR
			current_difficulty_reg_color = HARD_COLOR
			current_difficulty_hover_color = HARD_HOVER_COLOR
			midi_file = CHARTS[this_level]["Hard"]
		_:
			difficulty_label.text = "UNCHARTED"
			difficulty_rect.color = EASY_COLOR
			current_difficulty_reg_color = EASY_COLOR
			current_difficulty_hover_color = EASY_HOVER_COLOR
			midi_file = CHARTS[this_level]["Easy"]

func _on_difficulty_pressed():
	difficulty_select.visible = !difficulty_select.visible


func _on_increase_pressed():
	if difficulty < DIFFICULTY_ENUM.HARD:
		difficulty += 1
	check_difficulty()

func _on_decrease_pressed():
	if difficulty > DIFFICULTY_ENUM.EASY:
		difficulty -= 1
	check_difficulty()


func _on_difficulty_mouse_entered():
	difficulty_rect.color = current_difficulty_hover_color


func _on_difficulty_mouse_exited():
	difficulty_rect.color = current_difficulty_reg_color
