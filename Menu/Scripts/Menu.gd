extends Node2D

enum MENU_TYPE
{
	PLAY = 0, 
	OPTIONS = 1,
	CREDITS = 2
}

var click: AudioStream = preload("res://Audio/SFX/Click.ogg")
var bingbong: AudioStream = preload("res://Audio/SFX/Bingbong_fx.ogg")

@onready var sfx_player = $SFXPlayer
@onready var music_player = $MusicPlayer
@onready var background = $Background

var play_menu_open = false
var options_menu_open = false
var credits_menu_open = false

var music_volume_tween: Tween

signal status_changed_for_menu(type: int, open: bool)

# Called when the node enters the scene tree for the first time.
func _ready():
	background.color = Color(0.043, 0.043, 0.043, 1)
	for i in get_children(false):
		if i.is_class("TextureButton"):
			i.mouse_entered_sig.connect(_on_any_button_mouse_entered)
			i.button_pressed_sig.connect(_on_any_button_pressed)
			i.open_status_changed.connect(on_menu_status_changed)
	for i in $PlayButton/LevelSelect.get_children(false):
		if i.is_class("TextureButton"):
			i.mouse_entered_sig.connect(_on_any_button_mouse_entered)
			i.button_pressed_sig.connect(_on_any_button_pressed)
			if not i.is_in_group("how to"):
				i.playing_sample.connect(lower_music_volume)
				i.stopped_sample.connect(raise_music_volume)

func _on_any_button_mouse_entered():
	sfx_player.set_stream(click)
	sfx_player.play()

func _on_any_button_pressed():
	sfx_player.set_stream(bingbong)
	sfx_player.play()

func on_menu_status_changed(type: int, open: bool):
	if type == MENU_TYPE.PLAY:
		play_menu_open = open
		status_changed_for_menu.emit(MENU_TYPE.PLAY, play_menu_open)
	elif type == MENU_TYPE.OPTIONS:
		options_menu_open = open
		status_changed_for_menu.emit(MENU_TYPE.OPTIONS, options_menu_open)
	elif type == MENU_TYPE.CREDITS:
		credits_menu_open = open
		status_changed_for_menu.emit(MENU_TYPE.CREDITS, credits_menu_open)

func lower_music_volume():
	if music_volume_tween != null:
		music_volume_tween.kill()
	music_volume_tween = create_tween()
	music_volume_tween.tween_property(music_player, "volume_db", -80, 2)
	
func raise_music_volume():
	if music_volume_tween != null:
		music_volume_tween.kill()
	music_volume_tween = create_tween()
	music_volume_tween.tween_property(music_player, "volume_db", 0, 1)

func exit():
	GlobalVariables.SaveGame()
	get_tree().quit()
