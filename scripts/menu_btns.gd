extends Node2D

#var move_shrink_v = Vector2(24,24)
var move_shrink_v = Vector2(32,32)
func _ready():
	$language.texture_normal = load("res://misc/%s.png" % ScriptHelper.lang)
	var tween = create_tween()
	var tween_time=0.1
	tween.set_parallel()
	for child in get_children():
		child.scale = Vector2(0,0)
		var move_scale = 1 if child.name != "language" else 0.5
		child.position = child.position + move_shrink_v * move_scale
		tween.tween_property(child,"scale",Vector2(1,1),tween_time)
		tween.tween_property(child,"position",child.position-move_shrink_v*move_scale,tween_time)

func btn(scene_name,skip_loading=false):
	Sound.play_se(1)
	var tween = create_tween()
	var tween_time=0.1
	tween.set_parallel(true)
	match scene_name:
		"worlden":
			Sound.play_bgm(17)
		"charen":
			Sound.play_bgm(3)
		"diagnose":
			Sound.play_bgm(18)
	tween.finished.connect(get_node("/root/Main").load_scene.bind(scene_name,skip_loading))
	for child in get_children():
		var move_scale = 1 if child.name != "language" else 0.5	
		tween.tween_property(child,"scale",Vector2.ZERO,tween_time)
		tween.tween_property(child,"position",child.position+move_shrink_v*move_scale,tween_time)
	#get_parent().load_scene(scene_name)

func freetalk_btn():
	btn("freetime",true)
	
func calendar_btn():
	btn("calendar_scene")
	
func clock_btn():
	btn("clock_scene")
	
func save_language():
	var f = FileAccess.open("user://lang.save",FileAccess.WRITE)
	f.store_string(ScriptHelper.lang)
	
func change_language():
	if ScriptHelper.lang == "jp":
		ScriptHelper.get_script_obj("en")
		$language.texture_normal = load("res://misc/en.png")
		save_language()
	else:
		ScriptHelper.get_script_obj("jp")
		$language.texture_normal = load("res://misc/jp.png")
		save_language()
