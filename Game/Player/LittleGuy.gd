extends Node2D

var perfect = false
var good = false
var okay = false
var last_note = null
var last_hold_note = null
var current_note = null

@export var speed = 0.1
@export var game: Node2D

@onready var current_line = get_parent().get_parent()
@onready var current_track = get_parent()
@onready var ray = $RayCast2D
@onready var hold_particles = $HoldParticles
@onready var timer = $Timer
@onready var tp_up = $TPUp
@onready var tp_down = $TPDown

var hit = false

# HOLD NOTE VARIABLES
var holding_note = false
var left_click_down = false
var player_moved = false
var timer_finished = false

# BARRIER NOTES
var in_barrier = false

var yes_animate_pwease = false

signal parent_changed
signal player_clicked

signal held_all_the_way
signal not_held_all_the_way

func _ready():
	pass

# Only handle hold notes
func _process(delta):
	if holding_note == true: # If currently holding note
		hold_particles.emitting = true
		if left_click_down == false: # And player isn't holding left click
			game.increment_score(0) # Player bailed out of hold
			not_held_all_the_way.emit()
			_reset_hold_bools()
			return
		else: # If player is holding left click, go until timer is finished
			if timer_finished: # If held all the way
				held_all_the_way.emit()
				_reset_hold_bools()
				return
			if player_moved: # If player moved during hold
				game.increment_score(0)
				not_held_all_the_way.emit()
				_reset_hold_bools()
				return

func _reset_hold_bools():
	holding_note = false
	player_moved = false
	timer_finished = false
	hold_particles.emitting = false
	if last_hold_note != null:
		last_hold_note.timer.stop()
	if current_note != null:
		current_note.timer.stop()

func _unhandled_input(event):
	if event.is_action_pressed("Up"):
		player_move_up()
		
	elif event.is_action_pressed("Down"):
		player_move_down()
		
	if event.is_action_pressed("Click"):
		player_click(event)
		left_click_down = true
	if event.is_action_released("Click"):
		left_click_down = false

func player_move_up():
	ray.position.y = -32
	ray.target_position = Vector2(0, -500)
	cast_ray()
	retrack(current_track)
	if yes_animate_pwease == true:
		animate_player_up()
	yes_animate_pwease = false

func player_move_down():
	ray.position.y = 32
	ray.target_position = Vector2(0, 500)
	cast_ray()
	retrack(current_track)
	if yes_animate_pwease == true:
		animate_player_down()
	yes_animate_pwease = false
	
func player_click(event):
	player_clicked.emit()
	if event.is_action_pressed("Click", false):
		if current_note != null:
			handle_note_hit()
		else:
			game.increment_score(0)

func handle_note_hit():
	if current_note.is_in_group("regular note"):
		current_note.hit = true
		handle_reg_note_hit()
	elif current_note.is_in_group("hold note"):
		handle_hold_note_hit()

func handle_reg_note_hit():
	if perfect:
		game.increment_score(3)
		current_note.destroy()
	elif good:
		game.increment_score(2)
		current_note.destroy()
	elif okay:
		game.increment_score(1)
		current_note.destroy()
	_reset()

func handle_hold_note_hit():
	holding_note = true
	current_note.note_hit()
	if perfect:
		game.increment_score(3)
	elif good:
		game.increment_score(2)
	elif okay:
		game.increment_score(1)

func _on_hold_timer_timeout():
	timer_finished = true

func cast_ray():
	ray.force_raycast_update()
	var caught_line = ray.get_collider()
	if caught_line != null and caught_line.is_class("Area2D"):
		current_line = caught_line.get_parent()
		current_track = current_line.get_child(0)
		yes_animate_pwease = true

func retrack(new_track: PathFollow2D):
	get_parent().remove_child(self)
	new_track.add_child(self)
	parent_changed.emit()
	if holding_note:
		player_moved = true

func animate_player_up():
	tp_up.play()

func animate_player_down():
	tp_down.play()
	
func _on_PerfectArea_entered(area):
	if area.is_in_group("regular note"):
		perfect = true
	elif area.is_in_group("hold note"):
		perfect = true
	elif area.is_in_group("barrier note"):
		game.increment_score(0)

func _on_PerfectArea_exited(area):
	if area.is_in_group("regular note"):
		perfect = false
	elif area.is_in_group("hold note"):
		perfect = true

func _on_GoodArea_entered(area):
	if area.is_in_group("regular note"):
		good = true
	elif area.is_in_group("hold note"):
		good = true

func _on_GoodArea_exited(area):
	if area.is_in_group("regular note"):
		good = false
	elif area.is_in_group("hold note"):
		good = true

func _on_OkayArea_entered(area):
	if area.is_in_group("regular note"):
		okay = true
		current_note = area
	elif area.is_in_group("hold note"):
		okay = true
		current_note = area
		area.timer.timeout.connect(_on_hold_timer_timeout)

func _on_OkayArea_exited(area):
	if area.is_in_group("regular note"):
		okay = false
		if current_note == last_note:
			current_note = null
		last_note = area
	if area.is_in_group("hold note"):
		okay = false
		if current_note == last_hold_note:
			current_note = null
		last_hold_note = area
		if last_hold_note.hit == false:
			last_hold_note.no_hit_destroy()

func _reset():
	current_note = null
	perfect = false
	good = false
	okay = false

func _on_held_all_the_way():
	game.increment_score(3)
	last_hold_note.remove_line()

func _on_not_held_all_the_way():
	game.increment_score(0)
	last_hold_note.remove_line()
	
func _on_reg_timer_timeout():
	game.increment_score(0)
