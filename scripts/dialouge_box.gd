extends Node2D

var skip_forward=false
func skip_button_tween():
	var tween = create_tween()
	var tween_time = 0.125 if (not skip_forward) else 1
	tween.tween_property($SkipButton/Sprite2D,"position:x",1*(1 if skip_forward else -1), tween_time)
	skip_forward=!skip_forward
	tween.finished.connect(self.skip_button_tween)
	
var cont_forward=false
func continue_button_tween():
	var tween = create_tween()
	var tween_time = 0.25 if (not cont_forward) else 1
	tween.tween_property($ContinueButton/Sprite2D,"position:y",3*(1 if cont_forward else -1), tween_time)
	cont_forward=!cont_forward
	tween.finished.connect(self.continue_button_tween)

const text_col = "#00ff00"
#const react_col = "#ff00ff"
const react_col = "#E63EEB"

const char_per_sec = 30
var char_speed = 1.0 / float(char_per_sec)
var char_timer = 0.0
var loaded_mess=false
var char_index = 0
var line_index = 0
var bbc_text=""
var line_loaded=false
var mess
var tbox
var contsprite
var reactpopup
var has_react=false
var has_select=false
var select_prefab
func _ready():
	tbox = $Textbox/RichTextLabel
	contsprite = $ContinueButton/Sprite2D
	mpicprefab = load("res://scenes/mess_pic.tscn")
	reactpopup = load("res://scenes/react_popup.tscn")
	select_prefab = load("res://scenes/select_box.tscn")
	skip_button_tween()
	continue_button_tween()

var mpicprefab
var mpic=null
func del_mpic():
	if mpic != null:
		mpic.exit()
	mpic = null

func handle_command(com):
	var spl = com.split(":")
	match spl[0]:
		"FACE":
			Global.change_face(int(spl[1]))
		"VOICE":
			Sound.play_voice(int(spl[1]))
		"PICON":
			mpic = mpicprefab.instantiate()
			var fname = "res://cg/cg"+str(Global.to_m_digits(int(spl[1]),3))+".png"
			mpic.get_node("Pic").texture = load(fname)
			Global.get_main().add_child(mpic)
		"PICOFF":
			del_mpic()

func compile_bbc_text():
	bbc_text = "[color=%s]%s[/color]" % [text_col,mess["lines"][line_index]]
	if bbc_text.contains("<REACT>"):
		has_react=true
		var escaped_react_line = mess["react_line"].replace("[","[lb]")#.replace("]","[rb]")
		var react_replace = "[/color][color=%s][url=%s]%s[/url][/color][color=%s]" % [react_col, mess["react_jump"], escaped_react_line, text_col]
		bbc_text = bbc_text.replace("<REACT>",react_replace)

func load_line(l):
	char_index = 0
	line_index = l
	char_timer = 0
	meta_hover=false
	has_react = false
	has_select=false
	
	if line_index+1 == mess["lines"].size() and "select" in mess:
		has_select=true
	
#	tbox.text=""
	compile_bbc_text()
	tbox.clear()
#	tbox.append_text("[color=%s]" % text_col)
	line_loaded=false
	contsprite.visible=false
	if str(line_index) in mess["commands"]:
		for c in mess["commands"][str(line_index)]:
			handle_command(c)
			

func select_press(id):
	Sound.play_se(5)
	after()
	load_mess(id)

var sboxes=[]
func render_select():
	var y = -168
	for s in mess["select"]:
		y += 48
		var csplit = s.split(":")
		var sbox = select_prefab.instantiate()
		sbox.get_node("Label").text = csplit[1]
		sbox.get_node("TouchScreenButton").pressed.connect(self.select_press.bind(csplit[0]))
		sbox.position.y = y
		sboxes.append(sbox)
		add_child(sbox)
		
func del_select():
	if has_select:
		has_select=false
		for sbox in sboxes:
			sbox.queue_free()
	sboxes=[]

func line_finished():
	line_loaded=true
	contsprite.visible = true
	delaying_cont=false
	cont_delay_timer=0.0
	if has_select:
		render_select()

func load_mess(id):
	del_mpic()
	del_select()
	Global.change_face(0)
	mess = ScriptHelper.get_mess(id)
	if not mess:
		return false
	loaded_mess=true
	load_line(0)
	return true

func exit_tween(connect=self.queue_free):
	var tween = create_tween()
	var tween_time = 0.25
	tween.tween_property(self,"position:x",-528,tween_time)
	if connect != null:
		tween.finished.connect(connect)

func after():
	if not mess:
		return
	if "after" in mess:
		var asplit = mess["after"].split(":")
		if asplit[1] == "0":
			ScriptHelper.set_var(asplit[0],0)
			ScriptHelper.save_vars()
			return
		ScriptHelper.add_var(asplit[0],1)
		ScriptHelper.save_vars()

func enter_tween(id):
	position.x = -528
	var tween = create_tween()
	var tween_time = 0.25
	tween.tween_property(self,"position:x",0,tween_time)
	tween.finished.connect(self.load_mess.bind(id))

func exit_protocol(from_button=false):
	del_mpic()
	if from_button:
		Sound.play_se(3)
	after()
	match get_parent().name:
		"Freetalk","Greeting":
			exit_tween(Global.get_main().exit_current_scene.bind(true))
		"Help", "Diagnose":
			exit_tween(Global.get_main().exit_current_scene.bind(false))
		"WorldEn","CharEn":
			exit_tween(get_parent().finished_item)

func cont():
	if not line_loaded:
#		tbox.text=""
		tbox.clear()
		tbox.append_text(bbc_text)
		line_finished()
		return
	if has_select:
		return
	Sound.play_se(3)
	if line_index + 1 >= mess["lines"].size():
		if "jump" in mess:
			after()
			var tryload = load_mess(mess["jump"])
			if not tryload:
				exit_protocol()
				return
			return
		exit_protocol()
		return
	load_line(line_index+1)

var delaying_cont=false
var cont_delay_timer=0.0
func _cont_press():
	if meta_hover or not loaded_mess or delaying_cont:
		return
	if has_react:
		delaying_cont=true
		cont_delay_timer=0.0
		return
	cont()
	
var meta_hover=false
func set_meta_hover(meta, b):
	meta_hover=b

func meta_press(data):
	delaying_cont=false
	cont_delay_timer=0.0
	Global.get_main().add_child(reactpopup.instantiate())
	after()
	load_mess(data)

func get_char():
	return mess["lines"][line_index][char_index]
	
func get_line_length():
	return mess["lines"][line_index].length()
	
func get_bchar():
	return bbc_text[char_index]
	
func get_bline_length():
	return bbc_text.length()

func append_text(t):
	tbox.append_text(t)
#	tbox.text += t
#	tbox.parse_bbcode(t)

func add_char():
	var to_append_text = ""
	var in_brackets = ""
	while(char_index < get_bline_length() and get_bchar() == "["):
		in_brackets = ""
		while(get_bchar() != "]"):
			in_brackets += get_bchar()
			char_index += 1
		if in_brackets.length() < 2:
			pass
		elif in_brackets[1] == "/":
			tbox.pop()
		elif in_brackets.contains("="):
			var tags = in_brackets.replace("[","").split("=")
			match tags[0]:
				"color":
					tbox.push_color(Color(tags[1]))
				"url":
					tbox.push_meta(tags[1])
		else:
			match in_brackets:
				"[lb":
					tbox.append_text("[lb]")
		char_index += 1
	if char_index >= get_bline_length():
		return
	to_append_text += get_bchar()
	char_index += 1
	append_text(to_append_text)

func _process(delta):
	if not loaded_mess:
		return
	if delaying_cont:
		cont_delay_timer += delta
		var cont_delay = 0.1
		if cont_delay_timer >= cont_delay:
			delaying_cont=false
			cont_delay_timer=0.0
			cont()
	if line_loaded:
		return
	char_timer += delta
	if char_timer >= char_speed:
		char_timer = 0
		add_char()
		if char_index == get_bline_length():
			line_finished()

