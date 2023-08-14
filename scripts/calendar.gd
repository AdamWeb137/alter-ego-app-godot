extends Node2D

func leap_year(year):
	if year % 4 != 0:
		return 0
	if year % 100 == 0:
		if year % 400:
			return 1
		return 0
	return 1
	
func get_first_weekday_of_month(day,weekday):
	return 8 - ((day-weekday) % 7)
	
func set_up_cal_item(day,weekday,row,calitem):
	calitem.day = str(day)
	calitem.shown_text = "dayweek"
	if weekday == 0:
		calitem.shown_text = "day0"
	elif weekday == 6:
		calitem.shown_text = "day6"
	calitem.get_node(calitem.shown_text).visible=true
	calitem.get_node(calitem.shown_text).text=get_node("/root/Main").to_two_digits(day)
	calitem.position = Vector2(64 * (weekday), row*32)
	calitem.get_node("CalBtn").pressed.connect(self.set_stamp.bind(calitem))
	$SpriteHolder/CalItemHolders.add_child(calitem)

func create_drag_objects():
	var drag_obj = load("res://scenes/cal_drag_object.tscn")
	for child in $Stamps.get_children():
		if child.name == "modback":
			continue
		var do1 = drag_obj.instantiate()
		do1.get_node("Label").text = child.text[0]
		do1.or_pos = Vector2(0,0)
		do1.get_node("Area2D").input_event.connect(do1._on_input_event)
		var do2 = drag_obj.instantiate()
		do2.get_node("Label").text = child.text[1]
		do2.or_pos = Vector2(0,34)
		do2.position = do2.or_pos
		do2.get_node("Area2D").input_event.connect(do2._on_input_event)
		child.add_child(do1)
		child.add_child(do2)

func load_cal_data():
	if not FileAccess.file_exists("user://caldata.save"):
		return {}
	var caldatasave = FileAccess.open("user://caldata.save",FileAccess.READ)
	var caldatatext = caldatasave.get_as_text()
	var json = JSON.new()
	var parse_result = json.parse(caldatatext)
	if not parse_result == OK:
		return {}
	return json.get_data()
	
func init_cal_data():
	for month in cal_data:
		for day in cal_data[month]:
			$SpriteHolder/CalItemHolders.get_child(int(day)-1).get_node("Stamp").text = cal_data[month][day]

var cal_data
var cur_month
func _ready():
	
	cal_data = load_cal_data()
	
	var or_time_pos = Vector2(0,8)
	var or_sprite_pos = Vector2(0,0)
	var or_stamps_pos = Vector2(72,-120)
	
	var tween = create_tween()
	var tween_time = 0.25
	tween.set_parallel(true)
	tween.tween_property($TimeHolder,"position",or_time_pos,tween_time)
	tween.tween_property($SpriteHolder,"position",or_sprite_pos,tween_time)
	tween.tween_property($Stamps,"position",or_stamps_pos,tween_time)
	
	#create_drag_objects()
	
	var current_time = Time.get_datetime_dict_from_system()
	cur_month = str(current_time.month)
	
	if not str(current_time.month) in cal_data:
		cal_data[str(current_time.month)] = {}
	
	var cal_day = load("res://scenes/cal_day.tscn")
	var curr_day_marker = load("res://scenes/current_day_marker.tscn")
	var letters = "aabcdefghijklmnop"
	var days_in_month = [0, 31, 28 + leap_year(current_time.year), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	var weekday = get_first_weekday_of_month(current_time.day,current_time.weekday)
	var row = 0
	for i in range(1,days_in_month[current_time.month]+1):
		var calitem = cal_day.instantiate()
		if i == current_time.day:
			calitem.add_child(curr_day_marker.instantiate())
		set_up_cal_item(i,weekday,row,calitem)
		weekday += 1
		if weekday >= 7:
			weekday=0
			row += 1
	$TimeHolder/Month.text = letters[current_time.month]
	$TimeHolder/Year.text = str(current_time.year)
	init_cal_data()
	
func save_cal_data():
	var cal_save = FileAccess.open("user://caldata.save",FileAccess.WRITE)
	cal_save.store_string(JSON.stringify(cal_data))
	
var selected_letter = null
var calitem_with_border
func set_stamp(calitem):
	if selected_letter == null:
		return
	if calitem_with_border != null and selected_letter != "erase":
		if calitem_with_border != calitem:
			calitem_with_border.get_node("border").visible=false
	calitem_with_border=calitem
	if selected_letter == "erase":
		calitem.get_node("Stamp").text = ""
		calitem.get_node("border").visible=false
		cal_data[cur_month].erase(str(calitem.day))
		save_cal_data()
		return
	calitem.get_node("border").visible=true
	calitem.get_node("Stamp").text = selected_letter
	cal_data[cur_month][str(calitem.day)]=selected_letter
	save_cal_data()
	

var stamp_button_with_border = null
func on_stamp_selected(letter:String):
	selected_letter = letter
	var letter_matchups = ["ag", "bh", "ci", "dj", "ek", "fl"]
	var real_letter = letter
	if real_letter == "erase":
		real_letter = "a"
	for i in range(letter_matchups.size()):
		if letter_matchups[i].contains(real_letter):
			if stamp_button_with_border != null:
				stamp_button_with_border.get_node("border").visible=false
			stamp_button_with_border = $Stamps.get_node(str(i+1)+"/"+real_letter)
			stamp_button_with_border.get_node("border").visible=true
			return
	
func exit():
	var ex_time_pos = Vector2(-504,8)
	var ex_sprite_pos = Vector2(-504,0)
	var ex_stamps_pos = Vector2(504,-120)
	var tween = create_tween()
	var tween_time = 0.25
	tween.set_parallel(true)
	tween.finished.connect(get_node("/root/Main").exit_current_scene)
	tween.tween_property($TimeHolder,"position",ex_time_pos,tween_time)
	tween.tween_property($SpriteHolder,"position",ex_sprite_pos,tween_time)
	tween.tween_property($Stamps,"position",ex_stamps_pos,tween_time)
