extends Node2D

var points = []
var is_editing = true

func _unhandled_input(event):
	if is_editing and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		points.append(get_global_mouse_position())
		queue_redraw()
	elif is_editing and event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		is_editing = false
		print("Zone définie avec %d points." % points.size())

func _draw():
	if points.size() > 1:
		draw_polyline(points + [points[0]], Color.YELLOW, 2.0)
	for p in points:
		draw_circle(p, 4, Color.RED)
