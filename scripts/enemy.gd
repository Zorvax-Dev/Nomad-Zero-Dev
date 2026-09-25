extends CharacterBody2D
class_name NomadEnemy

signal died(enemy: NomadEnemy, xp_value: int)
signal request_shot(enemy: NomadEnemy, target: Node2D)
signal damaged(world_position: Vector2, amount: float, was_heavy: bool, was_critical: bool)
signal phase_changed(enemy: NomadEnemy, phase: int)

const BLASTER_IDLE: Texture2D = preload("res://assets/enemies/blaster_idle.png")
const BLASTER_A: Texture2D = preload("res://assets/enemies/blaster_run_a.png")
const BLASTER_B: Texture2D = preload("res://assets/enemies/blaster_run_b.png")
const RAIDER_IDLE: Texture2D = preload("res://assets/enemies/raider_idle.png")
const RAIDER_A: Texture2D = preload("res://assets/enemies/raider_run_a.png")
const RAIDER_B: Texture2D = preload("res://assets/enemies/raider_run_b.png")
const HEAVY_IDLE: Texture2D = preload("res://assets/enemies/heavy_idle.png")
const HEAVY_A: Texture2D = preload("res://assets/enemies/heavy_run_a.png")
const HEAVY_B: Texture2D = preload("res://assets/enemies/heavy_run_b.png")
const ECHO_SCOUT_IDLE: Texture2D = preload("res://assets/enemies/echo_scout_idle.png")
const ECHO_SCOUT_A: Texture2D = preload("res://assets/enemies/echo_scout_run_a.png")
const ECHO_SCOUT_B: Texture2D = preload("res://assets/enemies/echo_scout_run_b.png")
const VEIL_TECH_IDLE: Texture2D = preload("res://assets/enemies/veil_tech_idle.png")
const VEIL_TECH_A: Texture2D = preload("res://assets/enemies/veil_tech_run_a.png")
const VEIL_TECH_B: Texture2D = preload("res://assets/enemies/veil_tech_run_b.png")
const VEIL_GUARDIAN_IDLE: Texture2D = preload("res://assets/enemies/veil_guardian_idle.png")
const VEIL_GUARDIAN_A: Texture2D = preload("res://assets/enemies/veil_guardian_run_a.png")
const VEIL_GUARDIAN_B: Texture2D = preload("res://assets/enemies/veil_guardian_run_b.png")
const SALVAGE_DRONE_IDLE: Texture2D = preload("res://assets/enemies/salvage_drone_idle.png")
const SALVAGE_DRONE_A: Texture2D = preload("res://assets/enemies/salvage_drone_run_a.png")
const SALVAGE_DRONE_B: Texture2D = preload("res://assets/enemies/salvage_drone_run_b.png")
const SCRAP_AUTOMATON_IDLE: Texture2D = preload("res://assets/enemies/scrap_automaton_idle.png")
const SCRAP_AUTOMATON_A: Texture2D = preload("res://assets/enemies/scrap_automaton_run_a.png")
const SCRAP_AUTOMATON_B: Texture2D = preload("res://assets/enemies/scrap_automaton_run_b.png")
const MOBILE_TURRET_IDLE: Texture2D = preload("res://assets/enemies/mobile_turret_idle.png")
const MOBILE_TURRET_A: Texture2D = preload("res://assets/enemies/mobile_turret_run_a.png")
const MOBILE_TURRET_B: Texture2D = preload("res://assets/enemies/mobile_turret_run_b.png")
const LEVIATHAN_GRINDER_IDLE: Texture2D = preload("res://assets/enemies/leviathan_grinder_idle.png")
const LEVIATHAN_GRINDER_A: Texture2D = preload("res://assets/enemies/leviathan_grinder_run_a.png")
const LEVIATHAN_GRINDER_B: Texture2D = preload("res://assets/enemies/leviathan_grinder_run_b.png")
const MARAUDER_BOSS: Texture2D = preload("res://assets/bosses/marauder_idle.png")
const SENTINEL_BOSS: Texture2D = preload("res://assets/bosses/sentinel_idle.png")
const ARCHON_BOSS: Texture2D = preload("res://assets/bosses/archon_idle.png")
const RESONATOR_BOSS: Texture2D = preload("res://assets/bosses/resonator_idle.png")
const SCRAP_TITAN_BOSS: Texture2D = preload("res://assets/bosses/scrap_titan_idle.png")
const BOSS_CUTOUT: Shader = preload("res://assets/bosses/boss_cutout.gdshader")
const GROUND_SHADOW: Texture2D = preload("res://assets/effects/ground_shadow.png")

var kind: String = "blaster"
var elite: bool = false
var affix: String = ""
var attack_speed_multiplier: float = 1.0
var damage_taken_multiplier: float = 1.0
var target: NomadPlayer
var world_nav: StylizedWorld
var speed: float = 98.0
var max_health: float = 48.0
var health: float = 48.0
var damage: float = 10.0
var ranged_attack_range: float = 285.0
var attack_timer: float = 0.0
var active: bool = true
var xp_value: int = 5
# The warning is transient, like a projectile: a restored boss starts a fresh attack.
var windup_left: float = 0.0
var windup_duration: float = 0.0
var windup_position: Vector2 = Vector2.ZERO
var windup_direction: Vector2 = Vector2.ZERO
var windup_pattern: String = ""
var boss_attack_index: int = 0
var phase_two: bool = false
var exposed_timer: float = 0.0
var beam_flash_left: float = 0.0
var role_action_timer: float = 0.0
var affix_action_timer: float = 0.0
var role_windup_left: float = 0.0
var role_windup_duration: float = 0.0
var role_windup_pattern: String = ""
var role_locked_position: Vector2 = Vector2.ZERO
var role_locked_direction: Vector2 = Vector2.RIGHT
var affix_windup_left: float = 0.0
var affix_windup_duration: float = 0.0
var affix_windup_pattern: String = ""
var affix_locked_direction: Vector2 = Vector2.RIGHT
var strafe_sign: float = 1.0

var _shadow_sprite: Sprite2D
var _sprite: Sprite2D
var _anim_time: float = 0.0
var _run_frame: bool = false
var _knockback_velocity: Vector2 = Vector2.ZERO
var _stagger_timer: float = 0.0
var _base_sprite_scale: Vector2 = Vector2.ONE
var _stuck_time: float = 0.0
var _detour_time: float = 0.0
var _detour_direction: Vector2 = Vector2.ZERO
var _detour_sign: float = 1.0
var _run_cycle: float = 0.0
var _idle_cycle: float = 0.0
var visual_quality: int = 2
var _visual_redraw_cooldown: float = 0.0
var _los_check_timer: float = 0.0
var _los_cache_result: bool = true

func setup(enemy_kind: String, difficulty: float, elite_mode: bool = false, enemy_affix: String = "") -> void:
	kind = enemy_kind
	elite = elite_mode
	affix = enemy_affix
	attack_speed_multiplier = 1.0
	damage_taken_multiplier = 1.0
	match kind:
		"raider":
			speed = 132.0
			max_health = 64.0 * difficulty
			damage = 12.0 * difficulty
			xp_value = 7
		"stalker":
			speed = 158.0
			max_health = 54.0 * difficulty
			damage = 11.5 * difficulty
			xp_value = 8
		"sniper":
			speed = 84.0
			max_health = 58.0 * difficulty
			damage = 16.5 * difficulty
			ranged_attack_range = 505.0
			xp_value = 10
		"suppressor":
			speed = 94.0
			max_health = 76.0 * difficulty
			damage = 9.0 * difficulty
			ranged_attack_range = 345.0
			xp_value = 11
		"breaker":
			speed = 79.0
			max_health = 172.0 * difficulty
			damage = 21.0 * difficulty
			xp_value = 16
		"heavy":
			speed = 73.0
			max_health = 145.0 * difficulty
			damage = 18.0 * difficulty
			xp_value = 13
		"echo_scout":
			speed = 164.0
			max_health = 64.0 * difficulty
			damage = 12.0 * difficulty
			xp_value = 12
		"veil_tech":
			speed = 76.0
			max_health = 82.0 * difficulty
			damage = 12.5 * difficulty
			ranged_attack_range = 350.0
			xp_value = 14
		"veil_guardian":
			speed = 64.0
			max_health = 360.0 * difficulty
			damage = 25.0 * difficulty
			xp_value = 48
		"salvage_drone":
			speed = 152.0
			max_health = 58.0 * difficulty
			damage = 9.5 * difficulty
			ranged_attack_range = 330.0
			xp_value = 11
		"scrap_automaton":
			speed = 82.0
			max_health = 158.0 * difficulty
			damage = 18.5 * difficulty
			xp_value = 16
		"mobile_turret":
			speed = 56.0
			max_health = 108.0 * difficulty
			damage = 13.0 * difficulty
			ranged_attack_range = 430.0
			xp_value = 15
		"leviathan_grinder":
			speed = 68.0
			max_health = 395.0 * difficulty
			damage = 25.5 * difficulty
			xp_value = 52
		"phantom":
			speed = 118.0
			max_health = 225.0 * difficulty
			damage = 18.5 * difficulty
			ranged_attack_range = 430.0
			xp_value = 34
		"colossus":
			speed = 64.0
			max_health = 345.0 * difficulty
			damage = 27.0 * difficulty
			xp_value = 40
		"marauder":
			speed = 148.0
			max_health = 360.0 * difficulty
			damage = 25.0 * difficulty
			xp_value = 72
		"sentinel":
			speed = 68.0
			max_health = 420.0 * difficulty
			damage = 21.0 * difficulty
			xp_value = 60
		"archon":
			speed = 83.0
			max_health = 390.0 * difficulty
			damage = 23.0 * difficulty
			xp_value = 68
		"warden":
			speed = 91.0
			max_health = 475.0 * difficulty
			damage = 22.5 * difficulty
			xp_value = 78
		"reaper":
			speed = 154.0
			max_health = 445.0 * difficulty
			damage = 27.5 * difficulty
			xp_value = 84
		"resonator":
			speed = 72.0
			max_health = 520.0 * difficulty
			damage = 25.0 * difficulty
			ranged_attack_range = 380.0
			xp_value = 98
		"scrap_titan":
			speed = 66.0
			max_health = 565.0 * difficulty
			damage = 26.0 * difficulty
			ranged_attack_range = 365.0
			xp_value = 108
		_:
			speed = 96.0
			max_health = 46.0 * difficulty
			damage = 8.5 * difficulty
			xp_value = 5
	if elite and not is_boss():
		max_health *= 1.65
		damage *= 1.16
		speed *= 1.05
		xp_value *= 2
	match affix:
		"swift":
			speed *= 1.28
			max_health *= 0.88
			attack_speed_multiplier = 1.25
		"bulwark":
			max_health *= 1.34
			speed *= 0.86
			damage *= 1.06
			damage_taken_multiplier = 0.82
		"overcharged":
			damage *= 1.28
			max_health *= 0.94
			attack_speed_multiplier = 1.28
		"void":
			max_health *= 1.15
			damage *= 1.14
			damage_taken_multiplier = 0.92
			xp_value = int(round(float(xp_value) * 1.40))
	health = max_health
	role_action_timer = 0.0
	affix_action_timer = 0.0
	role_windup_left = 0.0
	role_windup_duration = 0.0
	role_windup_pattern = ""
	affix_windup_left = 0.0
	affix_windup_duration = 0.0
	affix_windup_pattern = ""

func _ready() -> void:
	_shadow_sprite = Sprite2D.new()
	_shadow_sprite.texture = GROUND_SHADOW
	_shadow_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_shadow_sprite.z_index = -1
	_shadow_sprite.modulate = Color(0.90, 0.86, 0.80, 0.42)
	add_child(_shadow_sprite)
	_sprite = Sprite2D.new()
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var scale_value: float = 0.46
	if kind == "raider": scale_value = 0.47
	if kind == "stalker": scale_value = 0.45
	if kind == "sniper": scale_value = 0.44
	if kind == "suppressor": scale_value = 0.49
	if kind == "breaker": scale_value = 0.58
	if kind == "heavy": scale_value = 0.54
	if kind == "echo_scout": scale_value = 0.48
	if kind == "veil_tech": scale_value = 0.47
	if kind == "veil_guardian": scale_value = 0.64
	if kind == "salvage_drone": scale_value = 0.54
	if kind == "scrap_automaton": scale_value = 0.55
	if kind == "mobile_turret": scale_value = 0.54
	if kind == "leviathan_grinder": scale_value = 0.68
	if kind == "phantom": scale_value = 0.56
	if kind == "colossus": scale_value = 0.68
	if kind == "marauder": scale_value = 0.248188
	if kind == "sentinel": scale_value = 0.240023
	if kind == "archon": scale_value = 0.246555
	if kind == "warden": scale_value = 0.244922
	if kind == "reaper": scale_value = 0.251453
	if kind == "resonator": scale_value = 0.238
	if kind == "scrap_titan": scale_value = 0.246
	_sprite.scale = Vector2(scale_value, scale_value)
	_base_sprite_scale = _sprite.scale
	strafe_sign = -1.0 if int(get_instance_id()) % 2 == 0 else 1.0
	_detour_sign = strafe_sign
	var shadow_scale: float = 0.68 if is_boss() else scale_value * 0.96
	_shadow_sprite.scale = Vector2(shadow_scale, shadow_scale * 0.82)
	_shadow_sprite.position = Vector2(0.0, 80.0 if is_boss() else 46.0 + (scale_value - 0.46) * 42.0)
	if is_boss():
		var boss_material: ShaderMaterial = ShaderMaterial.new()
		boss_material.shader = BOSS_CUTOUT
		_sprite.material = boss_material
		if kind == "warden":
			_sprite.modulate = Color(0.40, 0.96, 1.0)
		elif kind == "reaper":
			_sprite.modulate = Color(1.0, 0.38, 0.62)
		elif kind == "resonator":
			_sprite.modulate = Color(0.92, 0.78, 1.0)
		elif kind == "scrap_titan":
			_sprite.modulate = Color(0.88, 0.71, 0.49)
	elif affix == "swift":
		_sprite.modulate = Color(0.72, 0.84, 0.86)
	elif affix == "bulwark":
		_sprite.modulate = Color(0.73, 0.75, 0.80)
	elif affix == "overcharged":
		_sprite.modulate = Color(0.92, 0.62, 0.43)
	elif affix == "void":
		_sprite.modulate = Color(0.72, 0.58, 0.82)
	elif elite:
		_sprite.modulate = Color(0.88, 0.72, 0.45)
	elif kind == "stalker":
		_sprite.modulate = Color(0.63, 0.84, 0.69)
	elif kind == "sniper":
		_sprite.modulate = Color(0.62, 0.78, 0.86)
	elif kind == "suppressor":
		_sprite.modulate = Color(0.88, 0.64, 0.38)
	elif kind == "breaker":
		_sprite.modulate = Color(0.86, 0.53, 0.38)
	elif kind == "salvage_drone":
		_sprite.modulate = Color(0.68, 0.82, 0.82)
	elif kind == "scrap_automaton":
		_sprite.modulate = Color(0.80, 0.62, 0.44)
	elif kind == "mobile_turret":
		_sprite.modulate = Color(0.78, 0.70, 0.56)
	elif kind == "leviathan_grinder":
		_sprite.modulate = Color(0.76, 0.55, 0.38)
	elif kind == "phantom":
		_sprite.modulate = Color(0.58, 0.84, 1.0)
	elif kind == "colossus":
		_sprite.modulate = Color(1.0, 0.66, 0.30)
	elif kind == "warden":
		_sprite.modulate = Color(0.40, 0.96, 1.0)
	elif kind == "reaper":
		_sprite.modulate = Color(1.0, 0.38, 0.62)
	add_child(_sprite)
	_set_idle()
	queue_redraw()

func set_visual_quality(level: int) -> void:
	visual_quality = clampi(level, 0, 2)
	_visual_redraw_cooldown = 0.0
	queue_redraw()

func _request_visual_redraw(force: bool = false) -> void:
	if force or visual_quality >= 2:
		queue_redraw()
		return
	if _visual_redraw_cooldown > 0.0:
		return
	_visual_redraw_cooldown = 0.045 if visual_quality == 1 else 0.075
	queue_redraw()

func is_boss() -> bool:
	return kind in ["sentinel", "marauder", "archon", "warden", "reaper", "resonator", "scrap_titan"]

func is_miniboss() -> bool:
	return kind in ["phantom", "colossus", "veil_guardian", "leviathan_grinder"]

func _physics_process(delta: float) -> void:
	_visual_redraw_cooldown = maxf(0.0, _visual_redraw_cooldown - delta)
	_los_check_timer = maxf(0.0, _los_check_timer - delta)
	if not active or not is_instance_valid(target):
		return
	attack_timer = maxf(0.0, attack_timer - delta)
	role_action_timer = maxf(0.0, role_action_timer - delta)
	affix_action_timer = maxf(0.0, affix_action_timer - delta)
	if affix == "void" or affix == "overcharged":
		_request_visual_redraw()
	if exposed_timer > 0.0:
		exposed_timer = maxf(0.0, exposed_timer - delta)
		_request_visual_redraw()
	if beam_flash_left > 0.0:
		beam_flash_left = maxf(0.0, beam_flash_left - delta)
		_request_visual_redraw()
	_stagger_timer = maxf(0.0, _stagger_timer - delta)
	_knockback_velocity = _knockback_velocity.move_toward(Vector2.ZERO, 1900.0 * delta)
	if _knockback_velocity.length_squared() > 9.0:
		var knock_target: Vector2 = global_position + _knockback_velocity * delta
		var knock_radius: float = 29.0 if kind in ["colossus", "veil_guardian", "leviathan_grinder"] else (24.0 if kind in ["heavy", "breaker", "scrap_automaton", "mobile_turret"] or is_boss() else 20.0)
		global_position = world_nav.resolve_motion(global_position, knock_target, knock_radius) if world_nav != null else knock_target
	if _stagger_timer > 0.0:
		z_index = int(global_position.y)
		return
	if role_windup_left > 0.0:
		role_windup_left = maxf(0.0, role_windup_left - delta)
		_request_visual_redraw()
		if role_windup_left <= 0.0:
			_finish_role_action()
		_set_idle()
		z_index = int(global_position.y)
		return
	if affix_windup_left > 0.0:
		affix_windup_left = maxf(0.0, affix_windup_left - delta)
		_request_visual_redraw()
		if affix_windup_left <= 0.0:
			_finish_affix_action()
		_set_idle()
		z_index = int(global_position.y)
		return
	if windup_left > 0.0:
		windup_left = maxf(0.0, windup_left - delta)
		_request_visual_redraw()
		if windup_left <= 0.0:
			_finish_boss_attack()
		_set_idle()
		z_index = int(global_position.y)
		return
	var to_target: Vector2 = target.global_position - global_position
	var dist: float = to_target.length()
	var moving: bool = false
	# V44.41: elite mobility is telegraphed before it happens.
	if not is_boss() and dist > 0.01 and affix_action_timer <= 0.0:
		if affix == "swift" and dist < 250.0:
			_start_affix_windup("swift_dodge", 0.18, to_target)
		elif affix == "void" and dist > 110.0 and dist < 430.0:
			_start_affix_windup("void_blink", 0.34, to_target)
	if affix_windup_left > 0.0:
		_set_idle()
		z_index = int(global_position.y)
		return
	match kind:
		"raider":
			if dist > 150.0:
				_move_dir((to_target.normalized() + to_target.normalized().orthogonal() * strafe_sign * 0.18).normalized(), delta)
				moving = true
			elif dist > 62.0 and role_action_timer <= 0.0:
				_start_role_windup("raider_hook", 0.24 / minf(1.12, attack_speed_multiplier), to_target)
			elif dist > 46.0:
				_move_dir(to_target.normalized().rotated(0.16 * strafe_sign), delta)
				moving = true
			elif attack_timer <= 0.0:
				attack_timer = 0.72 / attack_speed_multiplier
				target.take_damage(damage)
		"stalker":
			if dist > 150.0:
				_move_dir(to_target.normalized(), delta)
				moving = true
			elif dist > 62.0 and role_action_timer <= 0.0:
				_start_role_windup("stalker_lunge", 0.32, to_target)
			elif dist > 46.0:
				var flank: Vector2 = (to_target.normalized() + to_target.normalized().orthogonal() * strafe_sign * 0.42).normalized()
				_move_dir(flank, delta)
				moving = true
			elif attack_timer <= 0.0:
				attack_timer = 0.64 / attack_speed_multiplier
				target.take_damage(damage)
		"sniper":
			if dist > ranged_attack_range + 28.0:
				_move_dir(to_target.normalized(), delta)
				moving = true
			elif dist < ranged_attack_range - 185.0:
				_move_dir(-to_target.normalized(), delta)
				moving = true
			elif not _has_clear_shot():
				_move_dir(_line_reposition_direction(to_target), delta * 0.82)
				moving = true
			elif attack_timer <= 0.0:
				_start_role_windup("sniper_lock", 0.78 / minf(1.18, attack_speed_multiplier), to_target)
			else:
				_move_dir(to_target.normalized().orthogonal() * strafe_sign, delta * 0.34)
				moving = true
		"suppressor":
			if dist > ranged_attack_range + 25.0:
				_move_dir(to_target.normalized(), delta)
				moving = true
			elif dist < ranged_attack_range - 140.0:
				_move_dir(-to_target.normalized(), delta)
				moving = true
			elif not _has_clear_shot():
				_move_dir(_line_reposition_direction(to_target), delta * 0.72)
				moving = true
			elif attack_timer <= 0.0:
				_start_role_windup("suppressor_burst", 0.42 / minf(1.16, attack_speed_multiplier), to_target)
		"breaker":
			if dist > 118.0 and dist < 330.0 and role_action_timer <= 0.0:
				_start_role_windup("breaker_charge", 0.58 / minf(1.12, attack_speed_multiplier), to_target)
			elif dist > 86.0:
				_move_dir(to_target.normalized(), delta)
				moving = true
			elif attack_timer <= 0.0:
				attack_timer = 1.34 / attack_speed_multiplier
				target.take_damage(damage)
		"heavy":
			if dist > 118.0:
				_move_dir(to_target.normalized(), delta)
				moving = true
			elif dist <= 108.0 and role_action_timer <= 0.0:
				_start_role_windup("heavy_slam", 0.72 / minf(1.10, attack_speed_multiplier), to_target)
			elif dist > 70.0:
				_move_dir(to_target.normalized(), delta * 0.55)
				moving = true
			elif attack_timer <= 0.0:
				attack_timer = 1.26 / attack_speed_multiplier
				target.take_damage(damage * 0.84)
		"echo_scout":
			if dist > 185.0:
				_move_dir((to_target.normalized() + to_target.normalized().orthogonal() * strafe_sign * 0.28).normalized(), delta)
				moving = true
			elif dist > 72.0 and role_action_timer <= 0.0:
				_start_role_windup("echo_dash", 0.36, to_target)
			elif dist > 48.0:
				_move_dir(to_target.normalized().rotated(0.22 * strafe_sign), delta)
				moving = true
			elif attack_timer <= 0.0:
				attack_timer = 0.58 / attack_speed_multiplier
				target.take_damage(damage)
		"veil_tech":
			if dist > ranged_attack_range + 36.0:
				_move_dir(to_target.normalized(), delta)
				moving = true
			elif dist < 210.0:
				_move_dir(-to_target.normalized(), delta)
				moving = true
			elif not _has_clear_shot():
				_move_dir(_line_reposition_direction(to_target), delta * 0.68)
				moving = true
			elif role_action_timer <= 0.0:
				_start_role_windup("veil_mine", 0.84, to_target)
			else:
				_move_dir(to_target.normalized().orthogonal() * strafe_sign, delta * 0.24)
				moving = true
		"veil_guardian":
			if dist > 165.0:
				_move_dir(to_target.normalized(), delta)
				moving = true
			elif role_action_timer <= 0.0:
				_start_role_windup("guardian_shards", 1.02, to_target)
			elif dist <= 74.0 and attack_timer <= 0.0:
				attack_timer = 1.36
				target.take_damage(damage * 0.74)
		"salvage_drone":
			if dist > ranged_attack_range + 34.0:
				_move_dir(to_target.normalized(), delta)
				moving = true
			elif dist < 175.0:
				_move_dir((-to_target.normalized() + to_target.normalized().orthogonal() * strafe_sign * 0.52).normalized(), delta)
				moving = true
			elif not _has_clear_shot():
				_move_dir(_line_reposition_direction(to_target), delta * 0.86)
				moving = true
			elif role_action_timer <= 0.0:
				_start_role_windup("drone_burst", 0.34, to_target)
			else:
				_move_dir(to_target.normalized().orthogonal() * strafe_sign, delta * 0.46)
				moving = true
		"scrap_automaton":
			if dist > 116.0 and dist < 340.0 and role_action_timer <= 0.0:
				_start_role_windup("automaton_ram", 0.58, to_target)
			elif dist > 78.0:
				_move_dir(to_target.normalized(), delta)
				moving = true
			elif attack_timer <= 0.0:
				attack_timer = 1.24 / attack_speed_multiplier
				target.take_damage(damage)
		"mobile_turret":
			if dist > ranged_attack_range + 26.0:
				_move_dir(to_target.normalized(), delta)
				moving = true
			elif dist < ranged_attack_range - 170.0:
				_move_dir(-to_target.normalized(), delta)
				moving = true
			elif not _has_clear_shot():
				_move_dir(_line_reposition_direction(to_target), delta * 0.56)
				moving = true
			elif role_action_timer <= 0.0:
				_start_role_windup("turret_lock", 0.62, to_target)
		"leviathan_grinder":
			if dist > 142.0:
				_move_dir(to_target.normalized(), delta)
				moving = true
			elif role_action_timer <= 0.0:
				_start_role_windup("grinder_spin", 0.88, to_target)
			elif dist <= 76.0 and attack_timer <= 0.0:
				attack_timer = 1.42
				target.take_damage(damage * 0.74)
		"blaster":
			var preferred_range: float = ranged_attack_range
			if dist > preferred_range + 34.0:
				_move_dir((to_target.normalized() + to_target.normalized().orthogonal() * strafe_sign * 0.16).normalized(), delta)
				moving = true
			elif dist < preferred_range - 120.0:
				_move_dir((-to_target.normalized() + to_target.normalized().orthogonal() * strafe_sign * 0.30).normalized(), delta)
				moving = true
			elif not _has_clear_shot():
				_move_dir(_line_reposition_direction(to_target), delta * 0.74)
				moving = true
			elif attack_timer <= 0.0 and role_action_timer <= 0.0:
				_start_role_windup("blaster_double", 0.30 / minf(1.14, attack_speed_multiplier), to_target)
			else:
				_move_dir(to_target.normalized().orthogonal() * strafe_sign, delta * 0.22)
				moving = true
		"phantom":
			if dist > ranged_attack_range + 30.0:
				_move_dir(to_target.normalized(), delta)
				moving = true
			elif dist < 245.0:
				_move_dir(-to_target.normalized(), delta)
				moving = true
			elif not _has_clear_shot():
				_move_dir(_line_reposition_direction(to_target), delta * 0.78)
				moving = true
			elif attack_timer <= 0.0 and role_action_timer <= 0.0:
				_start_role_windup("phantom_volley", 0.64, to_target)
			else:
				_move_dir(to_target.normalized().orthogonal() * strafe_sign, delta * 0.42)
				moving = true
		"colossus":
			if dist > 150.0:
				_move_dir(to_target.normalized(), delta)
				moving = true
			elif role_action_timer <= 0.0:
				_start_role_windup("colossus_quake", 0.82, to_target)
			elif attack_timer <= 0.0 and dist <= 82.0:
				attack_timer = 1.45
				target.take_damage(damage * 0.72)
		"marauder":
			var marauder_ratio: float = health / maxf(1.0, max_health)
			var marauder_range: float = 62.0 if marauder_ratio > 0.45 else 82.0
			if dist > marauder_range:
				_move_dir(to_target.normalized(), delta)
				moving = true
			elif attack_timer <= 0.0:
				_start_boss_attack(0.78 if marauder_ratio > 0.45 else 0.68, _next_boss_pattern())
		"sentinel":
			var hp_ratio: float = health / maxf(1.0, max_health)
			if dist > 330.0:
				_move_dir(to_target.normalized(), delta)
				moving = true
			elif dist < 175.0:
				_move_dir(-to_target.normalized(), delta)
				moving = true
			elif attack_timer <= 0.0:
				_start_boss_attack(0.76 if hp_ratio > 0.33 else 0.68, _next_boss_pattern())
		"archon":
			if dist > 370.0:
				_move_dir(to_target.normalized(), delta)
				moving = true
			elif dist < 155.0:
				_move_dir(-to_target.normalized(), delta)
				moving = true
			elif attack_timer <= 0.0:
				_start_boss_attack(0.86 if health > max_health * 0.4 else 0.75, _next_boss_pattern())
		"warden":
			if dist > 355.0:
				_move_dir(to_target.normalized(), delta)
				moving = true
			elif dist < 205.0:
				_move_dir(-to_target.normalized(), delta)
				moving = true
			elif attack_timer <= 0.0:
				_start_boss_attack(0.82 if not phase_two else 0.70, _next_boss_pattern())
		"reaper":
			if dist > 205.0:
				_move_dir(to_target.normalized(), delta)
				moving = true
			elif attack_timer <= 0.0:
				_start_boss_attack(0.76 if not phase_two else 0.64, _next_boss_pattern())
		"resonator":
			if dist > 390.0:
				_move_dir(to_target.normalized(), delta)
				moving = true
			elif dist < 165.0:
				_move_dir(-to_target.normalized(), delta)
				moving = true
			elif attack_timer <= 0.0:
				_start_boss_attack(0.96 if not phase_two else 0.78, _next_boss_pattern())
		"scrap_titan":
			if dist > 365.0:
				_move_dir(to_target.normalized(), delta)
				moving = true
			elif dist < 190.0:
				_move_dir(-to_target.normalized(), delta)
				moving = true
			elif attack_timer <= 0.0:
				_start_boss_attack(0.92 if not phase_two else 0.74, _next_boss_pattern())
		_:
			if dist > ranged_attack_range:
				_move_dir(to_target.normalized(), delta)
				moving = true
			elif dist < 155.0:
				_move_dir(-to_target.normalized(), delta)
				moving = true
			elif attack_timer <= 0.0:
				attack_timer = 1.28 / attack_speed_multiplier
				request_shot.emit(self, target)
	if not moving and not is_boss():
		moving = _apply_passive_crowd_separation(delta)
	if moving:
		_animate_run(delta, to_target.x)
	else:
		_animate_idle(delta, to_target.x)
	z_index = int(global_position.y)

func _start_role_windup(pattern: String, duration: float, to_target: Vector2) -> void:
	if role_windup_left > 0.0 or not active:
		return
	role_windup_pattern = pattern
	role_windup_duration = maxf(0.08, duration)
	role_windup_left = role_windup_duration
	role_locked_position = target.global_position if is_instance_valid(target) else global_position + to_target
	role_locked_direction = to_target.normalized() if to_target.length_squared() > 0.01 else Vector2.RIGHT
	queue_redraw()

func _finish_role_action() -> void:
	if not active or not is_instance_valid(target) or not target.active:
		role_windup_pattern = ""
		return
	var pattern: String = role_windup_pattern
	match pattern:
		"raider_hook":
			var hook_start: Vector2 = global_position
			var side_dir: Vector2 = role_locked_direction.orthogonal() * strafe_sign
			var hook_dir: Vector2 = (role_locked_direction * 0.82 + side_dir * 0.42).normalized()
			var hook_distance: float = minf(108.0, maxf(54.0, hook_start.distance_to(role_locked_position) - 34.0))
			var hook_target: Vector2 = hook_start + hook_dir * hook_distance
			global_position = world_nav.resolve_motion(hook_start, hook_target, 20.0) if world_nav != null else hook_target
			strafe_sign *= -1.0
			role_action_timer = 1.55
			var closest_hook: Vector2 = Geometry2D.get_closest_point_to_segment(target.global_position, hook_start, global_position)
			if closest_hook.distance_to(target.global_position) <= 46.0:
				target.take_damage(damage * 0.70)
		"heavy_slam":
			role_action_timer = 2.80
			attack_timer = 0.95 / attack_speed_multiplier
			if target.global_position.distance_to(global_position) <= 104.0:
				target.take_damage(damage * 0.92)
		"blaster_double":
			request_shot.emit(self, target)
			attack_timer = 1.36 / attack_speed_multiplier
			role_action_timer = 0.78
			strafe_sign *= -1.0
		"stalker_lunge":
			var lunge_start: Vector2 = global_position
			var locked_dist: float = lunge_start.distance_to(role_locked_position)
			var lunge_target: Vector2 = lunge_start + role_locked_direction * minf(118.0, maxf(30.0, locked_dist - 38.0))
			global_position = world_nav.resolve_motion(lunge_start, lunge_target, 20.0) if world_nav != null else lunge_target
			role_action_timer = 2.0
			var closest_lunge: Vector2 = Geometry2D.get_closest_point_to_segment(target.global_position, lunge_start, global_position)
			if closest_lunge.distance_to(target.global_position) <= 52.0:
				target.take_damage(damage * 0.72)
		"sniper_lock":
			request_shot.emit(self, target)
			attack_timer = 2.15 / attack_speed_multiplier
		"suppressor_burst":
			request_shot.emit(self, target)
			attack_timer = 1.58 / attack_speed_multiplier
		"breaker_charge":
			var charge_start: Vector2 = global_position
			var locked_dist_charge: float = charge_start.distance_to(role_locked_position)
			var charge_target: Vector2 = charge_start + role_locked_direction * minf(175.0, maxf(68.0, locked_dist_charge - 52.0))
			global_position = world_nav.resolve_motion(charge_start, charge_target, 25.0) if world_nav != null else charge_target
			role_action_timer = 3.35
			var closest_charge: Vector2 = Geometry2D.get_closest_point_to_segment(target.global_position, charge_start, global_position)
			if closest_charge.distance_to(target.global_position) <= 68.0:
				target.take_damage(damage * 0.88)
		"echo_dash":
			var dash_start: Vector2 = global_position
			var dash_distance: float = minf(190.0, maxf(82.0, dash_start.distance_to(role_locked_position) - 44.0))
			var dash_target: Vector2 = dash_start + role_locked_direction * dash_distance
			global_position = world_nav.resolve_motion(dash_start, dash_target, 20.0) if world_nav != null else dash_target
			role_action_timer = 2.45
			strafe_sign *= -1.0
			var closest_echo: Vector2 = Geometry2D.get_closest_point_to_segment(target.global_position, dash_start, global_position)
			if closest_echo.distance_to(target.global_position) <= 46.0:
				target.take_damage(damage * 0.78)
		"veil_mine":
			role_action_timer = 3.25
			if target.global_position.distance_to(role_locked_position) <= 82.0:
				target.take_damage(damage * 0.80)
			request_shot.emit(self, target)
		"guardian_shards":
			role_action_timer = 3.70
			var side_axis: Vector2 = role_locked_direction.orthogonal() * 96.0
			for shard_center: Vector2 in [role_locked_position, role_locked_position + side_axis, role_locked_position - side_axis]:
				if target.global_position.distance_to(shard_center) <= 58.0:
					target.take_damage(damage * 0.82)
					break
		"drone_burst":
			request_shot.emit(self, target)
			attack_timer = 1.24 / attack_speed_multiplier
			role_action_timer = 1.52
			strafe_sign *= -1.0
		"automaton_ram":
			var ram_start: Vector2 = global_position
			var ram_target: Vector2 = ram_start + role_locked_direction * minf(210.0, maxf(82.0, ram_start.distance_to(role_locked_position) - 45.0))
			global_position = world_nav.resolve_motion(ram_start, ram_target, 24.0) if world_nav != null else ram_target
			role_action_timer = 3.15
			var closest_ram: Vector2 = Geometry2D.get_closest_point_to_segment(target.global_position, ram_start, global_position)
			if closest_ram.distance_to(target.global_position) <= 62.0:
				target.take_damage(damage * 0.88)
		"turret_lock":
			request_shot.emit(self, target)
			attack_timer = 1.72 / attack_speed_multiplier
			role_action_timer = 1.66
		"grinder_spin":
			role_action_timer = 3.55
			if target.global_position.distance_to(global_position) <= 108.0:
				target.take_damage(damage * 0.90)
		"phantom_volley":
			request_shot.emit(self, target)
			var blink_side: Vector2 = role_locked_direction.orthogonal() * strafe_sign
			var blink_target: Vector2 = global_position + blink_side * 118.0
			global_position = world_nav.resolve_motion(global_position, blink_target, 22.0) if world_nav != null else blink_target
			strafe_sign *= -1.0
			attack_timer = 2.05
			role_action_timer = 2.55
		"colossus_quake":
			role_action_timer = 3.45
			if target.global_position.distance_to(role_locked_position) <= 112.0:
				target.take_damage(damage * 0.92)
	role_windup_pattern = ""
	role_windup_left = 0.0
	queue_redraw()

func _start_affix_windup(pattern: String, duration: float, to_target: Vector2) -> void:
	if affix_windup_left > 0.0 or not active:
		return
	affix_windup_pattern = pattern
	affix_windup_duration = maxf(0.08, duration)
	affix_windup_left = affix_windup_duration
	affix_locked_direction = to_target.normalized() if to_target.length_squared() > 0.01 else Vector2.RIGHT
	queue_redraw()

func _finish_affix_action() -> void:
	if not active:
		affix_windup_pattern = ""
		return
	match affix_windup_pattern:
		"swift_dodge":
			var dodge_target: Vector2 = global_position + affix_locked_direction.orthogonal() * strafe_sign * 86.0
			global_position = world_nav.resolve_motion(global_position, dodge_target, 20.0) if world_nav != null else dodge_target
			strafe_sign *= -1.0
			affix_action_timer = 2.6
		"void_blink":
			var blink_target: Vector2 = global_position + affix_locked_direction.orthogonal() * strafe_sign * 118.0
			global_position = world_nav.resolve_motion(global_position, blink_target, 22.0) if world_nav != null else blink_target
			strafe_sign *= -1.0
			affix_action_timer = 4.2
	affix_windup_pattern = ""
	affix_windup_left = 0.0
	queue_redraw()

func has_active_telegraph() -> bool:
	return windup_left > 0.0 or role_windup_left > 0.0 or affix_windup_left > 0.0

func telegraph_label() -> String:
	if windup_left > 0.0:
		return "BOSS"
	match role_windup_pattern:
		"raider_hook": return "RAIDER"
		"heavy_slam": return "LOURD"
		"blaster_double": return "BLASTER"
		"sniper_lock": return "SNIPER"
		"suppressor_burst": return "SUPPRESSEUR"
		"breaker_charge": return "BRISEUR"
		"stalker_lunge": return "PISTEUR"
		"phantom_volley": return "CHASSEUR PHASE"
		"colossus_quake": return "COLOSSE"
		"echo_dash": return "ÉCLAIREUR"
		"veil_mine": return "TECHNICIEN"
		"guardian_shards": return "GARDIEN DU VOILE"
		"drone_burst": return "DRONE"
		"automaton_ram": return "AUTOMATE"
		"turret_lock": return "TOURELLE"
		"grinder_spin": return "BROYEUR"
	match affix_windup_pattern:
		"void_blink": return "VOID"
		"swift_dodge": return "SWIFT"
	return ""

func _next_boss_pattern() -> String:
	var slot: int = boss_attack_index % (3 if phase_two else 2)
	boss_attack_index += 1
	match kind:
		"marauder": return "slam" if slot == 0 else ("charge" if slot == 1 else "cross")
		"sentinel": return "fan" if slot == 0 else ("sniper" if slot == 1 else "rails")
		"archon": return "beam" if slot == 0 else ("triad" if slot == 1 else "halo")
		"warden": return "grid" if slot == 0 else ("burst" if slot == 1 else "cage")
		"reaper": return "leap" if slot == 0 else ("cleave" if slot == 1 else "shockring")
		"resonator": return "echo_lines" if slot == 0 else ("echo_pulse" if slot == 1 else "echo_collapse")
		"scrap_titan": return "magnet_rails" if slot == 0 else ("scrap_burst" if slot == 1 else "crusher_ring")
		_: return ""

func _start_boss_attack(duration: float, pattern: String = "") -> void:
	windup_duration = duration
	windup_left = duration
	windup_position = target.global_position
	windup_direction = (windup_position - global_position).normalized()
	windup_pattern = pattern
	if windup_pattern.is_empty():
		match kind:
			"marauder": windup_pattern = "slam"
			"sentinel": windup_pattern = "fan"
			"archon": windup_pattern = "beam"
			"warden": windup_pattern = "grid"
			"reaper": windup_pattern = "leap"
			"resonator": windup_pattern = "echo_lines"
			"scrap_titan": windup_pattern = "magnet_rails"
	queue_redraw()

func _archon_triad_centers() -> Array[Vector2]:
	var side: Vector2 = windup_direction.orthogonal() * 110.0
	return [windup_position, windup_position + side, windup_position - side]

func _finish_boss_attack() -> void:
	if not active or not is_instance_valid(target) or not target.active:
		return
	if kind == "marauder":
		if windup_pattern == "charge":
			var start_position: Vector2 = global_position
			var destination: Vector2 = start_position + windup_direction * 230.0
			global_position = world_nav.resolve_motion(start_position, destination, 24.0) if world_nav != null else destination
			var closest: Vector2 = Geometry2D.get_closest_point_to_segment(target.global_position, start_position, global_position)
			if closest.distance_to(target.global_position) <= 45.0:
				target.take_damage(damage * 0.85)
		elif windup_pattern == "cross":
			var axis: Vector2 = windup_direction * 165.0
			var across: Vector2 = windup_direction.orthogonal() * 165.0
			var hit_axis: Vector2 = Geometry2D.get_closest_point_to_segment(target.global_position, windup_position - axis, windup_position + axis)
			var hit_across: Vector2 = Geometry2D.get_closest_point_to_segment(target.global_position, windup_position - across, windup_position + across)
			if minf(hit_axis.distance_to(target.global_position), hit_across.distance_to(target.global_position)) <= 37.0:
				target.take_damage(damage * 0.90)
		else:
			# The circle stays where the player stood when the warning began.
			if target.global_position.distance_to(windup_position) <= 94.0:
				target.take_damage(damage)
	elif kind == "sentinel":
		# main.gd fires the selected pattern along the locked warning direction.
		request_shot.emit(self, target)
	elif kind == "archon":
		if windup_pattern == "triad":
			for center: Vector2 in _archon_triad_centers():
				if target.global_position.distance_to(center) <= 54.0:
					target.take_damage(damage * 0.86)
					break
		elif windup_pattern == "halo":
			var distance: float = target.global_position.distance_to(windup_position)
			if distance >= 66.0 and distance <= 156.0:
				target.take_damage(damage * 0.90)
		else:
			var beam_end: Vector2 = global_position + windup_direction * 520.0
			var closest: Vector2 = Geometry2D.get_closest_point_to_segment(target.global_position, global_position, beam_end)
			if closest.distance_to(target.global_position) <= 40.0:
				target.take_damage(damage)
		beam_flash_left = 0.16
		queue_redraw()
	elif kind == "warden":
		if windup_pattern == "burst":
			request_shot.emit(self, target)
		elif windup_pattern == "cage":
			var cage_axis: Vector2 = windup_direction * 150.0
			var cage_side: Vector2 = windup_direction.orthogonal() * 150.0
			var cage_hit_a: Vector2 = Geometry2D.get_closest_point_to_segment(target.global_position, windup_position - cage_axis, windup_position + cage_axis)
			var cage_hit_b: Vector2 = Geometry2D.get_closest_point_to_segment(target.global_position, windup_position - cage_side, windup_position + cage_side)
			if minf(cage_hit_a.distance_to(target.global_position), cage_hit_b.distance_to(target.global_position)) <= 31.0:
				target.take_damage(damage * 0.94)
		else:
			var grid_side: Vector2 = windup_direction.orthogonal()
			for lane_offset: float in [-72.0, 0.0, 72.0]:
				var lane_start: Vector2 = global_position + grid_side * lane_offset
				var lane_end: Vector2 = lane_start + windup_direction * 520.0
				var grid_hit: Vector2 = Geometry2D.get_closest_point_to_segment(target.global_position, lane_start, lane_end)
				if grid_hit.distance_to(target.global_position) <= 28.0:
					target.take_damage(damage * 0.88)
					break
	elif kind == "reaper":
		if windup_pattern == "leap":
			var leap_target: Vector2 = windup_position
			global_position = world_nav.resolve_motion(global_position, leap_target, 24.0) if world_nav != null else leap_target
			if target.global_position.distance_to(global_position) <= 102.0:
				target.take_damage(damage * 0.96)
		elif windup_pattern == "shockring":
			var ring_distance: float = target.global_position.distance_to(global_position)
			if ring_distance >= 68.0 and ring_distance <= 176.0:
				target.take_damage(damage * 0.92)
		else:
			var cleave_to_target: Vector2 = target.global_position - global_position
			if cleave_to_target.length() <= 170.0 and cleave_to_target.normalized().dot(windup_direction) >= 0.50:
				target.take_damage(damage)
	elif kind == "resonator":
		if windup_pattern == "echo_pulse":
			var echo_distance: float = target.global_position.distance_to(windup_position)
			if echo_distance <= 118.0 or (echo_distance >= 188.0 and echo_distance <= 252.0):
				target.take_damage(damage * 0.92)
		elif windup_pattern == "echo_collapse":
			for collapse_center: Vector2 in [windup_position, windup_position + windup_direction.orthogonal() * 120.0, windup_position - windup_direction.orthogonal() * 120.0]:
				if target.global_position.distance_to(collapse_center) <= 62.0:
					target.take_damage(damage * 0.88)
					break
		else:
			for lane_offset: float in [-86.0, 0.0, 86.0]:
				var lane_origin: Vector2 = global_position + windup_direction.orthogonal() * lane_offset
				var lane_end: Vector2 = lane_origin + windup_direction * 560.0
				var echo_hit: Vector2 = Geometry2D.get_closest_point_to_segment(target.global_position, lane_origin, lane_end)
				if echo_hit.distance_to(target.global_position) <= 31.0:
					target.take_damage(damage * 0.90)
					break
	elif kind == "scrap_titan":
		if windup_pattern == "scrap_burst":
			request_shot.emit(self, target)
		elif windup_pattern == "crusher_ring":
			var crusher_distance: float = target.global_position.distance_to(global_position)
			if crusher_distance >= 76.0 and crusher_distance <= 188.0:
				target.take_damage(damage * 0.94)
		else:
			var titan_side: Vector2 = windup_direction.orthogonal()
			for titan_offset: float in [-92.0, 0.0, 92.0]:
				var titan_start: Vector2 = global_position + titan_side * titan_offset
				var titan_end: Vector2 = titan_start + windup_direction * 540.0
				var titan_hit: Vector2 = Geometry2D.get_closest_point_to_segment(target.global_position, titan_start, titan_end)
				if titan_hit.distance_to(target.global_position) <= 34.0:
					target.take_damage(damage * 0.91)
					break
	match kind:
		"marauder": attack_timer = 0.58 if health > max_health * 0.45 else 0.44
		"sentinel": attack_timer = 0.85 if health > max_health * 0.66 else (0.62 if health > max_health * 0.33 else 0.48)
		"archon": attack_timer = 0.88 if health > max_health * 0.40 else 0.68
		"warden": attack_timer = 0.82 if not phase_two else 0.60
		"reaper": attack_timer = 0.68 if not phase_two else 0.50
		"resonator": attack_timer = 0.86 if not phase_two else 0.64
		"scrap_titan": attack_timer = 0.88 if not phase_two else 0.66
	exposed_timer = 0.72 if not phase_two else 0.58
	if kind != "archon":
		windup_direction = Vector2.ZERO

func _has_clear_shot() -> bool:
	if world_nav == null or not is_instance_valid(target):
		return true
	if _los_check_timer <= 0.0:
		_los_cache_result = world_nav.has_walkable_line(global_position, target.global_position, 4.0)
		# Décalage déterministe entre ennemis : évite de recalculer toutes les lignes le même frame.
		_los_check_timer = 0.11 + float(int(get_instance_id()) % 5) * 0.012
	return _los_cache_result

func _line_reposition_direction(to_target: Vector2) -> Vector2:
	if to_target.length_squared() <= 0.001:
		return Vector2.ZERO
	var forward: Vector2 = to_target.normalized()
	var side: Vector2 = forward.orthogonal() * strafe_sign
	return (side + forward * 0.26).normalized()

func _crowd_radius() -> float:
	if is_boss():
		return 112.0
	if is_miniboss():
		return 92.0
	if kind in ["heavy", "breaker", "scrap_automaton", "mobile_turret"]:
		return 78.0
	if kind in ["stalker", "echo_scout", "salvage_drone"]:
		return 66.0
	return 62.0

func _neighbor_separation() -> Vector2:
	var root: Node = get_parent()
	if root == null:
		return Vector2.ZERO
	var own_radius: float = _crowd_radius()
	var force: Vector2 = Vector2.ZERO
	for node: Node in root.get_children():
		var other: NomadEnemy = node as NomadEnemy
		if other == null or other == self or not other.active or other.is_queued_for_deletion():
			continue
		var delta_to_self: Vector2 = global_position - other.global_position
		var combined_radius: float = (own_radius + other._crowd_radius()) * 0.5
		var distance_sq: float = delta_to_self.length_squared()
		if distance_sq >= combined_radius * combined_radius:
			continue
		if distance_sq <= 0.001:
			var side: float = -1.0 if get_instance_id() < other.get_instance_id() else 1.0
			var angle: float = float(int(get_instance_id()) % 7) * 0.73
			force += Vector2(side, 0.0).rotated(angle)
			continue
		var distance: float = sqrt(distance_sq)
		var pressure: float = 1.0 - distance / combined_radius
		force += delta_to_self / distance * pressure * pressure
	return force.limit_length(1.0)

func _apply_passive_crowd_separation(delta: float) -> bool:
	var separation: Vector2 = _neighbor_separation()
	if separation.length_squared() <= 0.0025:
		return false
	var crowd_speed: float = speed * (0.34 if is_miniboss() else 0.42)
	var desired: Vector2 = global_position + separation * crowd_speed * delta
	var radius: float = 29.0 if kind in ["colossus", "veil_guardian", "leviathan_grinder"] else (24.0 if kind in ["heavy", "breaker", "scrap_automaton", "mobile_turret"] else 20.0)
	var resolved: Vector2 = world_nav.resolve_motion(global_position, desired, radius) if world_nav != null else desired
	var moved: bool = global_position.distance_squared_to(resolved) > 0.09
	global_position = resolved
	return moved

func _move_dir(direction: Vector2, delta: float) -> void:
	var move_dir: Vector2 = direction.normalized()
	if move_dir.length_squared() <= 0.001:
		return
	var separation: Vector2 = _neighbor_separation()
	if separation.length_squared() > 0.0025:
		var separation_weight: float = 0.26 if is_boss() else (0.34 if is_miniboss() else 0.46)
		move_dir = (move_dir + separation * separation_weight).normalized()
	var radius: float = 29.0 if kind in ["colossus", "veil_guardian", "leviathan_grinder"] else (24.0 if kind in ["heavy", "breaker", "scrap_automaton", "mobile_turret"] or is_boss() else 20.0)
	if world_nav == null:
		global_position += move_dir * speed * delta
		return

	# Tant qu'un détour est utile, on le suit brièvement au lieu de viser à nouveau
	# le joueur en ligne droite à chaque frame. C'est ce qui évite de rester collé
	# contre le même bord de bâtiment.
	_detour_time = maxf(0.0, _detour_time - delta)
	if _detour_time > 0.0 and _detour_direction.length_squared() > 0.01:
		move_dir = _detour_direction

	# V44.47 : anticipation des structures. On ne doit plus attendre d'être déjà
	# bloqué pour contourner un bâtiment. Les gros ennemis regardent plus loin.
	if _detour_time <= 0.0:
		var probe_distance: float = 132.0 if is_boss() else (112.0 if kind in ["heavy", "breaker", "colossus", "veil_guardian", "scrap_automaton", "mobile_turret", "leviathan_grinder"] else 92.0)
		if not world_nav.has_walkable_line(global_position, global_position + move_dir * probe_distance, radius):
			var proactive_detour: Vector2 = world_nav.detour_direction(global_position, direction.normalized(), radius, probe_distance, _detour_sign)
			if proactive_detour.length_squared() > 0.01:
				_detour_direction = proactive_detour
				_detour_time = 0.50 if is_boss() else 0.64
				_detour_sign *= -1.0
				move_dir = proactive_detour

	var before: Vector2 = global_position
	var desired: Vector2 = before + move_dir * speed * delta
	var resolved: Vector2 = world_nav.resolve_motion(before, desired, radius)
	var expected: float = maxf(0.001, speed * delta)
	var moved: float = before.distance_to(resolved)
	global_position = resolved

	if moved < expected * 0.22:
		_stuck_time += delta
	else:
		_stuck_time = maxf(0.0, _stuck_time - delta * 2.5)
		if _detour_time > 0.0 and moved >= expected * 0.70:
			# On garde le détour juste assez longtemps pour franchir le coin.
			_detour_time = maxf(_detour_time, 0.10)

	if _stuck_time >= 0.12:
		var target_dir: Vector2 = direction.normalized()
		var candidate: Vector2 = world_nav.detour_direction(global_position, target_dir, radius, 96.0, _detour_sign)
		if candidate.length_squared() > 0.01:
			_detour_direction = candidate
			_detour_time = 0.42 if is_boss() else 0.58
			_detour_sign *= -1.0
			var detour_target: Vector2 = global_position + _detour_direction * speed * delta
			global_position = world_nav.resolve_motion(global_position, detour_target, radius)
		_stuck_time = 0.0

	# Filet de sécurité : si un ancien checkpoint ou un dash a placé l'ennemi
	# dans une collision, on le replace au point praticable le plus proche.
	if not world_nav.is_walkable(global_position, radius):
		var recovery_clearance: float = 150.0 if is_boss() else (104.0 if kind in ["heavy", "breaker", "colossus", "veil_guardian", "scrap_automaton", "mobile_turret", "leviathan_grinder"] else 72.0)
		global_position = world_nav.nearest_open_area(global_position, radius, recovery_clearance, 0.64, 260.0)

func _set_idle() -> void:
	if _sprite == null:
		return
	match kind:
		"raider", "stalker": _sprite.texture = RAIDER_IDLE
		"echo_scout": _sprite.texture = ECHO_SCOUT_IDLE
		"veil_tech": _sprite.texture = VEIL_TECH_IDLE
		"veil_guardian": _sprite.texture = VEIL_GUARDIAN_IDLE
		"salvage_drone": _sprite.texture = SALVAGE_DRONE_IDLE
		"scrap_automaton": _sprite.texture = SCRAP_AUTOMATON_IDLE
		"mobile_turret": _sprite.texture = MOBILE_TURRET_IDLE
		"leviathan_grinder": _sprite.texture = LEVIATHAN_GRINDER_IDLE
		"heavy", "breaker", "colossus": _sprite.texture = HEAVY_IDLE
		"sniper", "suppressor", "phantom": _sprite.texture = BLASTER_IDLE
		"sentinel", "warden": _sprite.texture = SENTINEL_BOSS
		"marauder", "reaper": _sprite.texture = MARAUDER_BOSS
		"archon": _sprite.texture = ARCHON_BOSS
		"resonator": _sprite.texture = RESONATOR_BOSS
		"scrap_titan": _sprite.texture = SCRAP_TITAN_BOSS
		_: _sprite.texture = BLASTER_IDLE
	_sprite.rotation = 0.0
	_sprite.position = Vector2.ZERO
	_sprite.scale = _base_sprite_scale

func _animate_idle(delta: float, dx: float) -> void:
	_set_idle()
	_sprite.flip_h = dx < 0.0
	_idle_cycle = fmod(_idle_cycle + delta * (0.95 if is_boss() else 1.4), TAU)
	if is_boss():
		_sprite.position.y = sin(_idle_cycle * 2.0) * 1.0
		_sprite.rotation = sin(_idle_cycle) * 0.010
		var boss_pulse: float = cos(_idle_cycle * 2.0) * 0.003
		_sprite.scale = Vector2(_base_sprite_scale.x + boss_pulse, _base_sprite_scale.y - boss_pulse)
		return
	var breath: float = sin(_idle_cycle * 2.0)
	_sprite.position.y = breath * 0.45
	_sprite.rotation = sin(_idle_cycle) * 0.005
	var subtle_scale: float = cos(_idle_cycle * 2.0) * 0.002
	_sprite.scale = Vector2(_base_sprite_scale.x + subtle_scale, _base_sprite_scale.y - subtle_scale)

func _animate_run(delta: float, dx: float) -> void:
	_sprite.flip_h = dx < 0.0
	_anim_time += delta
	var frame_interval: float = 0.16
	var cycle_speed: float = clampf(speed / 15.0, 4.4, 9.4)
	var bob_amp: float = 1.1
	var lean_amp: float = 0.010
	var squash_amp: float = 0.003
	match kind:
		"stalker":
			frame_interval = clampf(15.0 / maxf(speed, 1.0), 0.088, 0.142)
			cycle_speed = clampf(speed / 13.2, 5.3, 10.2)
			bob_amp = 1.55
			lean_amp = 0.018
			squash_amp = 0.005
		"raider":
			frame_interval = clampf(17.0 / maxf(speed, 1.0), 0.102, 0.165)
			cycle_speed = clampf(speed / 14.0, 4.9, 9.6)
			bob_amp = 1.25
			lean_amp = 0.013
			squash_amp = 0.004
		"sniper":
			frame_interval = clampf(20.0 / maxf(speed, 1.0), 0.16, 0.23)
			cycle_speed = clampf(speed / 18.0, 3.6, 5.2)
			bob_amp = 0.55
			lean_amp = 0.006
			squash_amp = 0.0016
		"suppressor":
			frame_interval = clampf(18.5 / maxf(speed, 1.0), 0.135, 0.205)
			cycle_speed = clampf(speed / 16.0, 4.0, 6.2)
			bob_amp = 0.82
			lean_amp = 0.007
			squash_amp = 0.002
		"salvage_drone":
			frame_interval = clampf(14.0 / maxf(speed, 1.0), 0.082, 0.132)
			cycle_speed = clampf(speed / 12.8, 6.0, 11.0)
			bob_amp = 2.2
			lean_amp = 0.020
			squash_amp = 0.004
		"mobile_turret":
			frame_interval = clampf(22.0 / maxf(speed, 1.0), 0.19, 0.28)
			cycle_speed = clampf(speed / 21.0, 2.8, 4.0)
			bob_amp = 0.35
			lean_amp = 0.004
			squash_amp = 0.001
		"scrap_automaton":
			frame_interval = clampf(21.5 / maxf(speed, 1.0), 0.17, 0.245)
			cycle_speed = clampf(speed / 18.5, 3.4, 5.0)
			bob_amp = 1.65
			lean_amp = 0.012
			squash_amp = 0.003
		"heavy":
			frame_interval = clampf(21.0 / maxf(speed, 1.0), 0.175, 0.245)
			cycle_speed = clampf(speed / 18.8, 3.2, 4.8)
			bob_amp = 1.55
			lean_amp = 0.012
			squash_amp = 0.0028
		"breaker", "colossus":
			frame_interval = clampf(22.5 / maxf(speed, 1.0), 0.182, 0.26)
			cycle_speed = clampf(speed / 19.6, 3.1, 4.6)
			bob_amp = 1.95
			lean_amp = 0.015
			squash_amp = 0.0034
		"leviathan_grinder":
			frame_interval = clampf(23.0 / maxf(speed, 1.0), 0.19, 0.27)
			cycle_speed = clampf(speed / 20.2, 3.0, 4.5)
			bob_amp = 2.05
			lean_amp = 0.016
			squash_amp = 0.0036
		"phantom":
			frame_interval = clampf(18.0 / maxf(speed, 1.0), 0.122, 0.18)
			cycle_speed = clampf(speed / 15.2, 4.4, 6.9)
			bob_amp = 1.0
			lean_amp = 0.010
			squash_amp = 0.0025
	_run_cycle = fmod(_run_cycle + delta * cycle_speed, TAU)
	if is_boss():
		var boss_shift: float = sin(_run_cycle * 2.0)
		_sprite.position.y = boss_shift * 1.3
		_sprite.rotation = sin(_run_cycle) * 0.017 + clampf(dx / 180.0, -1.0, 1.0) * 0.010
		var boss_scale: float = cos(_run_cycle * 2.0) * 0.0035
		_sprite.scale = Vector2(_base_sprite_scale.x + boss_scale, _base_sprite_scale.y - boss_scale * 0.8)
		return
	if _anim_time >= frame_interval:
		_anim_time = fmod(_anim_time, frame_interval)
		_run_frame = not _run_frame
		match kind:
			"raider", "stalker": _sprite.texture = RAIDER_A if _run_frame else RAIDER_B
			"echo_scout": _sprite.texture = ECHO_SCOUT_A if _run_frame else ECHO_SCOUT_B
			"veil_tech": _sprite.texture = VEIL_TECH_A if _run_frame else VEIL_TECH_B
			"veil_guardian": _sprite.texture = VEIL_GUARDIAN_A if _run_frame else VEIL_GUARDIAN_B
			"salvage_drone": _sprite.texture = SALVAGE_DRONE_A if _run_frame else SALVAGE_DRONE_B
			"scrap_automaton": _sprite.texture = SCRAP_AUTOMATON_A if _run_frame else SCRAP_AUTOMATON_B
			"mobile_turret": _sprite.texture = MOBILE_TURRET_A if _run_frame else MOBILE_TURRET_B
			"leviathan_grinder": _sprite.texture = LEVIATHAN_GRINDER_A if _run_frame else LEVIATHAN_GRINDER_B
			"heavy", "breaker", "colossus": _sprite.texture = HEAVY_A if _run_frame else HEAVY_B
			_: _sprite.texture = BLASTER_A if _run_frame else BLASTER_B
	var stride: float = sin(_run_cycle * 2.0)
	_sprite.position.y = stride * bob_amp
	_sprite.rotation = sin(_run_cycle) * lean_amp + clampf(dx / 220.0, -1.0, 1.0) * (lean_amp * 0.65)
	var squash: float = cos(_run_cycle * 2.0) * squash_amp
	_sprite.scale = Vector2(_base_sprite_scale.x + squash, _base_sprite_scale.y - squash * 0.8)

func play_fire_recoil(fire_direction: Vector2) -> void:
	if not active or _sprite == null:
		return
	var dir: Vector2 = fire_direction.normalized() if fire_direction.length_squared() > 0.01 else Vector2.RIGHT
	_sprite.position = -dir * 5.0
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(_sprite, "position", Vector2.ZERO, 0.11)

func apply_knockback(source_position: Vector2, force: float) -> void:
	if not active:
		return
	var direction: Vector2 = global_position - source_position
	if direction.length_squared() <= 0.01:
		direction = Vector2.RIGHT
	direction = direction.normalized()
	var resistance: float = 1.0
	if kind == "heavy":
		resistance = 0.56
	elif kind == "breaker":
		resistance = 0.44
	elif kind == "colossus":
		resistance = 0.24
	elif kind == "phantom":
		resistance = 0.88
	elif kind == "stalker":
		resistance = 1.18
	elif kind == "echo_scout":
		resistance = 1.22
	elif kind == "veil_guardian":
		resistance = 0.22
	elif kind == "salvage_drone":
		resistance = 1.20
	elif kind == "scrap_automaton":
		resistance = 0.48
	elif kind == "mobile_turret":
		resistance = 0.38
	elif kind == "leviathan_grinder":
		resistance = 0.22
	elif is_boss():
		resistance = 0.30
	if affix == "bulwark":
		resistance *= 0.52
	elif affix == "swift":
		resistance *= 1.18
	_knockback_velocity += direction * force * resistance
	_stagger_timer = maxf(_stagger_timer, 0.075 * resistance + 0.035)

func take_damage(amount: float, was_critical: bool = false) -> void:
	if not active:
		return
	amount *= damage_taken_multiplier * (1.20 if is_boss() and exposed_timer > 0.0 else 1.0)
	health = maxf(0.0, health - amount)
	if is_boss() and health > 0.0 and health <= max_health * 0.5 and not phase_two:
		phase_two = true
		boss_attack_index = 0
		windup_left = 0.0
		windup_direction = Vector2.ZERO
		exposed_timer = 0.0
		attack_timer = maxf(attack_timer, 1.05)
		phase_changed.emit(self, 2)
	var was_heavy: bool = kind in ["heavy", "breaker", "colossus", "veil_guardian", "scrap_automaton", "mobile_turret", "leviathan_grinder"] or is_boss()
	damaged.emit(global_position, amount, was_heavy, was_critical)
	var target_modulate: Color = Color.WHITE
	if affix == "swift":
		target_modulate = Color(0.72, 0.84, 0.86)
	elif affix == "bulwark":
		target_modulate = Color(0.73, 0.75, 0.80)
	elif affix == "overcharged":
		target_modulate = Color(0.92, 0.62, 0.43)
	elif affix == "void":
		target_modulate = Color(0.72, 0.58, 0.82)
	elif elite:
		target_modulate = Color(0.88, 0.72, 0.45)
	elif kind == "stalker":
		target_modulate = Color(0.63, 0.84, 0.69)
	elif kind == "sniper":
		target_modulate = Color(0.62, 0.78, 0.86)
	elif kind == "suppressor":
		target_modulate = Color(0.88, 0.64, 0.38)
	elif kind == "breaker":
		target_modulate = Color(0.86, 0.53, 0.38)
	elif kind == "salvage_drone":
		target_modulate = Color(0.68, 0.82, 0.82)
	elif kind == "scrap_automaton":
		target_modulate = Color(0.80, 0.62, 0.44)
	elif kind == "mobile_turret":
		target_modulate = Color(0.78, 0.70, 0.56)
	elif kind == "leviathan_grinder":
		target_modulate = Color(0.76, 0.55, 0.38)
	elif kind == "phantom":
		target_modulate = Color(0.58, 0.84, 1.0)
	elif kind == "colossus":
		target_modulate = Color(1.0, 0.66, 0.30)
	elif kind == "warden":
		target_modulate = Color(0.40, 0.96, 1.0)
	elif kind == "reaper":
		target_modulate = Color(1.0, 0.38, 0.62)
	elif kind == "resonator":
		target_modulate = Color(0.92, 0.78, 1.0)
	elif kind == "scrap_titan":
		target_modulate = Color(0.88, 0.71, 0.49)
	_sprite.modulate = Color(1.0, 0.94, 0.82) if was_critical else Color(1.0, 0.76, 0.66)
	_sprite.scale = _base_sprite_scale * (1.055 if was_critical else 1.028)
	queue_redraw()
	if health > 0.0:
		var hit_tween: Tween = create_tween()
		hit_tween.set_parallel(true)
		hit_tween.tween_property(_sprite, "modulate", target_modulate, 0.075 if was_critical else 0.09)
		hit_tween.tween_property(_sprite, "scale", _base_sprite_scale, 0.085 if was_critical else 0.10)
	if health <= 0.0:
		active = false
		_knockback_velocity = Vector2.ZERO
		_stagger_timer = 0.0
		died.emit(self, xp_value)
		var death_tween: Tween = create_tween()
		death_tween.set_parallel(true)
		death_tween.set_trans(Tween.TRANS_QUAD)
		death_tween.set_ease(Tween.EASE_OUT)
		death_tween.tween_property(_sprite, "scale", _base_sprite_scale * (0.86 if was_heavy else 0.80), 0.28)
		death_tween.tween_property(_sprite, "modulate:a", 0.0, 0.28)
		death_tween.tween_property(_sprite, "rotation", deg_to_rad(10.0 if int(get_instance_id()) % 2 == 0 else -10.0), 0.28)
		death_tween.tween_property(_sprite, "position:y", _sprite.position.y + 10.0, 0.28)
		death_tween.tween_property(_shadow_sprite, "modulate:a", 0.0, 0.24)
		death_tween.tween_property(_shadow_sprite, "scale", _shadow_sprite.scale * 0.82, 0.28)
		death_tween.finished.connect(queue_free)

func _draw() -> void:
	if not active:
		return
	if windup_left > 0.0:
		_draw_boss_warning()
	if role_windup_left > 0.0:
		_draw_role_warning()
	if affix_windup_left > 0.0:
		_draw_affix_warning()
	if beam_flash_left > 0.0 and kind == "archon":
		if windup_pattern == "triad":
			for center: Vector2 in _archon_triad_centers():
				draw_circle(to_local(center), 54.0, Color(0.49, 1.0, 0.23, 0.28))
		elif windup_pattern == "halo":
			draw_arc(to_local(windup_position), 111.0, 0.0, TAU, 64, Color(0.49, 1.0, 0.23, 0.42), 90.0, true)
		else:
			var end_point: Vector2 = windup_direction * 520.0
			draw_line(Vector2.ZERO, end_point, Color(0.34, 1.0, 0.25, 0.28), 86.0, true)
			draw_line(Vector2.ZERO, end_point, Color(0.74, 1.0, 0.62, 0.82), 14.0, true)
	if elite or is_boss() or is_miniboss() or not affix.is_empty() or kind in ["stalker", "sniper", "suppressor", "breaker", "salvage_drone", "scrap_automaton", "mobile_turret"]:
		var aura_color: Color = Color(1.0, 0.28, 0.16, 0.28) if kind == "marauder" else (Color(0.72, 0.42, 1.0, 0.26) if kind == "sentinel" else (Color(0.51, 1.0, 0.25, 0.29) if kind == "archon" else Color(1.0, 0.72, 0.24, 0.22)))
		if kind == "warden": aura_color = Color(0.28, 0.90, 1.0, 0.30)
		elif kind == "reaper": aura_color = Color(1.0, 0.32, 0.58, 0.30)
		elif kind == "phantom": aura_color = Color(0.40, 0.78, 1.0, 0.32)
		elif kind == "colossus": aura_color = Color(1.0, 0.52, 0.18, 0.32)
		elif kind == "stalker": aura_color = Color(0.32, 1.0, 0.60, 0.25)
		elif kind == "sniper": aura_color = Color(0.36, 0.84, 1.0, 0.25)
		elif kind == "suppressor": aura_color = Color(1.0, 0.58, 0.22, 0.25)
		elif kind == "breaker": aura_color = Color(1.0, 0.32, 0.16, 0.28)
		elif kind == "salvage_drone": aura_color = Color(0.42, 0.78, 0.82, 0.23)
		elif kind == "scrap_automaton": aura_color = Color(0.80, 0.49, 0.25, 0.25)
		elif kind == "mobile_turret": aura_color = Color(0.82, 0.66, 0.36, 0.24)
		elif kind == "leviathan_grinder": aura_color = Color(0.86, 0.42, 0.18, 0.30)
		elif kind == "scrap_titan": aura_color = Color(0.88, 0.58, 0.30, 0.30)
		if affix == "swift": aura_color = Color(0.34, 0.90, 1.0, 0.24)
		elif affix == "bulwark": aura_color = Color(0.46, 0.58, 0.92, 0.24)
		elif affix == "overcharged": aura_color = Color(1.0, 0.32, 0.18, 0.26)
		elif affix == "void": aura_color = Color(0.67, 0.32, 1.0, 0.28)
		draw_arc(Vector2.ZERO, 63.0 if is_boss() else 46.0, 0.0, TAU, 32, aura_color, 3.0)
		if affix == "bulwark":
			draw_arc(Vector2.ZERO, 51.0, -2.75, -0.39, 18, Color(0.64, 0.78, 1.0, 0.72), 5.0, true)
			draw_arc(Vector2.ZERO, 51.0, 0.39, 2.75, 18, Color(0.64, 0.78, 1.0, 0.44), 3.0, true)
		elif affix == "overcharged":
			var pulse_radius: float = 48.0 + sin(Time.get_ticks_msec() * 0.015) * 4.0
			draw_arc(Vector2.ZERO, pulse_radius, 0.0, TAU, 18, Color(0.90, 0.52, 0.30, 0.46), 2.5, true)
			for spark_angle: float in [0.2, 1.7, 3.1, 4.8]:
				var p1: Vector2 = Vector2.from_angle(spark_angle) * 43.0
				var p2: Vector2 = Vector2.from_angle(spark_angle + 0.16) * 56.0
				draw_line(p1, p2, Color(0.95, 0.70, 0.44, 0.52), 2.0, true)
		elif affix == "void":
			var void_spin: float = Time.get_ticks_msec() * 0.0025
			for void_offset: float in [0.0, PI]:
				draw_arc(Vector2.ZERO, 52.0, void_spin + void_offset, void_spin + void_offset + 1.05, 12, Color(0.68, 0.52, 0.82, 0.54), 4.0, true)
		elif affix == "swift":
			var swift_side: float = 1.0 if strafe_sign > 0.0 else -1.0
			for swift_i: int in range(2):
				var swift_y: float = -9.0 + float(swift_i) * 18.0
				draw_line(Vector2(-50.0 * swift_side, swift_y), Vector2(-61.0 * swift_side, swift_y - 7.0), Color(0.64, 0.82, 0.86, 0.50), 2.5, true)
				draw_line(Vector2(-50.0 * swift_side, swift_y), Vector2(-61.0 * swift_side, swift_y + 7.0), Color(0.64, 0.82, 0.86, 0.50), 2.5, true)
	if is_boss() and exposed_timer > 0.0:
		draw_arc(Vector2.ZERO, 67.0, -PI * 0.5, -PI * 0.5 + TAU * exposed_timer / (0.58 if phase_two else 0.72), 42, Color(0.83, 1.0, 0.75, 0.86), 5.0, true)
	if health < max_health:
		var width: float = 54.0
		if kind == "heavy": width = 70.0
		if kind == "breaker": width = 76.0
		if kind == "phantom": width = 82.0
		if kind == "colossus": width = 92.0
		if kind == "scrap_automaton": width = 74.0
		if kind == "mobile_turret": width = 70.0
		if kind == "leviathan_grinder": width = 94.0
		if is_boss(): width = 94.0
		var ratio: float = clampf(health / max_health, 0.0, 1.0)
		var health_y: float = -113.0 if is_boss() else -78.0
		draw_rect(Rect2(Vector2(-width * 0.5, health_y), Vector2(width, 7.0)), Color(0.06, 0.07, 0.08, 0.88), true)
		draw_rect(Rect2(Vector2(-width * 0.5 + 1.0, health_y + 1.0), Vector2((width - 2.0) * ratio, 5.0)), Color(0.92, 0.25, 0.22, 1.0), true)

func _draw_role_warning() -> void:
	var progress: float = 1.0 - role_windup_left / maxf(0.01, role_windup_duration)
	match role_windup_pattern:
		"raider_hook":
			var hook_side: Vector2 = role_locked_direction.orthogonal() * strafe_sign * 34.0
			var hook_finish: Vector2 = role_locked_direction * 112.0 + hook_side
			draw_line(Vector2.ZERO, hook_finish, Color(1.0, 0.58, 0.28, 0.13 + progress * 0.13), 24.0, true)
			draw_line(Vector2.ZERO, hook_finish * progress, Color(1.0, 0.82, 0.54, 0.92), 3.0, true)
			draw_arc(Vector2.ZERO, 40.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 28, Color(1.0, 0.68, 0.36), 4.0, true)
		"heavy_slam":
			draw_circle(Vector2.ZERO, 104.0, Color(1.0, 0.38, 0.16, 0.08 + progress * 0.12))
			draw_arc(Vector2.ZERO, 104.0, 0.0, TAU, 46, Color(1.0, 0.58, 0.28, 0.82), 3.5, true)
			draw_arc(Vector2.ZERO, 94.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 40, Color.WHITE, 4.0, true)
		"blaster_double":
			var blaster_end: Vector2 = role_locked_direction * 360.0
			var spread_side: Vector2 = role_locked_direction.orthogonal() * 12.0
			for offset: Vector2 in [-spread_side, spread_side]:
				draw_line(offset, blaster_end + offset, Color(0.98, 0.72, 0.34, 0.10 + progress * 0.12), 10.0, true)
				draw_line(offset, (blaster_end + offset) * progress, Color(1.0, 0.88, 0.58, 0.90), 2.2, true)
			draw_arc(Vector2.ZERO, 42.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 28, Color(1.0, 0.76, 0.38), 3.5, true)
		"sniper_lock":
			var end_point: Vector2 = role_locked_direction * 560.0
			draw_line(Vector2.ZERO, end_point, Color(0.18, 0.78, 1.0, 0.13 + progress * 0.15), 18.0, true)
			draw_line(Vector2.ZERO, end_point, Color(0.43, 0.91, 1.0, 0.78), 2.2, true)
			draw_line(Vector2.ZERO, end_point * progress, Color.WHITE, 3.2, true)
			draw_arc(Vector2.ZERO, 48.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 32, Color(0.55, 0.94, 1.0), 4.0, true)
		"suppressor_burst":
			var left: Vector2 = role_locked_direction.rotated(-0.15) * 390.0
			var right: Vector2 = role_locked_direction.rotated(0.15) * 390.0
			draw_colored_polygon(PackedVector2Array([Vector2.ZERO, left, right]), Color(1.0, 0.42, 0.12, 0.08 + progress * 0.11))
			draw_line(Vector2.ZERO, left, Color(1.0, 0.55, 0.20, 0.70), 2.4, true)
			draw_line(Vector2.ZERO, right, Color(1.0, 0.55, 0.20, 0.70), 2.4, true)
			draw_arc(Vector2.ZERO, 45.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 30, Color(1.0, 0.77, 0.42), 4.0, true)
		"breaker_charge":
			var finish: Vector2 = role_locked_direction * 190.0
			var side: Vector2 = role_locked_direction.orthogonal() * 38.0
			draw_colored_polygon(PackedVector2Array([-side, finish - side, finish + side, side]), Color(1.0, 0.22, 0.10, 0.10 + progress * 0.14))
			draw_line(-side, finish - side, Color(1.0, 0.35, 0.18, 0.82), 3.0, true)
			draw_line(side, finish + side, Color(1.0, 0.35, 0.18, 0.82), 3.0, true)
			draw_line(Vector2.ZERO, finish * progress, Color.WHITE, 3.2, true)
			draw_arc(Vector2.ZERO, 52.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 34, Color(1.0, 0.52, 0.30), 5.0, true)
		"stalker_lunge":
			var finish: Vector2 = role_locked_direction * 126.0
			draw_line(Vector2.ZERO, finish, Color(0.28, 1.0, 0.58, 0.16 + progress * 0.12), 28.0, true)
			draw_line(Vector2.ZERO, finish * progress, Color(0.66, 1.0, 0.78, 0.92), 3.0, true)
			draw_arc(Vector2.ZERO, 43.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 28, Color(0.45, 1.0, 0.67), 4.0, true)
		"echo_dash":
			var echo_finish: Vector2 = role_locked_direction * 198.0
			draw_line(Vector2.ZERO, echo_finish, Color(0.86, 0.52, 0.34, 0.13 + progress * 0.12), 28.0, true)
			draw_line(Vector2.ZERO, echo_finish * progress, Color(0.96, 0.78, 0.60, 0.90), 3.0, true)
		"veil_mine":
			var mine_center: Vector2 = to_local(role_locked_position)
			draw_circle(mine_center, 82.0, Color(0.88, 0.50, 0.24, 0.08 + progress * 0.10))
			draw_arc(mine_center, 82.0, 0.0, TAU, 38, Color(0.94, 0.67, 0.38, 0.82), 3.0, true)
		"guardian_shards":
			var shard_side: Vector2 = role_locked_direction.orthogonal() * 96.0
			for shard_center: Vector2 in [role_locked_position, role_locked_position + shard_side, role_locked_position - shard_side]:
				var local_shard: Vector2 = to_local(shard_center)
				draw_circle(local_shard, 58.0, Color(0.54, 0.46, 0.72, 0.08 + progress * 0.11))
				draw_arc(local_shard, 58.0, 0.0, TAU, 34, Color(0.74, 0.68, 0.88, 0.86), 3.0, true)
		"drone_burst":
			var drone_end: Vector2 = role_locked_direction * 370.0
			draw_line(Vector2.ZERO, drone_end, Color(0.40, 0.82, 0.84, 0.12 + progress * 0.12), 14.0, true)
			draw_line(Vector2.ZERO, drone_end * progress, Color(0.78, 0.96, 0.94, 0.92), 2.6, true)
		"automaton_ram":
			var ram_finish: Vector2 = role_locked_direction * 220.0
			var ram_side: Vector2 = role_locked_direction.orthogonal() * 34.0
			draw_colored_polygon(PackedVector2Array([-ram_side, ram_finish - ram_side, ram_finish + ram_side, ram_side]), Color(0.82, 0.40, 0.18, 0.09 + progress * 0.13))
			draw_line(Vector2.ZERO, ram_finish * progress, Color(0.96, 0.78, 0.52, 0.94), 3.0, true)
		"turret_lock":
			var turret_end: Vector2 = role_locked_direction * 470.0
			draw_line(Vector2.ZERO, turret_end, Color(0.84, 0.64, 0.34, 0.12 + progress * 0.13), 24.0, true)
			draw_line(Vector2.ZERO, turret_end * progress, Color(1.0, 0.86, 0.58, 0.94), 2.8, true)
		"grinder_spin":
			draw_circle(Vector2.ZERO, 108.0, Color(0.78, 0.35, 0.16, 0.08 + progress * 0.12))
			draw_arc(Vector2.ZERO, 108.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 48, Color(0.96, 0.63, 0.30, 0.90), 4.0, true)
		"phantom_volley":
			var phantom_end: Vector2 = role_locked_direction * 520.0
			for spread: float in [-0.10, 0.0, 0.10]:
				var ray: Vector2 = phantom_end.rotated(spread)
				draw_line(Vector2.ZERO, ray, Color(0.48, 0.78, 1.0, 0.16 + progress * 0.15), 12.0, true)
				draw_line(Vector2.ZERO, ray * progress, Color(0.72, 0.94, 1.0, 0.92), 2.4, true)
			draw_arc(Vector2.ZERO, 50.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 32, Color(0.62, 0.88, 1.0), 4.0, true)
		"colossus_quake":
			var quake_center: Vector2 = to_local(role_locked_position)
			draw_circle(quake_center, 112.0, Color(1.0, 0.48, 0.16, 0.10 + progress * 0.12))
			draw_arc(quake_center, 112.0, 0.0, TAU, 48, Color(1.0, 0.66, 0.30, 0.88), 4.0, true)
			draw_arc(quake_center, 102.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 42, Color.WHITE, 4.0, true)

func _draw_affix_warning() -> void:
	var progress: float = 1.0 - affix_windup_left / maxf(0.01, affix_windup_duration)
	if affix_windup_pattern == "void_blink":
		var radius: float = 38.0 + progress * 18.0
		draw_circle(Vector2.ZERO, radius, Color(0.65, 0.28, 1.0, 0.07 + progress * 0.10))
		for void_offset: float in [0.0, PI]:
			draw_arc(Vector2.ZERO, radius, progress * 3.2 + void_offset, progress * 3.2 + void_offset + 1.15, 14, Color(0.78, 0.50, 1.0, 0.86), 4.0, true)
	elif affix_windup_pattern == "swift_dodge":
		var side: Vector2 = affix_locked_direction.orthogonal() * strafe_sign
		for distance: float in [48.0, 62.0, 76.0]:
			var tip: Vector2 = side * distance
			var back: Vector2 = tip - side * 12.0
			var wing: Vector2 = side.orthogonal() * 7.0
			draw_line(back + wing, tip, Color(0.48, 0.94, 1.0, 0.40 + progress * 0.42), 2.5, true)
			draw_line(back - wing, tip, Color(0.48, 0.94, 1.0, 0.40 + progress * 0.42), 2.5, true)

func _draw_boss_warning() -> void:
	var progress: float = 1.0 - windup_left / maxf(0.01, windup_duration)
	var warning_color: Color = Color(1.0, 0.42, 0.20) if kind == "marauder" else (Color(0.60, 1.0, 0.30) if kind == "archon" else (Color(0.28, 0.90, 1.0) if kind == "warden" else (Color(1.0, 0.32, 0.58) if kind == "reaper" else (Color(0.52, 0.76, 0.82) if kind == "resonator" else (Color(0.88, 0.58, 0.30) if kind == "scrap_titan" else Color(0.79, 0.51, 1.0))))))
	if kind == "marauder":
		if windup_pattern == "charge":
			var across: Vector2 = windup_direction.orthogonal() * 45.0
			var finish: Vector2 = windup_direction * 230.0
			draw_colored_polygon(PackedVector2Array([across, finish + across, finish - across, -across]), Color(warning_color.r, warning_color.g, warning_color.b, 0.14 + progress * 0.14))
			draw_line(across, finish + across, warning_color, 3.0, true)
			draw_line(-across, finish - across, warning_color, 3.0, true)
			draw_line(Vector2.ZERO, finish * progress, Color.WHITE, 3.0, true)
		elif windup_pattern == "cross":
			var center: Vector2 = to_local(windup_position)
			for axis: Vector2 in [windup_direction, windup_direction.orthogonal()]:
				var extent: Vector2 = axis * 165.0
				draw_line(center - extent, center + extent, Color(warning_color.r, warning_color.g, warning_color.b, 0.16 + progress * 0.16), 78.0, true)
				draw_line(center - extent, center + extent, warning_color, 3.0, true)
			draw_arc(center, 37.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 32, Color.WHITE, 4.0, true)
		else:
			var center: Vector2 = to_local(windup_position)
			draw_circle(center, 94.0, Color(warning_color.r, warning_color.g, warning_color.b, 0.13 + progress * 0.14))
			draw_arc(center, 94.0, 0.0, TAU, 64, warning_color, 3.5, true)
			draw_arc(center, 89.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 48, Color.WHITE, 4.0, true)
	elif kind == "archon":
		if windup_pattern == "triad":
			for center: Vector2 in _archon_triad_centers():
				var local_center: Vector2 = to_local(center)
				draw_circle(local_center, 54.0, Color(warning_color.r, warning_color.g, warning_color.b, 0.13 + progress * 0.14))
				draw_arc(local_center, 54.0, 0.0, TAU, 32, warning_color, 3.0, true)
				draw_arc(local_center, 49.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 28, Color.WHITE, 3.0, true)
		elif windup_pattern == "halo":
			var center: Vector2 = to_local(windup_position)
			draw_arc(center, 111.0, 0.0, TAU, 64, Color(warning_color.r, warning_color.g, warning_color.b, 0.12 + progress * 0.14), 90.0, true)
			draw_arc(center, 66.0, 0.0, TAU, 64, warning_color, 3.0, true)
			draw_arc(center, 156.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 64, Color.WHITE, 4.0, true)
		else:
			var beam_end: Vector2 = windup_direction * 520.0
			draw_line(Vector2.ZERO, beam_end, Color(warning_color.r, warning_color.g, warning_color.b, 0.12 + progress * 0.13), 82.0, true)
			draw_line(Vector2.ZERO, beam_end, warning_color, 3.0, true)
			draw_line(Vector2.ZERO, beam_end * progress, Color.WHITE, 4.0, true)
		draw_arc(Vector2.ZERO, 66.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 48, warning_color, 5.0, true)
	elif kind == "warden":
		if windup_pattern == "cage":
			var cage_center: Vector2 = to_local(windup_position)
			for axis: Vector2 in [windup_direction, windup_direction.orthogonal()]:
				var extent: Vector2 = axis * 150.0
				draw_line(cage_center - extent, cage_center + extent, Color(warning_color.r, warning_color.g, warning_color.b, 0.15 + progress * 0.16), 62.0, true)
				draw_line(cage_center - extent, cage_center + extent, warning_color, 3.0, true)
			draw_arc(cage_center, 42.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 36, Color.WHITE, 4.0, true)
		elif windup_pattern == "burst":
			for spread: float in [-0.36, -0.18, 0.0, 0.18, 0.36]:
				var ray: Vector2 = windup_direction.rotated(spread) * 480.0
				draw_line(Vector2.ZERO, ray, Color(warning_color.r, warning_color.g, warning_color.b, 0.10 + progress * 0.12), 20.0, true)
				draw_line(Vector2.ZERO, ray * progress, warning_color, 2.0, true)
		else:
			var side: Vector2 = windup_direction.orthogonal() * 72.0
			for lane: Vector2 in [-side, Vector2.ZERO, side]:
				draw_line(lane, lane + windup_direction * 520.0, Color(warning_color.r, warning_color.g, warning_color.b, 0.13 + progress * 0.14), 52.0, true)
				draw_line(lane, lane + windup_direction * 520.0 * progress, Color.WHITE, 2.8, true)
		draw_arc(Vector2.ZERO, 64.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 48, warning_color, 5.0, true)
	elif kind == "reaper":
		if windup_pattern == "leap":
			var leap_center: Vector2 = to_local(windup_position)
			draw_circle(leap_center, 102.0, Color(warning_color.r, warning_color.g, warning_color.b, 0.11 + progress * 0.13))
			draw_arc(leap_center, 102.0, 0.0, TAU, 48, warning_color, 4.0, true)
			draw_line(Vector2.ZERO, leap_center * progress, Color.WHITE, 3.0, true)
		elif windup_pattern == "shockring":
			draw_arc(Vector2.ZERO, 122.0, 0.0, TAU, 64, Color(warning_color.r, warning_color.g, warning_color.b, 0.15 + progress * 0.14), 108.0, true)
			draw_arc(Vector2.ZERO, 68.0, 0.0, TAU, 64, warning_color, 3.0, true)
			draw_arc(Vector2.ZERO, 176.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 64, Color.WHITE, 4.0, true)
		else:
			var left: Vector2 = windup_direction.rotated(-0.52) * 170.0
			var right: Vector2 = windup_direction.rotated(0.52) * 170.0
			draw_colored_polygon(PackedVector2Array([Vector2.ZERO, left, right]), Color(warning_color.r, warning_color.g, warning_color.b, 0.12 + progress * 0.14))
			draw_line(Vector2.ZERO, left, warning_color, 3.0, true)
			draw_line(Vector2.ZERO, right, warning_color, 3.0, true)
		draw_arc(Vector2.ZERO, 63.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 48, warning_color, 5.0, true)
	elif kind == "resonator":
		if windup_pattern == "echo_pulse":
			var echo_center: Vector2 = to_local(windup_position)
			draw_circle(echo_center, 118.0, Color(warning_color.r, warning_color.g, warning_color.b, 0.08 + progress * 0.10))
			draw_arc(echo_center, 118.0, 0.0, TAU, 56, warning_color, 3.0, true)
			draw_arc(echo_center, 220.0, 0.0, TAU, 56, Color(warning_color.r, warning_color.g, warning_color.b, 0.08 + progress * 0.08), 56.0, true)
			draw_arc(echo_center, 252.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 54, Color(0.92, 0.97, 0.98), 3.0, true)
		elif windup_pattern == "echo_collapse":
			var collapse_side: Vector2 = windup_direction.orthogonal() * 120.0
			for collapse_center: Vector2 in [windup_position, windup_position + collapse_side, windup_position - collapse_side]:
				var local_center: Vector2 = to_local(collapse_center)
				draw_circle(local_center, 62.0, Color(warning_color.r, warning_color.g, warning_color.b, 0.10 + progress * 0.12))
				draw_arc(local_center, 62.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 36, Color.WHITE, 3.0, true)
		else:
			var echo_side: Vector2 = windup_direction.orthogonal() * 86.0
			for lane: Vector2 in [-echo_side, Vector2.ZERO, echo_side]:
				draw_line(lane, lane + windup_direction * 560.0, Color(warning_color.r, warning_color.g, warning_color.b, 0.11 + progress * 0.12), 46.0, true)
				draw_line(lane, lane + windup_direction * 560.0 * progress, Color.WHITE, 2.6, true)
		draw_arc(Vector2.ZERO, 66.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 48, warning_color, 5.0, true)
	elif kind == "scrap_titan":
		if windup_pattern == "scrap_burst":
			for spread: float in [-0.34, -0.17, 0.0, 0.17, 0.34]:
				var scrap_ray: Vector2 = windup_direction.rotated(spread) * 470.0
				draw_line(Vector2.ZERO, scrap_ray, Color(warning_color.r, warning_color.g, warning_color.b, 0.08 + progress * 0.11), 18.0, true)
				draw_line(Vector2.ZERO, scrap_ray * progress, warning_color, 2.0, true)
		elif windup_pattern == "crusher_ring":
			draw_arc(Vector2.ZERO, 132.0, 0.0, TAU, 64, Color(warning_color.r, warning_color.g, warning_color.b, 0.12 + progress * 0.12), 112.0, true)
			draw_arc(Vector2.ZERO, 76.0, 0.0, TAU, 64, warning_color, 3.0, true)
			draw_arc(Vector2.ZERO, 188.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 64, Color.WHITE, 4.0, true)
		else:
			var titan_side: Vector2 = windup_direction.orthogonal() * 92.0
			for titan_lane: Vector2 in [-titan_side, Vector2.ZERO, titan_side]:
				draw_line(titan_lane, titan_lane + windup_direction * 540.0, Color(warning_color.r, warning_color.g, warning_color.b, 0.12 + progress * 0.13), 58.0, true)
				draw_line(titan_lane, titan_lane + windup_direction * 540.0 * progress, Color.WHITE, 2.8, true)
		draw_arc(Vector2.ZERO, 66.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 48, warning_color, 5.0, true)
	else:
		if windup_pattern == "sniper":
			var sniper_end: Vector2 = windup_direction * 500.0
			draw_line(Vector2.ZERO, sniper_end, Color(warning_color.r, warning_color.g, warning_color.b, 0.16 + progress * 0.16), 56.0, true)
			draw_line(Vector2.ZERO, sniper_end * progress, Color.WHITE, 3.0, true)
		elif windup_pattern == "rails":
			var side: Vector2 = windup_direction.orthogonal() * 38.0
			for lane: Vector2 in [side, -side]:
				draw_line(lane, lane + windup_direction * 500.0, Color(warning_color.r, warning_color.g, warning_color.b, 0.14 + progress * 0.15), 43.0, true)
				draw_line(lane, lane + windup_direction * 500.0, warning_color, 3.0, true)
				draw_line(lane, lane + windup_direction * 500.0 * progress, Color.WHITE, 2.0, true)
		else:
			var left: Vector2 = windup_direction.rotated(-0.30) * 485.0
			var right: Vector2 = windup_direction.rotated(0.30) * 485.0
			draw_colored_polygon(PackedVector2Array([Vector2.ZERO, left, right]), Color(warning_color.r, warning_color.g, warning_color.b, 0.10 + progress * 0.12))
			draw_line(Vector2.ZERO, left, warning_color, 3.0, true)
			draw_line(Vector2.ZERO, right, warning_color, 3.0, true)
			draw_line(Vector2.ZERO, windup_direction * 485.0, Color.WHITE, 1.5, true)
		draw_arc(Vector2.ZERO, 62.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 48, warning_color, 5.0, true)

func _draw_flat_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	for i: int in range(22):
		var angle: float = TAU * float(i) / 22.0
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	draw_colored_polygon(points, color)
