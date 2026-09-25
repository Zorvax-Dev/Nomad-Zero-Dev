extends Node2D
class_name NomadLootCache

signal opened(cache_rank: int, world_position: Vector2, zone_hint: String)

var player: NomadPlayer
var cache_rank: int = 1
var zone_hint: String = "DÉSERT"
var hold_time: float = 0.0
var phase: float = 0.0
var active: bool = true

func configure(rank_value: int, zone_value: String) -> void:
	cache_rank = clampi(rank_value, 1, 4)
	zone_hint = zone_value

func _ready() -> void:
	phase = randf_range(0.0, TAU)
	z_index = 3520
	queue_redraw()

func _physics_process(delta: float) -> void:
	if not active:
		return
	phase += delta * 1.85
	if not is_instance_valid(player):
		queue_redraw()
		return
	var dist: float = player.global_position.distance_to(global_position)
	if dist <= 88.0:
		hold_time += delta
		if hold_time >= 0.48:
			active = false
			opened.emit(cache_rank, global_position, zone_hint)
			queue_free()
	else:
		hold_time = maxf(0.0, hold_time - delta * 2.0)
	queue_redraw()

func _rank_color() -> Color:
	match cache_rank:
		2: return Color("5cc9ff")
		3: return Color("c875ff")
		4: return Color("ffb74d")
		_: return Color("a8d9b0")

func _draw() -> void:
	# Noyau de récupération sci-fi : silhouette technique/énergétique, jamais un coffre.
	var color: Color = _rank_color()
	var breathe: float = 0.5 + 0.5 * sin(phase * 1.7)
	var hover: float = sin(phase) * 2.2
	var center := Vector2(0.0, -5.0 + hover)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.42))
	draw_circle(Vector2(0.0, 44.0), 34.0, Color(0.0, 0.0, 0.0, 0.28))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_circle(center, 33.0 + breathe * 3.0, Color(color.r, color.g, color.b, 0.055 + breathe * 0.035))
	draw_arc(center, 29.0, phase, phase + PI * 1.18, 28, Color(color.r, color.g, color.b, 0.58), 2.4, true)
	draw_arc(center, 37.0, -phase * 0.72, -phase * 0.72 + PI * 0.72, 24, Color(color.r, color.g, color.b, 0.30), 1.6, true)
	for i: int in range(3):
		var a: float = phase * 0.16 + float(i) * TAU / 3.0
		var dir := Vector2.RIGHT.rotated(a)
		var side := dir.rotated(PI * 0.5)
		var root := center + dir * 16.0
		var tip := center + dir * 35.0
		var fin := PackedVector2Array([root + side * 6.0, tip, root - side * 6.0])
		draw_colored_polygon(fin, Color(0.065, 0.085, 0.098, 0.96))
		draw_polyline(PackedVector2Array([root + side * 6.0, tip, root - side * 6.0]), Color(color.r, color.g, color.b, 0.58), 1.5)
	var hex := PackedVector2Array()
	for i: int in range(6):
		hex.append(center + Vector2.RIGHT.rotated(-PI * 0.5 + float(i) * TAU / 6.0) * 17.0)
	draw_colored_polygon(hex, Color(0.035, 0.060, 0.072, 0.98))
	draw_polyline(PackedVector2Array([hex[0], hex[1], hex[2], hex[3], hex[4], hex[5], hex[0]]), Color(color.r, color.g, color.b, 0.92), 2.2)
	draw_circle(center, 8.0 + breathe * 1.8, Color(color.r, color.g, color.b, 0.72))
	draw_circle(center, 3.4, Color(0.94, 0.99, 1.0, 0.96))
	if hold_time > 0.0:
		var ratio: float = clampf(hold_time / 0.48, 0.0, 1.0)
		draw_arc(center, 45.0, -PI * 0.5, -PI * 0.5 + TAU * ratio, 40, Color(1.0, 1.0, 1.0, 0.94), 3.5, true)
