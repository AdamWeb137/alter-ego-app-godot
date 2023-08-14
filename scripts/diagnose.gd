extends Node2D

func _ready():
	var mess_id = "010_003"
	if ScriptHelper.get_var("SHINDAN") == 0:
		mess_id = "010_001"
	$DialougeBox.enter_tween(mess_id)
