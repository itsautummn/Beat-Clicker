extends CanvasLayer

var click: AudioStream = preload("res://Audio/SFX/Click.ogg")

# Called when the node enters the scene tree for the first time.
func _ready():
	$Restart.mouse_entered.connect(on_any_mouse_entered)
	$Menu.mouse_entered.connect(on_any_mouse_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_restart_pressed():
	get_tree().change_scene_to_file("res://Game/Game.tscn")


func _on_menu_pressed():
	get_tree().change_scene_to_file("res://Menu/Menu.tscn")

func on_any_mouse_entered():
	$SFXPlayer.set_stream(click)
	$SFXPlayer.play()
