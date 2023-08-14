extends Node2D

func to_two_digits(n):
	if n < 10:
		return "0"+str(n)
	return str(n)

var current_scene
var loading_inst
const menu_btns = preload("res://scenes/menu_btns.tscn")
const loading = preload("res://scenes/loading.tscn")
const scenes = {
	"clock_scene":preload("res://scenes/clock_scene.tscn"),
	"calendar_scene":preload("res://scenes/calendar.tscn"),
	"freetime":preload("res://scenes/freetalk.tscn"),
	"help":preload("res://scenes/help.tscn"),
	"diagnose":preload("res://scenes/diagnose.tscn"),
	"worlden":preload("res://scenes/world_en.tscn"),
	"charen":preload("res://scenes/char_en.tscn")
}

func load_scene(scene_name,skip_loading=false):
	current_scene.queue_free()
	if skip_loading:
		current_scene = scenes[scene_name].instantiate()
		add_child(current_scene)
		return
	loading_inst = loading.instantiate()
	add_child(loading_inst)
	current_scene = scenes[scene_name].instantiate()
	
func stop_loading():
	loading_inst.queue_free()
	add_child(current_scene)

func _ready():
	current_scene = $Greeting
	Sound.init()
	ScriptHelper.init()
	$Greeting.load_mess()
	
func change_face(num):
	var fname = "AlterEgoFace"+to_two_digits(num)+".png"
	get_node("AEFace").texture = load("res://face/"+fname)
	
func exit_current_scene(skip_loading=false):
	change_face(0)
	if Sound.current_song != 10:
		Sound.play_bgm(10)
	current_scene.queue_free()
	current_scene = menu_btns.instantiate()
	if skip_loading:
		add_child(current_scene)
		return
	Sound.play_se(4)
	loading_inst = loading.instantiate()
	add_child(loading_inst)
	#add_child(current_scene)
