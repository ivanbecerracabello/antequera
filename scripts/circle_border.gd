extends Control

func _draw():
	var rect = Rect2(Vector2.ZERO, size)
	var border_width = 4.0
	var border_color = Color.BLACK
	
	# Draw rectangle border
	draw_rect(rect, border_color, false, border_width)


