extends Node2D
var or_pos
var dragging

func _on_input_event(viewport, event, shape_idx):
	#if event is InputEventScreenTouch or event is InputEventScreenDrag: #or event is InputEventMouse:
	if event is InputEventMouseButton:
		if event.is_pressed():
			dragging = true
			print("pressed")
		if dragging == true:
			print("dragging")
			print(event.get_position())
			global_position = event.get_position()# - get_parent().position - get_parent().get_parent().position
		if event.is_released():
			dragging = false
			print("released")
