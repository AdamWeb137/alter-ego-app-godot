extends Node2D

func tween_finished():
	$DialougeBox.load_mess("000_001")

func _ready():
	#skip_button_tween()
	var tween = create_tween()
	var tween_time = 0.25
	tween.tween_property(self,"position:x",0,tween_time)
	tween.finished.connect(self.tween_finished)
