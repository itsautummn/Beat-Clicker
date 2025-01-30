extends Node2D

@onready var a = $Beat/a
@onready var asp = $AudioStreamPlayer2D
var zoomed = true
var tween: Tween
var a_tween: Tween
var rotate_amount = 0.1

var LittleGuySounds = [preload("res://Audio/SFX/clownhonk.ogg"), preload("res://Audio/SFX/bruh.ogg"), preload("res://Audio/SFX/wilhelm.ogg")]

var little_guy_sound: AudioStream

# Called when the node enters the scene tree for the first time.
func _ready():
	tween = get_tree().create_tween()
	tween_zoom() # First tween
	little_guy_sound = LittleGuySounds[randi() % 3]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func tween_zoom():
	self.rotation = rotate_amount
	if tween != null:
		tween.kill()
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.finished.connect(_on_tween_finished)
	tween.tween_property(self, "scale", Vector2(.85, .85), 4)
	tween.parallel().tween_property(self, "rotation", -rotate_amount, 4)
	zoomed = false

func tween_unzoom():
	self.rotation = -rotate_amount
	if tween != null:
		tween.kill()
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.finished.connect(_on_tween_finished)
	tween.tween_property(self, "scale", Vector2(.75, .75), 4)
	tween.parallel().tween_property(self, "rotation", rotate_amount, 4)
	zoomed = true

func _on_texture_button_pressed():
	if a_tween != null:
		a_tween.kill()
	a.position = Vector2(0, 0)
	a_tween = get_tree().create_tween()
	asp.set_stream(little_guy_sound)
	asp.play()
	a_tween.tween_property(a, "position", Vector2(0, -32), .05)
	a_tween.tween_property(a, "position", Vector2(0, 0), .05)

func _on_tween_finished():
	tween_zoom() if zoomed else tween_unzoom()
