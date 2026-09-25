extends Node2D
class_name NomadLootPickup

signal collected(module_id: String, rarity: String)

var player: NomadPlayer
var module_id: String = "field_patch"
var rarity: String = "common"
var age: float = 0.0
var phase: float = 0.0
var speed: float = 430.0
var _redraw_timer: float = 0.0

func configure(module_value: String, rarity_value: String) -> void:
	module_id = module_value
	rarity = rarity_value

func _ready() -> void:
	phase = randf_range(0.0, TAU)
	z_index = 3630
	if rarity in ["epic", "legendary", "signature"]:
		var rarity_label: Label = Label.new()
		rarity_label.position = Vector2(-72.0, -58.0)
		rarity_label.size = Vector2(144.0, 24.0)
		rarity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rarity_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		rarity_label.text = "RELIQUE" if rarity == "signature" else ("LÉGENDAIRE" if rarity == "legendary" else "ÉPIQUE")
		rarity_label.add_theme_font_size_override("font_size", 14)
		rarity_label.add_theme_color_override("font_color", rarity_color())
		rarity_label.add_theme_color_override("font_outline_color", Color(0.01, 0.015, 0.02, 0.96))
		rarity_label.add_theme_constant_override("outline_size", 4)
		rarity_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(rarity_label)
	queue_redraw()

func _physics_process(delta: float) -> void:
	_redraw_timer = maxf(0.0, _redraw_timer - delta)
	age += delta
	phase += delta * 3.4
	if age > 44.0:
		queue_free()
		return
	if not is_instance_valid(player):
		_queue_animated_redraw()
		return
	var to_player: Vector2 = player.global_position - global_position
	var dist: float = to_player.length()
	var attraction: float = maxf(175.0, player.magnet_range * 0.92)
	if dist < attraction * 1.04 or age > 6.5:
		var multiplier: float = 1.0 + clampf((attraction - dist) / maxf(1.0, attraction), 0.0, 1.0) * 0.72
		if dist > 0.001:
			global_position += to_player.normalized() * speed * multiplier * delta
	if dist < 36.0:
		queue_free()
		collected.emit(module_id, rarity)
	_queue_animated_redraw()

func rarity_color() -> Color:
	match rarity:
		"rare":
			return Color("5cc9ff")
		"epic":
			return Color("c875ff")
		"legendary":
			return Color("ffb74d")
		"signature":
			return Color("ff6a45")
		_:
			return Color("a8d9b0")

func _queue_animated_redraw() -> void:
	if _redraw_timer > 0.0:
		return
	_redraw_timer = 0.05
	queue_redraw()

func _draw() -> void:
	var color: Color = rarity_color()
	var bob: float = sin(phase) * 4.0
	var pulse: float = 1.0 + sin(phase * 1.8) * 0.08
	var outer_alpha: float = 0.14 if rarity == "common" else (0.22 if rarity == "rare" else 0.30)
	if rarity in ["epic", "legendary", "signature"]:
		var beam_height: float = 118.0 if rarity == "epic" else (168.0 if rarity == "legendary" else 205.0)
		var beam_alpha: float = 0.14 if rarity == "epic" else (0.20 if rarity == "legendary" else 0.27)
		draw_line(Vector2(0.0, bob - 18.0), Vector2(0.0, bob - beam_height), Color(color.r, color.g, color.b, beam_alpha), 12.0, true)
		draw_line(Vector2(0.0, bob - 18.0), Vector2(0.0, bob - beam_height), Color(1.0, 1.0, 1.0, beam_alpha * 0.72), 3.0, true)
	draw_circle(Vector2(0.0, bob), 25.0 * pulse, Color(color.r, color.g, color.b, outer_alpha))
	var diamond: PackedVector2Array = PackedVector2Array([
		Vector2(0.0, -16.0 + bob), Vector2(13.0, bob), Vector2(0.0, 16.0 + bob), Vector2(-13.0, bob)
	])
	draw_colored_polygon(diamond, Color(color.r, color.g, color.b, 0.92))
	draw_polyline(PackedVector2Array([diamond[0], diamond[1], diamond[2], diamond[3], diamond[0]]), Color(1.0, 1.0, 1.0, 0.92), 2.0)
	draw_circle(Vector2(0.0, bob), 5.0, Color(1.0, 1.0, 1.0, 0.92))
	if rarity in ["epic", "legendary", "signature"]:
		draw_arc(Vector2(0.0, bob), 31.0, phase, phase + PI * 1.45, 28, Color(color.r, color.g, color.b, 0.78), 2.5)
	if rarity in ["legendary", "signature"]:
		draw_arc(Vector2(0.0, bob), 37.0, -phase * 0.7, -phase * 0.7 + PI, 26, Color(1.0, 0.94, 0.72, 0.62), 2.0)
	if rarity == "signature":
		draw_arc(Vector2(0.0, bob), 44.0, phase * 0.42, phase * 0.42 + PI * 1.55, 30, Color(color.r, color.g, color.b, 0.48), 2.0)
