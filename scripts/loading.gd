extends Sprite2D

var rng = RandomNumberGenerator.new()
func _process(delta):
	var allowed_change = 2;
	$static.modulate.a += rng.randf_range(-1.0,1.0)*delta*allowed_change
	if $static.modulate.a < 0:
		$static.modulate.a = 0
	if $static.modulate.a > 1:
		$static.modulate.a = 1


func _on_timer_timeout():
	get_parent().stop_loading()
