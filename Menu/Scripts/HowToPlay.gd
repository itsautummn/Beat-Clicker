extends TextureButton

const REG_COLOR = Color(0.008, 0.094, 0.153, 1)
const HOVER_COLOR = Color(0.091, 0.388, 0.561, 1)

signal mouse_entered_sig
signal button_pressed_sig

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pressed():
	$CanvasLayer.visible = true
	button_pressed_sig.emit()

func _on_mouse_entered():
	mouse_entered_sig.emit()
	$ColorRect.color = HOVER_COLOR


func _on_mouse_exited():
	$ColorRect.color = REG_COLOR
