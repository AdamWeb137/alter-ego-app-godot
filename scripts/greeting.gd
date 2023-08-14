extends Node2D

var rng = RandomNumberGenerator.new()
func get_mess_id():
	rng.randomize()
	for id in ScriptHelper.type_messes[2]:
		if ScriptHelper.chk_mess("002_"+id):
			return "002_"+id
	var time_of_day = ScriptHelper.get_time_of_day()
	var eligable_array = ScriptHelper.time_messes[time_of_day]
	var rand_index = rng.randi_range(0,eligable_array.size()-1)
	return eligable_array[rand_index]
	
func load_mess():
	var id = get_mess_id()
	$DialougeBox.enter_tween(id)
