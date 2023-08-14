extends Node2D

func to_two_digits(n):
	if n < 10:
		return "0"+str(n)
	return str(n)
	
var leaving=false
var or_time_pos
var or_date_pos

func _ready():
	var time_pos = Vector2(-144,-136)
	var date_pos = Vector2(-208,96)
	or_time_pos = $Time.position
	or_date_pos = $Date.position
	var tween = create_tween()
	var tween_time = 0.25
	tween.set_parallel(true)
	tween.tween_property($Time, "position", time_pos, tween_time)
	tween.tween_property($Date, "position", date_pos, tween_time)
	tween.finished.connect(self.say_time)
	$TAudio.finished.connect(next_time_level)

var time_level=0
func next_time_level():
	time_level += 1
	say_time()

func say_time():
	var ct = Time.get_datetime_dict_from_system()
	match time_level:
		0:
			$TAudio.stream = load("res://sounds/voice/055.mp3")
			$TAudio.play()
		1:
			$TAudio.stream = load("res://sounds/voice/%s.mp3" % Global.to_m_digits(140+ct.month-1,3))
			$TAudio.play()
		2:
			$TAudio.stream = load("res://sounds/voice/%s.mp3" % Global.to_m_digits(152+ct.day-1,3))
			$TAudio.play()
		3:
			var fname = "res://sounds/voice/079.mp3"
			if ct.hour != 0:
				fname = "res://sounds/voice/%s.mp3" % Global.to_m_digits(56+ct.hour-1,3)
			$TAudio.stream = load(fname)
			$TAudio.play()
		4:
			var fname = "res://sounds/voice/080a.mp3"
			if ct.minute == 1:
				fname = "res://sounds/voice/080b.mp3"
			elif ct.minute != 0:
				fname = "res://sounds/voice/%s.mp3" % Global.to_m_digits(81+ct.minute-2,3)
			$TAudio.stream = load(fname)
			$TAudio.play()
		5:
			$TAudio.stream = load("res://sounds/voice/139.mp3")
			$TAudio.play()

func _process(_delta):
	var current_time = Time.get_datetime_dict_from_system()
	$Time/Hour.text = to_two_digits(current_time.hour)
	$Time/Minute.text = to_two_digits(current_time.minute)
	$Date/Year.text = str(current_time.year)
	$Date/Month.text = to_two_digits(current_time.month)
	$Date/Day.text = to_two_digits(current_time.day)
	$Date/WeekDay.text = str(current_time.weekday)
	


func _on_timer_timeout():
	$Time/Colon.visible = !$Time/Colon.visible


func _on_exit_released():
	leaving = true
	var tween = create_tween()	
	var tween_time = 0.25
	tween.set_parallel(true)
	tween.finished.connect(self.get_parent().exit_current_scene)	
	tween.tween_property($Time, "position", or_time_pos, tween_time)
	tween.tween_property($Date, "position", or_date_pos, tween_time)
