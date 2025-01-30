extends TextureButton

@onready var parent = get_parent()
@onready var background = get_parent().get_child(0)
@onready var particles = [get_parent().get_child(1).get_child(0), get_parent().get_child(1).get_child(1)]
@onready var credits_menu = $CreditsMenu

const HOVER_COLOR = Color(0.173, 0.063, 0.184, 1)
const REG_COLOR = Color(0.043, 0.043, 0.043, 1)
const PAR_HOVER_COLOR = Color(0.427, 0.2, 0.451, 1)
const PAR_REG_COLOR = Color(1, 1, 1, 1)

var openable = true

signal mouse_entered_sig
signal button_pressed_sig
signal open_status_changed(type: int, open: bool)

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


func _on_pressed():
	if openable:
		button_pressed_sig.emit()
		credits_menu.visible = !credits_menu.visible
		open_status_changed.emit(parent.MENU_TYPE.CREDITS, credits_menu.visible)

func _process(_delta):
	if credits_menu.visible:
		position.x = 0
		background.color = HOVER_COLOR
		for i in particles:
			i.color = PAR_HOVER_COLOR


func _on_status_changed_for_menu(type, open):
	if type != parent.MENU_TYPE.CREDITS:
		openable = !open
