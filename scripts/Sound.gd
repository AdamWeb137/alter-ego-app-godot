extends Node

var sounds = {
	"REACTION":36,
	"CONT":3
}

var se
var bgm
var v
var current_song=0
func init():
	se = Global.get_main().get_node("SE")
	bgm = Global.get_main().get_node("BGM")
	v = Global.get_main().get_node("VOICE")
	play_bgm(10)

func play_bgm(n):
	current_song = n
	var fname = "res://sounds/bgm/HS_BGM_"+Global.to_m_digits(n,3)+".mp3"
	bgm.stream = load(fname)
	bgm.play()

func play_voice(n):
	var fname = "res://sounds/voice/"+Global.to_m_digits(n,3)+".mp3"
	v.stream = load(fname)
	v.play()

func play_se(sname):
	var id = sname
	if sname is String:
		id = sounds[sname]
	var fname = "res://sounds/se/HS_SE_"+Global.to_m_digits(id,3)+".mp3"
	se.stream = load(fname)
	se.play()
