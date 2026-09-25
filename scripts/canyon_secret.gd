extends Node2D
class_name NomadCanyonSecret

signal discovered(secret_id: String, world_position: Vector2)

var player: NomadPlayer
var secret_id: String = ""
var phase: float = 0.0
var reveal_strength: float = 0.0
var active: bool = true
var collect_hold: float = 0.0

func configure(id_value: String) -> void:
	secret_id = id_value

func _ready() -> void:
	phase = randf_range(0.0, TAU)
	z_index = 3480
	queue_redraw()

func _physics_process(delta: float) -> void:
	if not active:
		return
	phase = fmod(phase + delta * 1.35, TAU)
	if not is_instance_valid(player):
		queue_redraw()
		return
	var dist: float = player.global_position.distance_to(global_position)
	var target_reveal: float = 0.06
	if dist < 210.0:
		target_reveal = lerpf(0.18, 1.0, clampf((210.0 - dist) / 150.0, 0.0, 1.0))
	reveal_strength = lerpf(reveal_strength, target_reveal, minf(1.0, delta * 5.0))
	if dist <= 46.0:
		collect_hold += delta
		if collect_hold >= 0.28:
			active = false
			discovered.emit(secret_id, global_position)
			queue_free()
			return
	else:
		collect_hold = maxf(0.0, collect_hold - delta * 2.0)
	queue_redraw()

func _secret_color() -> Color:
	match secret_id:
		"veil_archive": return Color("87d8ff")
		"buried_reactor": return Color("f3a55b")
		"resonant_shard": return Color("b787ff")
		"silent_vault": return Color("e7ddff")
		_: return Color("a8d9b0")

func _draw() -> void:
	var color: Color = _secret_color()
	var pulse: float = 0.5 + 0.5 * sin(phase * 2.0)
	var alpha: float = clampf(reveal_strength, 0.04, 1.0)
	# Indice environnemental volontairement discret : pierres fendues et lueur enfouie.
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.38))
	draw_circle(Vector2(0.0, 10.0), 30.0, Color(0.08, 0.055, 0.035, 0.16 * alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	for i: int in range(5):
		var a: float = float(i) * TAU / 5.0 + 0.28
		var p: Vector2 = Vector2.RIGHT.rotated(a) * (18.0 + float(i % 2) * 5.0)
		draw_circle(p, 3.0 + float(i % 3), Color(0.26, 0.20, 0.15, 0.30 + alpha * 0.20))
	var core_y: float = -2.0 + sin(phase) * 1.4
	draw_circle(Vector2(0.0, core_y), 14.0 + pulse * 3.0, Color(color.r, color.g, color.b, 0.025 + alpha * 0.08))
	var shard := PackedVector2Array([
		Vector2(0.0, -10.0 + core_y), Vector2(6.0, -1.0 + core_y),
		Vector2(1.0, 9.0 + core_y), Vector2(-5.0, 2.0 + core_y)
	])
	draw_colored_polygon(shard, Color(color.r, color.g, color.b, 0.12 + alpha * 0.62))
	draw_polyline(PackedVector2Array([shard[0], shard[1], shard[2], shard[3], shard[0]]), Color(0.95, 0.98, 1.0, 0.16 + alpha * 0.56), 1.4)
	if reveal_strength > 0.35:
		draw_arc(Vector2(0.0, core_y), 22.0 + pulse * 2.0, phase * 0.5, phase * 0.5 + PI * 1.25, 22, Color(color.r, color.g, color.b, (alpha - 0.30) * 0.48), 1.6, true)
	if collect_hold > 0.0:
		var ratio: float = clampf(collect_hold / 0.28, 0.0, 1.0)
		draw_arc(Vector2(0.0, core_y), 27.0, -PI * 0.5, -PI * 0.5 + TAU * ratio, 28, Color(1.0, 1.0, 1.0, 0.85), 2.6, true)
