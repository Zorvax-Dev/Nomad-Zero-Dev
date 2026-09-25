extends CharacterBody2D
class_name NomadPlayer

signal died
signal pulse_used
signal dash_used(from_position: Vector2, to_position: Vector2)
signal damaged(world_position: Vector2, amount: float)
signal dodged(world_position: Vector2, amount: float)

const IDLE: Texture2D = preload("res://assets/hero/hero_idle.png")
const IDLE_B: Texture2D = preload("res://assets/hero/hero_idle_b.png")
const RUN_A: Texture2D = preload("res://assets/hero/hero_run_a.png")
const RUN_B: Texture2D = preload("res://assets/hero/hero_run_b.png")
const RUN_C: Texture2D = preload("res://assets/hero/hero_run_c.png")
const RUN_D: Texture2D = preload("res://assets/hero/hero_run_d.png")
const RUN_E: Texture2D = preload("res://assets/hero/hero_run_e.png")
const RUN_F: Texture2D = preload("res://assets/hero/hero_run_f.png")
const ATTACK: Texture2D = preload("res://assets/hero/hero_attack.png")
const ATTACK_B: Texture2D = preload("res://assets/hero/hero_attack_b.png")
const ATTACK_C: Texture2D = preload("res://assets/hero/hero_attack_c.png")
const ATTACK_D: Texture2D = preload("res://assets/hero/hero_attack_d.png")
const DASH: Texture2D = preload("res://assets/hero/hero_dash.png")
const DASH_B: Texture2D = preload("res://assets/hero/hero_dash_b.png")
const DASH_C: Texture2D = preload("res://assets/hero/hero_dash_c.png")
const HURT: Texture2D = preload("res://assets/hero/hero_hurt.png")
const GROUND_SHADOW: Texture2D = preload("res://assets/effects/ground_shadow.png")

var world_nav: StylizedWorld
var touch_vector: Vector2 = Vector2.ZERO
var speed: float = 292.0
var max_health: float = 150.0
var health: float = 150.0
var max_shield: float = 0.0
var shield: float = 0.0
var damage: float = 29.0
var attack_interval: float = 0.44
var pulse_cooldown: float = 5.0
var pulse_timer: float = 0.0
var force_wave_radius: float = 270.0
var force_wave_damage_scale: float = 1.80
var force_wave_knockback: float = 520.0
var force_wave_auto_range: float = 225.0
var dash_cooldown: float = 2.35
var dash_timer: float = 0.0
var armor: float = 0.05
var regeneration: float = 0.35
var shield_regeneration: float = 0.0
var magnet_range: float = 235.0
var critical_chance: float = 0.08
var critical_multiplier: float = 1.80
var multishot_count: int = 1
var saber_range: float = 208.0
var saber_arc_degrees: float = 102.0
var active: bool = true
var selection_locked: bool = false

var _shadow_sprite: Sprite2D
var _sprite: Sprite2D
var _anim_time: float = 0.0
var _run_frame_index: int = 0
var _idle_frame_index: int = 0
var _attack_visual_timer: float = 0.0
var _dash_visual_timer: float = 0.0
var _hurt_visual_timer: float = 0.0
var _invulnerable_timer: float = 0.0
var _last_facing: Vector2 = Vector2.RIGHT
var _move_velocity: Vector2 = Vector2.ZERO
var _dash_velocity: Vector2 = Vector2.ZERO
var _run_frames: Array[Texture2D] = [RUN_A, RUN_B, RUN_C, RUN_D, RUN_E, RUN_F]
var _run_cycle: float = 0.0
var _idle_cycle: float = 0.0

func _ready() -> void:
	_shadow_sprite = Sprite2D.new()
	_shadow_sprite.texture = GROUND_SHADOW
	_shadow_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_shadow_sprite.scale = Vector2(0.44, 0.44)
	_shadow_sprite.position = Vector2(0.0, 48.0)
	_shadow_sprite.modulate = Color(0.92, 0.88, 0.82, 0.46)
	_shadow_sprite.z_index = -1
	add_child(_shadow_sprite)
	_sprite = Sprite2D.new()
	_sprite.texture = IDLE
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_sprite.scale = Vector2(0.435, 0.435)
	add_child(_sprite)
	_update_frame_anchor()
	z_index = int(global_position.y)
	queue_redraw()

func set_touch_vector(value: Vector2) -> void:
	touch_vector = value.limit_length(1.0)

func movement_direction() -> Vector2:
	if _move_velocity.length_squared() > 25.0:
		return _move_velocity.normalized()
	return _last_facing

func _physics_process(delta: float) -> void:
	if not active or selection_locked: return
	pulse_timer = maxf(0.0, pulse_timer - delta)
	dash_timer = maxf(0.0, dash_timer - delta)
	_attack_visual_timer = maxf(0.0, _attack_visual_timer - delta)
	_dash_visual_timer = maxf(0.0, _dash_visual_timer - delta)
	_hurt_visual_timer = maxf(0.0, _hurt_visual_timer - delta)
	_invulnerable_timer = maxf(0.0, _invulnerable_timer - delta)
	_dash_velocity = _dash_velocity.move_toward(Vector2.ZERO, 4600.0 * delta)
	if regeneration > 0.0 and health < max_health:
		health = minf(max_health, health + regeneration * delta)
	var key_vec: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var input_vec: Vector2 = touch_vector if touch_vector.length_squared() > 0.001 else key_vec
	var target_velocity: Vector2 = Vector2.ZERO
	if input_vec.length_squared() > 0.001:
		var input_strength: float = clampf(input_vec.length(), 0.0, 1.0)
		var input_dir: Vector2 = input_vec / maxf(input_strength, 0.001)
		_last_facing = input_dir
		target_velocity = input_dir * speed * input_strength
		_sprite.flip_h = input_dir.x < -0.05
	var reversing: bool = target_velocity.length_squared() > 0.0 and _move_velocity.length_squared() > 100.0 and target_velocity.dot(_move_velocity) < 0.0
	var acceleration: float = 4300.0 if reversing else (3000.0 if target_velocity.length_squared() > 0.0 else 3900.0)
	_move_velocity = _move_velocity.move_toward(target_velocity, acceleration * delta)
	var total_velocity: Vector2 = _move_velocity + _dash_velocity
	if total_velocity.length_squared() > 0.1:
		var desired: Vector2 = global_position + total_velocity * delta
		global_position = world_nav.resolve_motion(global_position, desired, 20.0) if world_nav != null else desired
	var move_speed_now: float = _move_velocity.length()
	var speed_ratio: float = clampf(move_speed_now / maxf(speed, 1.0), 0.0, 1.0)
	if _hurt_visual_timer > 0.0:
		_sprite.texture = HURT
	elif _attack_visual_timer > 0.0 and move_speed_now < 42.0:
		if _attack_visual_timer > 0.18:
			_sprite.texture = ATTACK
		elif _attack_visual_timer > 0.12:
			_sprite.texture = ATTACK_C
		elif _attack_visual_timer > 0.06:
			_sprite.texture = ATTACK_D
		else:
			_sprite.texture = ATTACK_B
	elif _dash_visual_timer > 0.0:
		if _dash_visual_timer > 0.14:
			_sprite.texture = DASH
		elif _dash_visual_timer > 0.07:
			_sprite.texture = DASH_C
		else:
			_sprite.texture = DASH_B
	elif move_speed_now > 28.0:
		_anim_time += delta
		var frame_interval: float = lerpf(0.122, 0.076, speed_ratio)
		while _anim_time >= frame_interval:
			_anim_time -= frame_interval
			_run_frame_index = (_run_frame_index + 1) % _run_frames.size()
		_sprite.texture = _run_frames[_run_frame_index]
		_run_cycle = fmod(_run_cycle + delta * lerpf(6.4, 10.6, speed_ratio), TAU)
	else:
		_anim_time += delta
		_idle_cycle = fmod(_idle_cycle + delta * 1.8, TAU)
		if _anim_time >= 0.42:
			_anim_time = 0.0
			_idle_frame_index = (_idle_frame_index + 1) % 2
		_sprite.texture = IDLE if _idle_frame_index == 0 else IDLE_B
	_update_frame_anchor()
	var base_position: Vector2 = _sprite.position
	var extra_y: float = 0.0
	var target_rotation: float = 0.0
	var target_scale: Vector2 = Vector2(0.435, 0.435)
	if _hurt_visual_timer > 0.0:
		extra_y = -1.0
		target_rotation = deg_to_rad(-3.0 if _sprite.flip_h else 3.0)
	elif _dash_visual_timer > 0.0:
		extra_y = sin((_dash_visual_timer / 0.18) * PI) * 2.2
		target_rotation = clampf(_last_facing.x, -1.0, 1.0) * 0.08
		target_scale = Vector2(0.448, 0.424)
	elif move_speed_now > 28.0:
		extra_y = sin(_run_cycle * 2.0) * lerpf(0.95, 1.9, speed_ratio)
		target_rotation = sin(_run_cycle) * 0.015 + clampf(_move_velocity.x / maxf(speed, 1.0), -1.0, 1.0) * 0.028
		var squash: float = cos(_run_cycle * 2.0) * 0.0045
		target_scale = Vector2(0.435 + squash, 0.435 - squash)
	elif _attack_visual_timer > 0.0:
		extra_y = sin((1.0 - _attack_visual_timer / 0.24) * PI) * 1.6
		target_rotation = clampf(_last_facing.x, -1.0, 1.0) * 0.026
		target_scale = Vector2(0.439, 0.431)
	else:
		extra_y = sin(_idle_cycle) * 0.55
		target_rotation = sin(_idle_cycle * 0.5) * 0.008
		var breathe: float = sin(_idle_cycle * 0.5) * 0.0025
		target_scale = Vector2(0.435 + breathe, 0.435 - breathe)
	_sprite.position = base_position + Vector2(0.0, extra_y)
	_sprite.rotation = lerpf(_sprite.rotation, target_rotation, minf(1.0, delta * 12.0))
	_sprite.scale = _sprite.scale.lerp(target_scale, minf(1.0, delta * 12.0))
	z_index = int(global_position.y)

func play_attack(target_position: Vector2) -> void:
	if not active or selection_locked:
		return
	_hurt_visual_timer = 0.0
	var facing: Vector2 = target_position - global_position
	if facing.length_squared() > 0.1:
		_last_facing = facing.normalized()
		if absf(facing.x) > 6.0:
			_sprite.flip_h = facing.x < 0.0
	# En mouvement, on conserve la foulée : l'ancienne version remplaçait la course
	# par une pose d'attaque toutes les ~0,4 s, ce qui donnait un effet saccadé.
	if _dash_visual_timer <= 0.0 and _move_velocity.length() < 42.0:
		_attack_visual_timer = maxf(_attack_visual_timer, 0.24)
		_anim_time = 0.0
		_idle_frame_index = 0
		_sprite.texture = ATTACK
		_update_frame_anchor()

func take_damage(amount: float) -> void:
	if not active or selection_locked:
		return
	if _invulnerable_timer > 0.0:
		dodged.emit(global_position, amount)
		return
	var applied: float = maxf(1.0, amount * (1.0 - clampf(armor, 0.0, 0.55)))
	health = maxf(0.0, health - applied)
	_hurt_visual_timer = 0.24
	_sprite.position.y = 0.0
	_attack_visual_timer = 0.0
	damaged.emit(global_position, applied)
	var tween: Tween = create_tween()
	_sprite.modulate = Color(1.0, 0.45, 0.42)
	tween.tween_property(_sprite, "modulate", Color.WHITE, 0.14)
	if health <= 0.0:
		active = false
		died.emit()


func set_selection_lock(locked: bool) -> void:
	selection_locked = locked
	if locked:
		touch_vector = Vector2.ZERO
		_move_velocity = Vector2.ZERO
		_dash_velocity = Vector2.ZERO

func heal(amount: float) -> void:
	if active: health = minf(max_health, health + maxf(0.0, amount))
func restore_shield(amount: float) -> void:
	if not active:
		return
	var cooldown_reduction: float = maxf(0.55, amount * 0.055)
	pulse_timer = maxf(0.0, pulse_timer - cooldown_reduction)
func heal_full() -> void:
	health = max_health
	pulse_timer = 0.0
func can_pulse() -> bool: return pulse_timer <= 0.0 and active
func trigger_pulse() -> bool:
	if not can_pulse(): return false
	pulse_timer = pulse_cooldown
	pulse_used.emit()
	return true
func can_dash() -> bool: return dash_timer <= 0.0 and active
func trigger_dash(direction: Vector2) -> bool:
	if not can_dash(): return false
	var dash_dir: Vector2 = direction.normalized() if direction.length_squared() > 0.01 else _last_facing
	if dash_dir.length_squared() <= 0.01:
		dash_dir = Vector2.RIGHT
	var from_position: Vector2 = global_position
	dash_timer = dash_cooldown
	_dash_visual_timer = 0.18
	_attack_visual_timer = 0.0
	_invulnerable_timer = 0.22
	_anim_time = 0.0
	_idle_frame_index = 0
	_dash_velocity = dash_dir * 820.0
	_move_velocity = dash_dir * maxf(220.0, speed * 0.85)
	_last_facing = dash_dir
	_sprite.position.y = 0.0
	_sprite.flip_h = dash_dir.x < -0.05
	dash_used.emit(from_position, global_position)
	return true

func _anchor_for_texture(tex: Texture2D) -> Vector2:
	# Baked alpha bounds: avoids scanning ~1M pixels on run start on mobile/web.
	if tex == IDLE: return Vector2(112.0, 251.0)
	if tex == IDLE_B: return Vector2(127.5, 256.0)
	if tex == RUN_A: return Vector2(128.5, 245.0)
	if tex == RUN_B: return Vector2(122.5, 248.0)
	if tex == RUN_C: return Vector2(123.0, 243.0)
	if tex == RUN_D: return Vector2(128.0, 231.0)
	if tex == RUN_E: return Vector2(131.0, 240.0)
	if tex == RUN_F: return Vector2(134.0, 240.0)
	if tex == ATTACK: return Vector2(130.0, 246.0)
	if tex == ATTACK_B: return Vector2(138.5, 250.0)
	if tex == ATTACK_C: return Vector2(125.5, 246.0)
	if tex == ATTACK_D: return Vector2(127.5, 246.0)
	if tex == DASH: return Vector2(134.0, 246.0)
	if tex == DASH_B: return Vector2(138.5, 248.0)
	if tex == DASH_C: return Vector2(128.0, 228.0)
	if tex == HURT: return Vector2(128.5, 254.0)
	return Vector2(128.0, 252.0)

func _update_frame_anchor() -> void:
	if _sprite == null or _sprite.texture == null:
		return
	var anchor: Vector2 = _anchor_for_texture(_sprite.texture)
	var s: float = 0.435
	var x_offset: float = (128.0 - anchor.x) * s
	if _sprite.flip_h:
		x_offset = -x_offset
	_sprite.position = Vector2(x_offset, 52.0 - (anchor.y - 128.0) * s)

func _draw() -> void:
	pass

