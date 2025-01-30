extends AudioStreamPlayer2D

@onready var panner = AudioServer.get_bus_effect(3, 0)
@onready var tween: Tween = get_tree().create_tween()
var flag = false

func _ready():
	panner.pan = 0
	tween.tween_property(panner, "pan", -0.5, 6.4)
	tween.finished.connect(tween_timeout)

func _on_finished():
	play()

func tween_timeout():
	tween.kill()
	tween = get_tree().create_tween()
	tween.finished.connect(tween_timeout)
	tween.tween_property(panner, "pan", -0.5, 6.4) if flag else tween.tween_property(panner, "pan", 0.5, 6.4)
	flag = !flag
