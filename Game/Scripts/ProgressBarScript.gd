extends ProgressBar

@export var asp: AudioStreamPlayer2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	value = asp.get_playback_position() / asp.stream.get_length() * 100
