extends Node2D

var chars = []
var selected_char = null
var chars_tweened=0
var char_tween_timer=0.0
var char_letters = [
	"abcdef",
	"ghijkl",
	"mnopqr"
]
var char_ids = [
	["003_035", "003_041", "003_049", "003_043", "003_061", "003_057"], 
	["003_059", "003_037", "003_039", "003_051", "003_045", "003_047"], 
	["003_053", "003_055", "003_065", "003_063", "003_067", "003_104"]
]
var char_index=0
var can_change_chars=false
func create_chars():
	var char_prefab = load("res://scenes/char.tscn")
	for i in range(6):
		var c = char_prefab.instantiate()
		c.position = Vector2(-168+64*i,-300)
		c.get_node("TouchScreenButton").pressed.connect(self.load_mess.bind(c))
		c.get_node("Label").text = char_letters[char_index][i]
		c.mess_id = char_ids[char_index][i]
		$Characters.add_child(c)
		chars.append(c)

func finished_item():
	selected_char.get_node("dark").visible=true
	$DialougeBox/Textbox/RichTextLabel.clear()
	selected_char=null
	$ExitBtn.visible=true

func load_mess(c):
	var id = c.mess_id
	if selected_char != null or not can_change_chars:
		return
	Sound.play_se(5)
	c.get_node("dark").visible=false
	$ExitBtn.visible=false
	selected_char=c
	$DialougeBox.enter_tween(id)
	

func _ready():
	var tween = create_tween()
	tween.tween_property($Header,"position:y",-136,0.2)
	create_chars()
	
func enable_chars(en=true):
	for c in chars:
		c.get_node("TouchScreenButton").visible=en
	
func first_enable_chars():
	can_change_chars=true
	enable_chars()

func reload_chars():
	var t = create_tween()
	var t_time = 0.2
	t.set_parallel()
	var i = 0
	for c in chars:
		c.position.x+=28*2
		c.mess_id = char_ids[char_index][i]
		c.get_node("Label").text = char_letters[char_index][i]
		t.tween_property(c,"scale:x",1,t_time)
		t.tween_property(c,"position:x",c.position.x-28,t_time)
		i += 1
	t.finished.connect(self.first_enable_chars)

func arrow_press(dir):
	if not can_change_chars or selected_char != null:
		return
	Sound.play_se(7)
	can_change_chars=false
	enable_chars(false)
	char_index += dir
	if char_index < 0:
		char_index = 2
	if char_index > 2:
		char_index = 0
	var t = create_tween()
	var t_time = 0.2
	t.set_parallel()
	for c in chars:
		t.tween_property(c,"scale:x",0,t_time)
		t.tween_property(c,"position:x",c.position.x-28,t_time)
	t.finished.connect(self.reload_chars)
	
	
func _process(delta):
	if chars_tweened < 6:
		char_tween_timer += delta
		if char_tween_timer > 0.15:
			char_tween_timer = 0.0
			var t = create_tween()
			t.tween_property(chars[chars_tweened],"position:y",0,0.1)
			chars_tweened += 1
			if chars_tweened == 6:
				t.finished.connect(self.first_enable_chars)
