extends Node2D
class_name NomadZoneObjectiveMarker

var title: String = "SIGNAL"
var subtitle: String = ""
var marker_color: Color = Color("8be7ff")
var radius: float = 76.0
var active: bool = true
var progress: float = 0.0
var target: float = 1.0
var pulse: float = 0.0

func configure(title_text: String, color_value: Color, radius_value: float = 76.0) -> void:
	title = title_text
	marker_color = color_value
	radius = radius_value
	queue_redraw()

func set_status(is_active: bool, progress_value: float, target_value: float, subtitle_text: String = "") -> void:
	active = is_active
	progress = maxf(0.0, progress_value)
	target = maxf(0.001, target_value)
	subtitle = subtitle_text
	visible = active
	queue_redraw()

func _ready() -> void:
	z_index = 2500
	queue_redraw()

func _process(delta: float) -> void:
	if not visible:
		return
	pulse = fmod(pulse + delta * 1.45, 1.0)
	queue_redraw()

func _draw() -> void:
	if not active:
		return
	var breathing: float = 0.5 + 0.5 * sin(pulse * TAU)
	var ring_color := Color(marker_color.r, marker_color.g, marker_color.b, 0.34 + breathing * 0.22)
	var r: float = radius + breathing * 5.0
	draw_circle(Vector2.ZERO, radius * 0.62, Color(marker_color.r, marker_color.g, marker_color.b, 0.035))
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 48, ring_color, 2.0, true)
	var ratio: float = clampf(progress / target, 0.0, 1.0)
	if ratio > 0.001:
		draw_arc(Vector2.ZERO, radius + 5.0, -PI * 0.5, -PI * 0.5 + TAU * ratio, 48, Color(marker_color.r, marker_color.g, marker_color.b, 0.88), 4.0, true)
	var d: float = 9.0 + breathing * 1.5
	var diamond := PackedVector2Array([Vector2(0.0,-d), Vector2(d,0.0), Vector2(0.0,d), Vector2(-d,0.0)])
	draw_colored_polygon(diamond, Color(marker_color.r, marker_color.g, marker_color.b, 0.86))
