extends ProgressBar


# Called when the node enters the scene tree for the first time.
func _ready():
	value = 100

func _on_damage_taken():
	if self.visible:
		value -= 5
		if value <= 0:
			scene_switcher.call_deferred("res://Game/DeathScreen.tscn")

func _on_health_gained():
	if self.visible:
		value += 2

func scene_switcher(path: String):
	get_tree().change_scene_to_file(path)
