extends TextureButton

@onready var parent = get_parent()
@onready var background = get_parent().get_child(0)
@onready var particles = [get_parent().get_child(1).get_child(0), get_parent().get_child(1).get_child(1)]
@onready var options_menu = $OptionsMenu
@onready var master_slider = $OptionsMenu/VolumeRect/VolumeSlider
@onready var sfx_slider = $OptionsMenu/VolumeRect/SFXSlider
@onready var music_slider = $OptionsMenu/VolumeRect/MusicSlider
@onready var master_value_label = $OptionsMenu/VolumeRect/VolumeSlider/VolumeValue
@onready var sfx_value_label = $OptionsMenu/VolumeRect/SFXSlider/VolumeValue
@onready var music_value_label = $OptionsMenu/VolumeRect/MusicSlider/VolumeValue

const HOVER_COLOR = Color(0.027, 0.106, 0.043, 1)
const REG_COLOR = Color(0.043, 0.043, 0.043, 1)
const PAR_HOVER_COLOR = Color(0.173, 0.396, 0.22, 1)
const PAR_REG_COLOR = Color(1, 1, 1, 1)

signal mouse_entered_sig
signal button_pressed_sig
signal open_status_changed(type: int, open: bool)

var openable = true

func _ready():
	AudioServer.set_bus_volume_db(0, linear_to_db(GlobalVariables.Settings['Volume']['Master']))
	AudioServer.set_bus_volume_db(1, linear_to_db(GlobalVariables.Settings['Volume']['Music']))
	AudioServer.set_bus_volume_db(2, linear_to_db(GlobalVariables.Settings['Volume']['SFX']))
	
	master_value_label.text = str(db_to_linear(AudioServer.get_bus_volume_db(0)) * 10)
	master_slider.set_value(db_to_linear(AudioServer.get_bus_volume_db(0)))
	
	sfx_value_label.text = str(db_to_linear(AudioServer.get_bus_volume_db(1)) * 10)
	sfx_slider.set_value(db_to_linear(AudioServer.get_bus_volume_db(1)))
	
	music_value_label.text = str(db_to_linear(AudioServer.get_bus_volume_db(2)) * 10)
	music_slider.set_value(db_to_linear(AudioServer.get_bus_volume_db(2)))
	
func _process(_delta):
	if options_menu.visible:
		position.x = 0
		background.color = HOVER_COLOR
		for i in particles:
			i.color = PAR_HOVER_COLOR

func _on_mouse_entered():
	if openable:
		if !options_menu.visible:
			mouse_entered_sig.emit()
			position.x = 0
			background.color = HOVER_COLOR
			for i in particles:
				i.color = PAR_HOVER_COLOR

func _on_mouse_exited():
	if !options_menu.visible:
		position.x = -128
		background.color = REG_COLOR
		for i in particles:
			i.color = PAR_REG_COLOR

func _on_pressed():
	if openable:
		options_menu.visible = !options_menu.visible
		button_pressed_sig.emit()
		open_status_changed.emit(parent.MENU_TYPE.OPTIONS, options_menu.visible)

func _on_options_menu_visibility_changed():
	position.x = 0 if options_menu.visible else -128

func _on_volume_slider_value_changed(value):
	master_value_label.text = str(value * 10)
	AudioServer.set_bus_volume_db(0, linear_to_db(value))
	GlobalVariables.Settings['Volume']['Master'] = value

func _on_sfx_slider_value_changed(value):
	sfx_value_label.text = str(value * 10)
	AudioServer.set_bus_volume_db(1, linear_to_db(value))
	GlobalVariables.Settings['Volume']['Music'] = value
	
func _on_music_slider_value_changed(value):
	music_value_label.text = str(value * 10)
	AudioServer.set_bus_volume_db(2, linear_to_db(value))
	GlobalVariables.Settings['Volume']['SFX'] = value


func _on_status_changed_for_menu(type, open):
	if type != parent.MENU_TYPE.OPTIONS:
		openable = !open
