extends TextureButton

@onready var background = get_parent().get_child(0)
@onready var particles = [get_parent().get_child(1).get_child(0), get_parent().get_child(1).get_child(1)]
const HOVER_COLOR = Color(0.191, 0.045, 0.029, 1)
const REG_COLOR = Color(0.043, 0.043, 0.043, 1)
const PAR_HOVER_COLOR = Color(0.644, 0.235, 0.188, 1)
const PAR_REG_COLOR = Color(1, 1, 1, 1)

signal mouse_entered_sig
signal button_pressed_sig
signal open_status_changed(type: int, open: bool)

func _on_mouse_entered():
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
