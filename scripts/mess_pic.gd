extends Node2D

var enter_time = 0.25
func movex_to(x,tween_time=0.5,connect=null,eas=Tween.EASE_IN):
	var tween = create_tween()
	tween.set_ease(eas)
	tween.tween_property(self,"position:x",x,tween_time)
	if connect != null:
		tween.finished.connect(connect)

func _ready():
	movex_to(-32,enter_time,movex_to.bind(0,0.05,null,Tween.EASE_OUT))

func exit():
	Sound.play_se(16)
	movex_to(32,0.05,movex_to.bind(-408,enter_time,self.queue_free))
