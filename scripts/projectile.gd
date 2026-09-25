extends Node2D
class_name NomadProjectile

signal impact(world_position: Vector2, damage: float, enemy_shot: bool, hit_color: Color)

var target: Node2D
var world_nav: StylizedWorld
var direction: Vector2 = Vector2.ZERO
var speed: float = 790.0
var damage: float = 20.0
var enemy_shot: bool = false
var tint_color: Color = Color(1.0, 0.18, 0.10)
var visual_style: String = "standard"
var lifetime: float = 2.0

func _ready() -> void:
	if direction.length_squared() <= 0.001 and is_instance_valid(target):
		direction = (target.global_position - global_position).normalized()
	if direction.length_squared() <= 0.001:
		direction = Vector2.RIGHT
	rotation = direction.angle()
	z_index = 3630
	queue_redraw()

func _physics_process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
		return
	if direction.length_squared() <= 0.001:
		queue_free()
		return
	var next_position: Vector2 = global_position + direction * speed * delta
	if is_instance_valid(world_nav):
		var sample_count: int = 4
		for sample_index: int in range(1, sample_count + 1):
			var sample_t: float = float(sample_index) / float(sample_count)
			var sample_position: Vector2 = global_position.lerp(next_position, sample_t)
			if not world_nav.is_walkable(sample_position, 2.0):
				impact.emit(sample_position, damage, enemy_shot, tint_color)
				queue_free()
				return
	if is_instance_valid(target):
		var hit_radius: float = 22.0 if enemy_shot else 24.0
		var closest: Vector2 = Geometry2D.get_closest_point_to_segment(target.global_position, global_position, next_position)
		if closest.distance_to(target.global_position) <= hit_radius:
			if target.has_method("take_damage"):
				target.take_damage(damage)
			impact.emit(target.global_position, damage, enemy_shot, tint_color)
			queue_free()
			return
	elif enemy_shot:
		queue_free()
		return
	global_position = next_position

func _draw() -> void:
	# V46.5: distinct projectile silhouettes without oversized neon bloom.
	var shell: Color = Color(tint_color.r, tint_color.g, tint_color.b, 0.88)
	var core: Color = Color(1.0, 0.94, 0.86, 0.96) if enemy_shot else Color(0.90, 1.0, 0.94, 0.96)
	var glow: Color = Color(tint_color.r, tint_color.g, tint_color.b, 0.16)
	var back_x: float = -8.0
	var front_x: float = 12.0
	var glow_width: float = 7.0
	var shell_width: float = 3.8
	var core_width: float = 1.5
	match visual_style:
		"sniper":
			back_x = -17.0; front_x = 22.0; glow_width = 5.8; shell_width = 2.9; core_width = 1.15
		"rail":
			back_x = -14.0; front_x = 19.0; glow_width = 6.0; shell_width = 3.1; core_width = 1.25
		"suppressor":
			back_x = -6.0; front_x = 10.0; glow_width = 8.0; shell_width = 4.6; core_width = 1.7
		"phase":
			back_x = -11.0; front_x = 15.0; glow_width = 6.5; shell_width = 3.0; core_width = 1.2
		"null":
			back_x = -10.0; front_x = 14.0; glow_width = 7.2; shell_width = 3.3; core_width = 1.35
		"void":
			back_x = -9.0; front_x = 13.0; glow_width = 7.0; shell_width = 3.2; core_width = 1.3
		"overcharged":
			back_x = -8.0; front_x = 13.0; glow_width = 8.4; shell_width = 4.1; core_width = 1.5
		"scrap":
			back_x = -7.0; front_x = 11.0; glow_width = 6.8; shell_width = 3.8; core_width = 1.4
		"turret":
			back_x = -12.0; front_x = 17.0; glow_width = 6.2; shell_width = 3.2; core_width = 1.25
		"titan":
			back_x = -13.0; front_x = 18.0; glow_width = 8.0; shell_width = 4.2; core_width = 1.55
	draw_line(Vector2(back_x, 0.0), Vector2(front_x, 0.0), glow, glow_width, true)
	draw_line(Vector2(back_x + 1.0, 0.0), Vector2(front_x - 1.0, 0.0), shell, shell_width, true)
	draw_line(Vector2(back_x + 3.0, 0.0), Vector2(front_x - 2.0, 0.0), core, core_width, true)
	draw_circle(Vector2(front_x, 0.0), maxf(1.3, shell_width * 0.46), shell)
	if visual_style in ["sniper", "rail"]:
		draw_line(Vector2(back_x - 5.0, 0.0), Vector2(back_x, 0.0), Color(shell.r, shell.g, shell.b, 0.28), 1.3, true)
