extends Area2D

@onready var hit_label = $CanvasLayer/Label
@onready var shape = $Shape
@onready var hold_line = $HoldLine/Line2D
@onready var end_of_hold = $HoldLine/Polygon2D
@onready var timer = $Timer
@onready var game = get_parent()

var hit = false

const KILL_SPOT = -100

signal destroyed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.global_position.x <= KILL_SPOT and hit == false:
		no_hit_destroy()

# Initializes the hold notes length and timer length
func initialize(hold_to, hold_for):
	hold_line.points[1].x = hold_to
	timer.wait_time = hold_for
	end_of_hold.position.x = hold_to

func note_hit():
	hit = true
	shape.visible = false
	hold_line.width = 15
	timer.start()

func remove_line():
	hold_line.visible = false
	queue_free()

func no_hit_destroy():
	queue_free()
	destroyed.emit()
