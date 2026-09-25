extends Node2D
class_name NomadSupplyPickup

signal collected(kind: String)

var player: NomadPlayer
var kind: String = "med"
var age: float = 0.0
var _phase: float = 0.0
var _redraw_timer: float = 0.0

func _ready() -> void:
	_phase = randf_range(0.0, TAU)
	z_index = 3610
	queue_redraw()

func _physics_process(delta: float) -> void:
	_redraw_timer = maxf(0.0, _redraw_timer - delta)
	age += delta
	_phase += delta * 4.0
	if age > 14.0:
		queue_free()
		return
	if not is_instance_valid(player):
		_queue_animated_redraw()
		return
	var to_player: Vector2 = player.global_position - global_position
	var dist: float = to_player.length()
	var attraction: float = 155.0 if kind == "med" else 145.0
	if dist < attraction or age > 5.0:
		var multiplier: float = 1.0 + clampf((attraction - dist) / maxf(1.0, attraction), 0.0, 1.0) * 0.80
		if dist > 0.001:
			global_position += to_player.normalized() * 340.0 * multiplier * delta
	if dist < 32.0:
		queue_free()
		collected.emit(kind)
	_queue_animated_redraw()

func _queue_animated_redraw() -> void:
	if _redraw_timer > 0.0:
		return
	_redraw_timer = 0.05
	queue_redraw()

func _draw() -> void:
	var color: Color = Color("65e58f")
	if kind == "charge": color = Color("6edff4")
	var bob: float = sin(_phase) * 3.2
	draw_circle(Vector2(0.0, bob), 19.0, Color(0.03, 0.05, 0.06, 0.72))
	draw_circle(Vector2(0.0, bob), 14.0, color)
	draw_arc(Vector2(0.0, bob), 23.0, 0.0, TAU, 28, Color(color.r, color.g, color.b, 0.46), 3.0)
	if kind == "med":
		draw_rect(Rect2(-3.0, -10.0 + bob, 6.0, 20.0), Color.WHITE, true)
		draw_rect(Rect2(-10.0, -3.0 + bob, 20.0, 6.0), Color.WHITE, true)
	elif kind == "charge":
		draw_polyline(PackedVector2Array([Vector2(-4,-11+bob),Vector2(5,-2+bob),Vector2(-2,1+bob),Vector2(5,11+bob)]), Color.WHITE, 3.0)
	else:
		draw_arc(Vector2(0.0, bob), 8.0, PI * 0.10, PI * 0.90, 12, Color.WHITE, 3.0)
		draw_arc(Vector2(0.0, bob), 8.0, PI * 1.10, PI * 1.90, 12, Color.WHITE, 3.0)
