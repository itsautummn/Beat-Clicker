extends PathFollow2D

@export var asp: AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	progress_ratio = 1 - (asp.get_playback_position() / asp.stream.get_length())
