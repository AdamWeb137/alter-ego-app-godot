extends Node2D

const max_alpha=137.0/255.0
var going_up=true

func set_tween():
	var new_alpha = max_alpha
	if going_up:
		new_alpha = 0.0
	var tween = create_tween()
	var tween_time = 1
	tween.tween_property($BigFlashing,"modulate:a",new_alpha,tween_time)
	going_up = !going_up
	tween.finished.connect(self.set_tween)

func _ready():
	set_tween()

var rotate_speed = PI/2
func _process(delta):
	self.rotation += rotate_speed * delta
