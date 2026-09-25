extends Node2D
class_name NomadRiftFragment

signal collected(value: int)

var player: NomadPlayer
var value: int = 1
var age: float = 0.0
var phase: float = 0.0
var speed: float = 520.0
var _redraw_timer: float = 0.0

func _ready() -> void:
	phase = randf_range(0.0, TAU)
	z_index = 3620
	queue_redraw()

func _physics_process(delta: float) -> void:
	_redraw_timer = maxf(0.0, _redraw_timer - delta)
	age += delta
	phase += delta * 4.4
	if not is_instance_valid(player):
		return
	var to_player: Vector2 = player.global_position - global_position
	var dist: float = to_player.length()
	if dist < 258.0 or age > 2.7:
		var multiplier: float = 1.0 + clampf((258.0 - dist) / 258.0, 0.0, 1.0) * 0.80
		if dist > 0.001:
			global_position += to_player.normalized() * speed * multiplier * delta
	if dist < 34.0:
		queue_free()
		collected.emit(value)
	_queue_animated_redraw()

func _queue_animated_redraw() -> void:
	if _redraw_timer > 0.0:
		return
	_redraw_timer = 0.05
	queue_redraw()

func _draw() -> void:
	var bob: float = sin(phase) * 4.0
	var pulse: float = 1.0 + sin(phase * 1.6) * 0.12
	draw_circle(Vector2(0.0, bob), 19.0 * pulse, Color(0.65, 0.30, 1.0, 0.14))
	var points: PackedVector2Array = PackedVector2Array([
		Vector2(0.0, -13.0 + bob), Vector2(9.0, bob), Vector2(0.0, 15.0 + bob), Vector2(-9.0, bob)
	])
	draw_colored_polygon(points, Color(0.73, 0.40, 1.0, 0.96))
	draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[3], points[0]]), Color(0.92, 0.82, 1.0, 1.0), 2.0)
