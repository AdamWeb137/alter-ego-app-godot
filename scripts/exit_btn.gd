extends TouchScreenButton

var mode = null
func _on_released():
	if get_parent().name == "Calendar":
		get_parent().exit()
		return
	get_node("/root/Main").exit_current_scene()
