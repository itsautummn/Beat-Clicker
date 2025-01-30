extends Control

@onready var label = $Label
@onready var tween = get_tree().create_tween()

var score_text: String
var self_pos: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	self.position = self_pos
	label.text = score_text
	label.position.y = 50
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "position", Vector2(0, -20), .1)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "position", Vector2(0, 0), 1)
	tween.tween_property(self, "visible", false, 0)

func initialize(score: int, pos: Vector2):
	self_pos = pos
	match score:
		0:
			score_text = "MISS"
		1:
			score_text = "OKAY"
		2:
			score_text = "GOOD"
		3:
			score_text = "PERFECT!"
