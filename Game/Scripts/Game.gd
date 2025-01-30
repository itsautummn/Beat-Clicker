extends Node

@onready var asp = $Camera2D/AudioStreamPlayer2D
@onready var midi_player = $GodotMidiPlayer
@onready var background = $BackgroundLayer/Background
@onready var border =  $BackgroundLayer/Border
@onready var path_track = $Tracks/Track1/NoteFollow
@onready var hud = $HUD
@onready var combo_label = $HUD/ComboScore
@onready var combo_score_label = $HUD/ComboScore/Combo
@onready var current_score_node = $HUD/CurrentScore
@onready var current_score = $HUD/CurrentScore/Score
@onready var all_scores = $HUD/Scores
@onready var perfect_score = $HUD/Scores/PerfectScore/Score
@onready var good_score = $HUD/Scores/GoodScore/Score
@onready var okay_score = $HUD/Scores/OkayScore/Score
@onready var missed_score = $HUD/Scores/MissedScore/Score
@onready var health_bar = $HUD/HealthBar
@onready var music_note = preload("res://Game/Notes/MusicNote.tscn")
@onready var hold_note = preload("res://Game/Notes/HoldNote.tscn")
@onready var barrier_note = preload("res://Game/Notes/Barrier.tscn")
@onready var hit_score_label = preload("res://Game/HitShowLabel.tscn")

const COMBO_HIT = Vector2(1.2, 1.2)
const COMBO_REG = Vector2(1, 1)

# The little thing that shows at the bottom of the screen with PERFECT!
var last_hit_label_instance

# Current Run Variables
var score = 0
var combo = 0

# Overall Run Variables
var max_combo = 0
var perfect = 0
var good = 0
var okay = 0
var missed = 0

var tween: Tween
var border_tween: Tween
var has_paused = false

var current_level = GlobalVariables.LevelSelect['level']

var pixel_per_second = 1000 # Number of pixels the player moves in a second

signal level_loaded
signal damage_taken
signal health_gained

# Desc:   Places all the music note instances along the path specified by the
#         midi notes 'note' data % 3.
# How it works: 
#         1) Loop through the first time to get all the notes to place and the total 
#         length of the track
#         2) Loop through a second time to place all hold notes first, as these 
#         require knowing both when a note starts and when the note ends
#         3) Loop through a third and final time to place all the regular notes
# Input:  First frame of entire scene
# Output: All notes placed along correct paths
func _ready():
	# Setting Up Level
	asp.stream = GlobalVariables.LevelSelect['song']
	midi_player.file = GlobalVariables.LevelSelect['midi']
	var track_pos_x = int(asp.stream.get_length()) * pixel_per_second
	$Tracks/Track1.curve.set_point_position(1,  Vector2(track_pos_x, 192))
	$Tracks/Track2.curve.set_point_position(1, Vector2(track_pos_x, 320))
	$Tracks/Track3.curve.set_point_position(1,  Vector2(track_pos_x, 448))
	
	current_score_node.visible = GlobalVariables.Settings['Score Display']['Score']
	all_scores.visible = GlobalVariables.Settings['Score Display']['Hit Type']
	health_bar.visible = GlobalVariables.Settings['Modifiers']['Health']
	
	path_track.progress_ratio = 1
	
	var total_length = asp.stream.get_length()
	var current_placer: PathFollow2D
	var all_notes = [] # Stores the data of each note
	var hold_notes = [] # Stores the 'time' data of each hold note
	var barrier_notes = [] # Stores the data of each barrier note
	var midi_file = midi_player.file
	var midi = load(midi_file)
	
	# First loop: Get total time and add notes to an array
	for track in midi.tracks:
		for event in track.events:
			if event.type == "note":
				# If its the melody track and the note doesn't already exist 
				# in the array:
				if not all_notes.has(event) and track.name == "Notes":
					all_notes.append(event)
				elif track.name == "Barriers" and event.subtype == 9:
					barrier_notes.append(event)
	
	# Second loop: Place all hold notes
	# IMPORTANT NOTE: A subtype of 8 is a 'note off' event, 9 is a 'note on' event
	var previous_note
	var last_on_note
	for i in all_notes:
		current_placer = _get_current_placer(i)
		# Get the length between the previous note start and this note, 
		# if it's greater than an abritrary number AND no note off
		# signals have been sent, then the previous note is a hold 
		# note for the duration calculated
		if last_on_note != null:
			if i.subtype == 8:
				if i.time - last_on_note.time > .5:
					hold_notes.append(last_on_note.time)
					spawn_hold_note(current_placer, total_length, last_on_note.time, i.time)
		# If our current note subtype is 9 (note on), and our previous note 
		# is not null AND its subtype is 8 (note off), then this is a new note 
		# and is now our last on note for next iteration
		if i.subtype == 9:
			if last_on_note == null:
				last_on_note = i
			else:
				if previous_note != null:
					if previous_note.subtype == 8:
						last_on_note = i
		previous_note = i
	
	# Third loop: Place all regular notes
	for i in all_notes:
		if hold_notes.has(i.time):
			continue
		else:
			if i.subtype == 9:
				current_placer = _get_current_placer(i)
				if not hold_notes.has(i.time):
					spawn_reg_note(current_placer, total_length, i.time)
	
	# Fourth loop: Place all barrier notes
	for i in barrier_notes:
		current_placer = _get_current_placer(i)
		spawn_barrier_note(current_placer, total_length, i.time)
	
	await get_tree().create_timer(2).timeout
	level_loaded.emit()
	asp.play()

func _get_current_placer(note) -> PathFollow2D:
	var placer: PathFollow2D
	if note.note % 3 == 0:
		placer = $Tracks/Track1/Placer
	elif note.note % 3 == 1:
		placer = $Tracks/Track2/Placer
	elif note.note % 3 == 2:
		placer = $Tracks/Track3/Placer 
	return placer

# Desc:   Spawns a regular note at a positon based on 'total_length' 
#         and the notes "time" data
# Param:  current_placer - The PathFollow2D node to place notes on
#         total_length - The total length of the track
#         note - The current midi note we are placing a music note on
# Output: A regular note will be placed on the correct path at the correct time
func spawn_reg_note(placer: PathFollow2D, total_length: float, place_time: float):
	placer.progress_ratio = place_time / total_length
	var instance = music_note.instantiate()
	path_track.add_child(instance)
	instance.global_position = placer.global_position
	instance.destroyed.connect(_on_note_destroyed)

# Desc:   Spawns a hold note at a positon based on 'total_length' 
#         and the notes "time" data, and ends it using the same parameters
# Param:  current_placer - The PathFollow2D node to place notes on
#         total_length - The total length of the track
#         note - The current midi note we are placing a music note on
# Output: A hold note will be placed on the correct path at the correct time
func spawn_hold_note(placer: PathFollow2D, total_length: float, hold_from: float, hold_to: float):
	placer.progress_ratio = hold_from / total_length # Start of note
	var pixel_hold_from = placer.progress
	var instance = hold_note.instantiate()
	path_track.add_child(instance)
	instance.global_position = placer.global_position
	# The distance to 'hold to' is calulated from the placers pixel progress
	placer.progress_ratio = hold_to / total_length
	var pixel_hold_length = placer.progress - pixel_hold_from
	instance.initialize(pixel_hold_length, hold_to - hold_from)
	instance.destroyed.connect(_on_note_destroyed)

# Desc:   Spawns a barrier note at a positon based on 'total_length' 
#         and the notes "time" data
# Param:  current_placer - The PathFollow2D node to place notes on
#         total_length - The total length of the track
#         note - The current midi note we are placing a music note on
# Output: A barrier note will be placed on the correct path at the correct time
func spawn_barrier_note(placer: PathFollow2D, total_length: float, place_time: float):
	placer.progress_ratio = place_time / total_length
	var instance = barrier_note.instantiate()
	path_track.add_child(instance)
	instance.global_position = placer.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
# Desc:   
# Input:  
# Output: 
func _process(delta):
	pass

func _input(event):
	if event.is_action("Escape"):
		update_globals()
		get_tree().change_scene_to_file("res://Menu/Menu.tscn")

func increment_score(by):
	if by > 0:
		combo_label_effect()
		combo += 1
		health_gained.emit()
		match by:
			1:
				okay += 1
			2:
				good += 1
			3: 
				perfect += 1
	else:
		combo = 0
		missed += 1
		damage_taken.emit()
		flash_border()
	combo_score_label.text = str(combo)
	if last_hit_label_instance != null:
		last_hit_label_instance.queue_free()
	var instance = hit_score_label.instantiate()
	instance.initialize(by, Vector2(592, 496))
	hud.add_child(instance)
	last_hit_label_instance = instance
	if GlobalVariables.Settings['Modifiers']['Health'] == true:
		by = int(by * 1.5)
	score += by
	set_scores()

func set_scores():
	current_score.text = str(score)
	perfect_score.text = str(perfect)
	good_score.text = str(good)
	okay_score.text = str(okay)
	missed_score.text = str(missed)

func combo_label_effect():
	if tween != null:
			tween.kill()
	tween = get_tree().create_tween()
	combo_label.scale = COMBO_HIT
	tween.tween_property(combo_label, "scale", COMBO_REG, 0.5)


func _on_asp_finished():
	update_globals()
	get_tree().change_scene_to_file("res://Menu/Menu.tscn")

func _on_note_destroyed():
	increment_score(0)

func flash_border():
	if border_tween != null:
		border_tween.kill()
	border_tween = get_tree().create_tween()
	border.color = Color(.829, 0, .009, .5)
	border_tween.tween_property(border, "color", Color(.043, .043, .043, 1), 1)

func update_globals():
	match current_level:
		GlobalVariables.LEVELS_ENUM.Tutorial:
			if score > GlobalVariables.Scores['Tutorial']['total_score']:
				GlobalVariables.Scores['Tutorial']['total_score'] = score
			if score > GlobalVariables.Scores['Tutorial']['max_combo']:
				GlobalVariables.Scores['Tutorial']['max_combo'] = max_combo
		GlobalVariables.LEVELS_ENUM.LevelOne:
			if score > GlobalVariables.Scores['LevelOne']['total_score']:
				GlobalVariables.Scores['LevelOne']['total_score'] = score
			if score > GlobalVariables.Scores['LevelOne']['max_combo']:
				GlobalVariables.Scores['LevelOne']['max_combo'] = max_combo
