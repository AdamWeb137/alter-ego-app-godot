extends Node2D


var rng = RandomNumberGenerator.new()
var shidden = false
const moves_per_show = 6
var moves = moves_per_show

func _set_move_timer():
	moves -= 1
	if moves < 0:
		$MoveTimer.stop()
		return
	if moves == 0:
		$MoveTimer.stop()
		_set_timer()
		return
	$Sprite2D.position.y = rng.randi_range(-160,160)
	$MoveTimer.start(rng.randf_range(0.1,0.2))

func _set_timer():
	if shidden == false:
		$Timer.start(rng.randf_range(6.0,30.0))
		$Sprite2D.visible = false
		shidden=true
		return
	shidden=false
	moves = moves_per_show
	$Sprite2D.visible = true
	_set_move_timer()

func _ready():
	$Timer.set_one_shot(false)
	$MoveTimer.set_one_shot(false)
	_set_timer()
