extends Area2D

@onready var shape = $Shape
@onready var timer = $Timer
@onready var particles = $HitParticles
@onready var game = get_parent()
@onready var camera = get_parent().get_child(5)

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
		
func no_hit_destroy():
	queue_free()
	destroyed.emit()

func destroy():
	hit = true
	shape.visible = false
	timer.start()
	particles.emitting = true

func _on_timer_timeout():
	queue_free()
