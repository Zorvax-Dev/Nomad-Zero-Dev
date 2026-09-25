extends Node2D
class_name NomadSupplyPickup

signal collected(kind: String)

var player: NomadPlayer
var kind: String = "med"
var age: float = 0.0
var _phase: float = 0.0

func _ready() -> void:
	_phase = randf_range(0.0, TAU)
	z_index = 3610
	queue_redraw()

func _physics_process(delta: float) -> void:
	age += delta
	_phase += delta * 4.0
	position.y += sin(_phase) * 0.08
	if age > 12.0:
		queue_free()
		return
	if not is_instance_valid(player):
		return
	var to_player: Vector2 = player.global_position - global_position
	var dist: float = to_player.length()
	if dist < 145.0:
		global_position += to_player.normalized() * 320.0 * delta
	if dist < 28.0:
		queue_free()
		collected.emit(kind)

func _draw() -> void:
	var color: Color = Color("65e58f")
	if kind == "charge": color = Color("6edff4")
	if kind == "shield": color = Color("63dcff")
	draw_circle(Vector2.ZERO, 19.0, Color(0.03, 0.05, 0.06, 0.72))
	draw_circle(Vector2.ZERO, 14.0, color)
	draw_arc(Vector2.ZERO, 23.0, 0.0, TAU, 28, Color(color.r, color.g, color.b, 0.46), 3.0)
	if kind == "med":
		draw_rect(Rect2(-3.0, -10.0, 6.0, 20.0), Color.WHITE, true)
		draw_rect(Rect2(-10.0, -3.0, 20.0, 6.0), Color.WHITE, true)
	elif kind == "charge":
		draw_polyline(PackedVector2Array([Vector2(-4,-11),Vector2(5,-2),Vector2(-2,1),Vector2(5,11)]), Color.WHITE, 3.0)
	else:
		draw_arc(Vector2.ZERO, 8.0, PI * 0.10, PI * 0.90, 12, Color.WHITE, 3.0)
		draw_arc(Vector2.ZERO, 8.0, PI * 1.10, PI * 1.90, 12, Color.WHITE, 3.0)
