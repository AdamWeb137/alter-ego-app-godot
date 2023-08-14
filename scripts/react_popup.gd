extends Node2D

func _ready():
	Sound.play_se("REACTION")
	$CPUParticles2D.restart()
	var tween=create_tween()
	var tween_time = 1
	tween.tween_property(self,"modulate:a",0.0,tween_time)
	tween.finished.connect(self.queue_free)
