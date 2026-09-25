extends Node2D
class_name NomadXPOrb

signal collected(value: int)

const ORB: Texture2D = preload("res://assets/effects/xp_orb.png")

var player: NomadPlayer
var value: int = 5
var speed: float = 470.0
var age: float = 0.0
var _sprite: Sprite2D
var _phase: float = 0.0

func _ready() -> void:
	_sprite = Sprite2D.new()
	_sprite.texture = ORB
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_sprite.scale = Vector2(0.62, 0.62)
	add_child(_sprite)
	_phase = randf_range(0.0, TAU)
	z_index = 3600

func _physics_process(delta: float) -> void:
	age += delta
	_phase += delta * 4.2
	_sprite.position.y = sin(_phase) * 3.0
	if not is_instance_valid(player):
		return
	var to_player: Vector2 = player.global_position - global_position
	var dist: float = to_player.length()
	var attraction: float = player.magnet_range + 14.0 if player != null else 199.0
	if dist < attraction * 1.08 or age > 3.6:
		var multiplier: float = 1.0 + clampf((attraction - dist) / maxf(1.0, attraction), 0.0, 1.0) * 0.95
		if dist > 0.001:
			global_position += to_player.normalized() * speed * multiplier * delta
	if dist < 34.0:
		queue_free()
		collected.emit(value)
