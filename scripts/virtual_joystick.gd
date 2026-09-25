extends Control
class_name NomadVirtualJoystick

var vector: Vector2 = Vector2.ZERO
var active: bool = false
var touch_id: int = -1
var center: Vector2 = Vector2.ZERO
var knob: Vector2 = Vector2.ZERO
var radius: float = 84.0
var deadzone: float = 0.11
var enabled: bool = false
var blocked_controls: Array[Control] = []

func _ready() -> void:
	set_process_input(true)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _input(event: InputEvent) -> void:
	if not enabled:
		return
	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		if touch.pressed and touch_id == -1 and not _touch_hits_button(touch.position):
			touch_id = touch.index
			active = true
			center = get_global_transform_with_canvas().affine_inverse() * touch.position
			knob = center
			vector = Vector2.ZERO
			queue_redraw()
		elif not touch.pressed and touch.index == touch_id:
			reset()
	elif event is InputEventScreenDrag:
		var drag: InputEventScreenDrag = event as InputEventScreenDrag
		if drag.index == touch_id:
			_update_vector(get_global_transform_with_canvas().affine_inverse() * drag.position)

func _touch_hits_button(position_in_viewport: Vector2) -> bool:
	for control: Control in blocked_controls:
		if not is_instance_valid(control) or not control.is_visible_in_tree():
			continue
		# Une touche de compétence en recharge reste une zone réservée à l'UI.
		# Elle ne doit pas déclencher le déplacement quand on tente de l'utiliser.
		var local_point: Vector2 = control.get_global_transform_with_canvas().affine_inverse() * position_in_viewport
		if Rect2(Vector2.ZERO, control.size).has_point(local_point):
			return true
	return false

func _update_vector(touch_position: Vector2) -> void:
	var delta: Vector2 = touch_position - center
	var distance: float = delta.length()
	if distance <= radius * deadzone:
		vector = Vector2.ZERO
		knob = center + delta * 0.35
		queue_redraw()
		return
	var direction: Vector2 = delta.normalized()
	var normalized_distance: float = clampf(distance / radius, 0.0, 1.0)
	var remapped: float = clampf((normalized_distance - deadzone) / (1.0 - deadzone), 0.0, 1.0)
	# Slight response curve: precise near the center, still reaches full speed quickly.
	var response: float = pow(remapped, 0.88)
	vector = direction * response
	knob = center + direction * minf(distance, radius)
	queue_redraw()

func reset() -> void:
	touch_id = -1
	active = false
	vector = Vector2.ZERO
	queue_redraw()

func _draw() -> void:
	if not enabled or not active:
		return
	draw_circle(center, radius, Color(0.025, 0.045, 0.060, 0.26))
	draw_arc(center, radius, 0.0, TAU, 48, Color(0.39, 0.86, 0.96, 0.48), 2.5)
	draw_circle(center, radius * deadzone, Color(0.39, 0.86, 0.96, 0.08))
	draw_circle(knob, 27.0, Color(0.39, 0.86, 0.96, 0.64))
	draw_arc(knob, 27.0, 0.0, TAU, 32, Color(0.84, 0.98, 1.0, 0.78), 2.0)
