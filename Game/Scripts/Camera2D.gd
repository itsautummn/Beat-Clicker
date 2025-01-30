extends Camera2D

@export var player: Node2D
@onready var follow_node = player.get_parent()

var zoom_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position.x = follow_node.progress + 448


func _on_little_guy_parent_changed():
	follow_node = player.get_parent()


func _on_little_guy_player_clicked():
	if zoom_tween != null:
		zoom_tween.kill()
	zoom = Vector2(1.05, 1.05)
	zoom_tween = get_tree().create_tween()
	zoom_tween.tween_property(self, "zoom", Vector2(1, 1), .5)
