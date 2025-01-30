extends TextureButton

enum TYPE
{
	Score,
	Hit,
	Health,
}

@export var type: TYPE
@export var text: String

var on: bool
var setting1
var setting2

const PRESS_COLOR = Color(0.027, 0.106, 0.043, 1)
const REG_COLOR = Color(0.043, 0.043, 0.043, 1)

# Called when the node enters the scene tree for the first time.
func _ready():
	match type:
		TYPE.Score:
			setting1 = 'Score Display'
			setting2 = 'Score'
		TYPE.Hit:
			setting1 = 'Score Display'
			setting2 = 'Hit Type'
		TYPE.Health:
			setting1 = 'Modifiers'
			setting2 = 'Health'
	
	on = GlobalVariables.Settings[setting1][setting2]
	$Label.text = text
	
	if on:
		$ColorRect.color = PRESS_COLOR
		$Sprite2D.visible = true
	else:
		$ColorRect.color = REG_COLOR
		$Sprite2D.visible = false

func _on_pressed():
	if on:
		$ColorRect.color = REG_COLOR
		$Sprite2D.visible = false
	else:
		$ColorRect.color = PRESS_COLOR
		$Sprite2D.visible = true
	on = !on
	GlobalVariables.Settings[setting1][setting2] = on
	
