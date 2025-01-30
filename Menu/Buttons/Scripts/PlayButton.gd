extends TextureButton

@onready var parent = get_parent()
@onready var background = get_parent().get_child(0)
@onready var particles = [get_parent().get_child(1).get_child(0), get_parent().get_child(1).get_child(1)]
@onready var level_select = $LevelSelect

const HOVER_COLOR = Color(0.008, 0.094, 0.153, 1)
const REG_COLOR = Color(0.043, 0.043, 0.043, 1)
const PAR_HOVER_COLOR = Color(0.091, 0.388, 0.561, 1)
const PAR_REG_COLOR = Color(1, 1, 1, 1)

signal mouse_entered_sig
signal button_pressed_sig
signal open_status_changed(type: int, open: bool)

var openable = true

func _on_mouse_entered():
	if openable:
		mouse_entered_sig.emit()
		position.x = 0
		background.color = HOVER_COLOR
		for i in particles:
				i.color = PAR_HOVER_COLOR

func _on_mouse_exited():
	position.x = -128
	background.color = REG_COLOR
	for i in particles:
			i.color = PAR_REG_COLOR

func _process(_delta):
	if level_select.visible:
		position.x = 0
		background.color = HOVER_COLOR
		for i in particles:
			i.color = PAR_HOVER_COLOR

func _on_pressed():
	if openable:
		level_select.visible = !level_select.visible
		button_pressed_sig.emit()
		open_status_changed.emit(parent.MENU_TYPE.PLAY, level_select.visible)

func _on_level_select_visibility_changed():
	position.x = 0 if level_select.visible else -128



func _on_status_changed_for_menu(type, open):
	if type != parent.MENU_TYPE.PLAY:
		openable = !open
