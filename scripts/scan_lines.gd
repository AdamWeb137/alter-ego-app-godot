extends Node2D

func set_tween():
	self.position = Vector2(0,0)
	var tween = create_tween()
	var tween_time = 20
	tween.tween_property(self,"position",Vector2(0,320),tween_time)
	tween.finished.connect(self.set_tween)

func _ready():
	set_tween()
