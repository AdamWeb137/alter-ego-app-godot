extends Node2D

var en_item_prefab

var item_titles_en = [
"School Introduction - Kibogamine Gakuen", "School Introduction - Purchasing Department", "School Introduction - Monomono Machine", "School Introduction - Library", "School Introduction - Trash Room", "School Introduction - Laundry", " School Introduction/Pool", "School Introduction/Recreation Room", "School Introduction/Physics Room", "School Introduction/Dressing Room",
"Introduction to the school/health room", "Introduction to the school/large public bath", "Introduction to the school/music room", "Introduction to the school/art room", "Introduction to the school/biology room", "Introduction to the school/martial arts hall", "School Introduction: Botanical Garden", "Introduction: Kitchen", "Introduction: Cafeteria", "Terminology: Free Time",
"Introduction of terms - Oshioki", "Introduction of terms - Kuro", "Introduction of terms - Gedo Tenshi☆Mochimochi Princess", "Introduction of terms - school rules", "Introduction of terms - Chimidoro Fever", "Introduction of terms - Graduation", "Introduction of terms ・Electronic Student Handbook", "Introduction of Terms ・Fenrir", "Introduction of Terms ・Night Time", "Introduction of Terms ・The Greatest and Worst Desperate Incident in Human History",
"Introduction of terms/class trial", "Introduction of terms/The Monokuma File", "Introduction of terms/classroom", "Introduction of terms/super high school level", "Introduction of terms/Bureuijidai Amondo"
]
var item_titles_jp = [
"学園紹介・希望ヶ峰学園", "学園紹介・購買部", "学園紹介・モノモノマシーン", "学園紹介・図書室", "学園紹介・トラッシュルーム", "学園紹介・ランドリー", "学園紹介・プール", "学園紹介・娯楽室", "学園紹介・物理室", "学園紹介・脱衣所",
"学園紹介・保健室", "学園紹介・大浴場", "学園紹介・音楽室", "学園紹介・美術室", "学園紹介・生物室", "学園紹介・武道場", "学園紹介・植物庭園", "学園紹介・厨房", "学園紹介・食堂", "用語紹介・自由時間",
"用語紹介・オシオキ", "用語紹介・クロ", "用語紹介・外道天使☆もちもちプリンセス", "用語紹介・校則", "用語紹介・チミドロフィーバー", "用語紹介・卒業", "用語紹介・電子生徒手帳", "用語紹介・フェンリル", "用語紹介・夜時間", "用語紹介・人類史上最大最悪の絶望的事件",
"用語紹介・学級裁判", "用語紹介・ザ・モノクマファイル", "用語紹介・教室", "用語紹介・超高校級", "用語紹介・暮威慈畏大亜紋土"
]
var item_ids = [
	"008_015", "008_016", "008_017", "008_018", "008_019", "008_020", "008_021", "008_022", "008_023", "008_024",
	"008_025", "008_026", "008_027", "008_028", "008_032", "008_033", "008_034", "008_037", "008_038", "008_039",
	"008_040", "008_041", "008_042", "008_043", "008_044", "008_045", "008_046", "008_047", "008_048", "008_049",
	"008_050", "008_051", "008_052", "008_053", "008_054"
]

var item_titles = {
	"en":item_titles_en,
	"jp":item_titles_jp
}

var item_selected=null
var an_item_selected=false

func finished_item():
	item_selected.get_node("Selected").visible=false
	an_item_selected=false
	item_selected=null
	$ExitBtn.visible=true
	$DialougeBox.get_node("Textbox/RichTextLabel").clear()

func load_mess(enitem,id):
	if an_item_selected:
		return
	Sound.play_se(1)
	item_selected=enitem
	an_item_selected=true
	enitem.get_node("Selected").visible=true
	$ExitBtn.visible=false
	$DialougeBox.enter_tween(id)

func load_en_items():
	var its = item_titles[ScriptHelper.lang]
	var y = 0
	var index=0
	for i in its:
		var enitem = en_item_prefab.instantiate()
		enitem.position.y = y
		enitem.get_node("Label").text = i
		enitem.get_node("TouchScreenButton").released.connect(self.load_mess.bind(enitem,item_ids[index]))
		y += 30
		$EnItems.add_child(enitem)
		index += 1

var width_lines = []
var height_lines = []
var line_alpha = 0.1
var ltween_time=0.1
func create_vert_lines():
	var tween = create_tween()
	var tween_time = 0.25
	tween.set_parallel(true)
	for i in range(int(480/32)):
		var wl = Line2D.new()
		var x = (i+1)*32-240
		wl.add_point(Vector2(x,-114))
		wl.add_point(Vector2(x,114))
		wl.position.y=-228
		wl.modulate.a = line_alpha
		wl.width=1.0
		tween.tween_property(wl,"position:y",0,ltween_time)
		$Lines.add_child(wl)
	tween.finished.connect(self.load_en_items)

func create_horz_lines():
	var tween = create_tween()
	var tween_time = 0.25
	tween.set_parallel(true)
	for i in range(int(228/32)):
		var hl = Line2D.new()
		var y = (i+1)*32-114
		hl.add_point(Vector2(-240, y))
		hl.add_point(Vector2(240, y))
		hl.position.x=-480
		hl.modulate.a = line_alpha
		hl.width=1.0
		tween.tween_property(hl,"position:x",0,ltween_time)
		$Lines.add_child(hl)
	tween.finished.connect(self.create_vert_lines)

func _ready():
	en_item_prefab = load("res://scenes/en_item.tscn")
	var tween = create_tween()
	var tween_time = 0.25
	tween.set_parallel()
	tween.tween_property($Left,"position:x",0,tween_time)
	tween.tween_property($Title/fromleft,"position:x",0,tween_time)
	tween.tween_property($Title/fromright,"position:x",0,tween_time)
	tween.finished.connect(self.create_horz_lines)

var rev_speed = PI/4
func _process(delta):
	$Left/Revolver.rotation += rev_speed*delta

func _input(inp_ev):
	var miny = -(item_titles_en.size()-1)*30+100
	var maxy = -80
	if an_item_selected:
		return
	if inp_ev is InputEventMouseMotion or inp_ev is InputEventScreenDrag:
		if inp_ev.pressure > 0 or inp_ev is InputEventScreenDrag:
			$EnItems.position.y += inp_ev.relative.y
	if $EnItems.position.y < miny:
		$EnItems.position.y = miny
	if $EnItems.position.y > maxy:
		$EnItems.position.y = maxy
				
	#print(inp_ev)
