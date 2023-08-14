extends Node2D

func check_visits():
	if ScriptHelper.visit_checked:
		return ""
	ScriptHelper.visit_checked=true
	for halfid in ScriptHelper.free_time_messes[11]:
		var id = "011_"+halfid
		if ScriptHelper.chk_mess(id):
			return id
	return ""

func id_halfes_to_id(l,r):
	return Global.to_m_digits(l,3)+"_"+Global.to_m_digits(r,3)

var rng = RandomNumberGenerator.new()
func get_random_id():
	var visit_id = check_visits()
	if visit_id.length() > 0:
		return visit_id
	while true:
		var random_topic = rng.randi_range(3,12)
		if random_topic == 7:
			if ScriptHelper.get_var("URANAI") == 0:
				return "007_001"
			var random_index=rng.randi_range(1,ScriptHelper.how_many_of_type_free(7)-1)
			return "007_"+ScriptHelper.free_time_messes[7][random_index]
		if random_topic == 6:
			var r = int(ScriptHelper.get_var("RANKING"))
			var rand_index = rng.randi_range(0,ScriptHelper.ranking_messages[r].size()-1)
			return "006_"+ScriptHelper.ranking_messages[r][rand_index]
		if random_topic == 10 or random_topic == 11:
			random_topic = rng.randi_range(3,9)
		var random_index = rng.randi_range(0,ScriptHelper.free_time_messes[random_topic].size()-1)
		var id = "%s_%s" % [Global.to_m_digits(random_topic,3),ScriptHelper.free_time_messes[random_topic][random_index]]
		if not ScriptHelper.chk_mess(id):
			continue
		return id

func tween_finished():
	$DialougeBox.load_mess(get_random_id())

func _ready():
	#skip_button_tween()
	rng.randomize()
	var tween = create_tween()
	var tween_time = 0.25
	tween.tween_property(self,"position:x",0,tween_time)
	tween.finished.connect(self.tween_finished)

