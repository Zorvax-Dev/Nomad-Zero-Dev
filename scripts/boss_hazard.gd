extends Node2D
class_name NomadBossHazard

signal activated(boss_kind: String)

var boss_kind: String = ""
var boss: NomadEnemy
var player: NomadPlayer
var world_nav: StylizedWorld
var warning_left: float = 1.15
var warning_duration: float = 1.15
var active_left: float = 1.6
var hit_cooldown: float = 0.0
var origin: Vector2 = Vector2.ZERO
var forward: Vector2 = Vector2.RIGHT
var lane_starts: Array[Vector2] = []
var lane_ends: Array[Vector2] = []
var rift_centers: Array[Vector2] = []

func configure(source: NomadEnemy, hero: NomadPlayer, terrain: StylizedWorld) -> bool:
	boss = source
	player = hero
	world_nav = terrain
	boss_kind = source.kind
	origin = source.global_position
	forward = (hero.global_position - origin).normalized()
	if forward.length_squared() < 0.01:
		forward = Vector2.RIGHT
	z_index = 1
	var hero_distance: float = origin.distance_to(hero.global_position)
	match boss_kind:
		"marauder":
			var end_point: Vector2 = _clipped_end(origin, forward, minf(570.0, maxf(320.0, hero_distance + 170.0)))
			if origin.distance_to(end_point) < 90.0:
				return false
			lane_starts.append(origin)
			lane_ends.append(end_point)
			active_left = 1.55
		"sentinel":
			var distance: float = minf(690.0, maxf(400.0, hero_distance + 170.0))
			var side: Vector2 = forward.orthogonal() * 120.0
			for lane_origin: Vector2 in [origin, origin + side]:
				if not world_nav.is_walkable(lane_origin, 8.0):
					return false
				var lane_end: Vector2 = _clipped_end(lane_origin, forward, distance)
				if lane_origin.distance_to(lane_end) < 90.0:
					return false
				lane_starts.append(lane_origin)
				lane_ends.append(lane_end)
			active_left = 1.35
		"archon":
			var locked_target: Vector2 = hero.global_position
			var cross: Vector2 = forward.orthogonal() * 165.0
			rift_centers.append(locked_target)
			for other_center: Vector2 in [locked_target + cross + forward * 70.0, locked_target - cross + forward * 70.0]:
				if world_nav.is_walkable(other_center, 28.0):
					rift_centers.append(other_center)
			active_left = 2.05
		"warden":
			var null_distance: float = minf(650.0, maxf(410.0, hero_distance + 160.0))
			var null_side: Vector2 = forward.orthogonal() * 96.0
			for lane_origin: Vector2 in [origin - null_side, origin, origin + null_side]:
				if not world_nav.is_walkable(lane_origin, 8.0):
					continue
				var lane_end: Vector2 = _clipped_end(lane_origin, forward, null_distance)
				if lane_origin.distance_to(lane_end) >= 90.0:
					lane_starts.append(lane_origin)
					lane_ends.append(lane_end)
			if lane_starts.is_empty():
				return false
			active_left = 1.45
		"reaper":
			rift_centers.append(hero.global_position)
			active_left = 1.70
		"resonator":
			var echo_target: Vector2 = hero.global_position
			var echo_side: Vector2 = forward.orthogonal() * 128.0
			rift_centers.append(echo_target)
			for echo_center: Vector2 in [echo_target + echo_side, echo_target - echo_side]:
				if world_nav.is_walkable(echo_center, 24.0):
					rift_centers.append(echo_center)
			active_left = 1.85
		"scrap_titan":
			var titan_distance: float = minf(650.0, maxf(410.0, hero_distance + 150.0))
			var titan_side: Vector2 = forward.orthogonal() * 92.0
			for lane_origin: Vector2 in [origin - titan_side, origin, origin + titan_side]:
				if not world_nav.is_walkable(lane_origin, 10.0):
					continue
				var lane_end: Vector2 = _clipped_end(lane_origin, forward, titan_distance)
				if lane_origin.distance_to(lane_end) >= 90.0:
					lane_starts.append(lane_origin)
					lane_ends.append(lane_end)
			if lane_starts.is_empty():
				return false
			active_left = 1.55
		_:
			return false
	queue_redraw()
	return true

func warning_name() -> String:
	match boss_kind:
		"marauder": return "PERCÉE"
		"sentinel": return "LIGNES DE TIR"
		"archon": return "FAILLES INSTABLES"
		"warden": return "GRILLE NULL"
		"reaper": return "CENDRES VIVES"
		"resonator": return "RÉSONANCE FRACTURÉE"
		"scrap_titan": return "CHAMP MAGNÉTIQUE"
		_: return "DANGER"

func _clipped_end(start: Vector2, direction: Vector2, length: float) -> Vector2:
	var last_walkable: Vector2 = start
	for index: int in range(1, ceili(length / 20.0) + 1):
		var point: Vector2 = start + direction * minf(length, float(index) * 20.0)
		if not world_nav.is_walkable(point, 6.0):
			return last_walkable
		last_walkable = point
	return last_walkable

func _physics_process(delta: float) -> void:
	if not is_instance_valid(boss) or not boss.active or not is_instance_valid(player) or not player.active:
		queue_free()
		return
	var remaining_step: float = delta
	if warning_left > 0.0:
		var preparation_step: float = minf(warning_left, remaining_step)
		warning_left -= preparation_step
		remaining_step -= preparation_step
		if warning_left <= 0.0:
			activated.emit(boss_kind)
		queue_redraw()
		if warning_left > 0.0:
			return
	active_left = maxf(0.0, active_left - remaining_step)
	if active_left <= 0.0:
		queue_free()
		return
	hit_cooldown = maxf(0.0, hit_cooldown - remaining_step)
	if hit_cooldown <= 0.0 and is_point_dangerous(player.global_position):
		player.take_damage(boss.damage * (0.42 if boss_kind == "archon" else (0.46 if boss_kind == "resonator" else (0.47 if boss_kind == "scrap_titan" else (0.48 if boss_kind in ["warden", "reaper"] else 0.55)))))
		hit_cooldown = 0.90
	queue_redraw()

func is_point_dangerous(point: Vector2) -> bool:
	if boss_kind == "archon":
		for center: Vector2 in rift_centers:
			if point.distance_to(center) <= 64.0:
				return true
		return false
	if boss_kind == "reaper":
		for center: Vector2 in rift_centers:
			if point.distance_to(center) <= 88.0:
				return true
		return false
	if boss_kind == "resonator":
		for center: Vector2 in rift_centers:
			if point.distance_to(center) <= 72.0:
				return true
		return false
	var reach: float = 42.0 if boss_kind == "marauder" else (32.0 if boss_kind == "scrap_titan" else (30.0 if boss_kind == "warden" else 34.0))
	for index: int in range(lane_starts.size()):
		var closest: Vector2 = Geometry2D.get_closest_point_to_segment(point, lane_starts[index], lane_ends[index])
		if closest.distance_to(point) <= reach:
			return true
	return false

func _draw() -> void:
	var hue: Color = Color("d88442") if boss_kind == "scrap_titan" else (Color("ff914f") if boss_kind == "marauder" else (Color("b98bff") if boss_kind == "sentinel" else (Color("a5eb68") if boss_kind == "archon" else (Color("55e8ff") if boss_kind == "warden" else (Color("b97bff") if boss_kind == "resonator" else Color("ff5f91"))))))
	var preparing: bool = warning_left > 0.0
	var progress: float = 1.0 - warning_left / maxf(0.01, warning_duration)
	var visible_alpha: float = 0.15 + progress * 0.16 if preparing else 0.26 * minf(1.0, active_left * 2.0)
	if boss_kind == "archon":
		for center: Vector2 in rift_centers:
			draw_circle(center, 64.0, Color(hue.r, hue.g, hue.b, visible_alpha))
			draw_arc(center, 64.0, 0.0, TAU, 40, hue, 3.0, true)
			if preparing:
				draw_arc(center, 57.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 40, Color.WHITE, 3.0, true)
			else:
				draw_arc(center, 24.0 + sin(active_left * 12.0) * 6.0, 0.0, TAU, 24, Color(0.88, 1.0, 0.77, 0.7), 2.0, true)
		return
	if boss_kind == "reaper":
		for center: Vector2 in rift_centers:
			draw_circle(center, 88.0, Color(hue.r, hue.g, hue.b, visible_alpha))
			draw_arc(center, 88.0, 0.0, TAU, 44, hue, 3.5, true)
			if preparing:
				draw_arc(center, 78.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 40, Color.WHITE, 3.5, true)
			else:
				draw_arc(center, 34.0 + sin(active_left * 15.0) * 8.0, 0.0, TAU, 28, Color(1.0, 0.76, 0.84, 0.72), 2.5, true)
		return
	if boss_kind == "resonator":
		for center: Vector2 in rift_centers:
			draw_circle(center, 72.0, Color(hue.r, hue.g, hue.b, visible_alpha))
			draw_arc(center, 72.0, 0.0, TAU, 44, hue, 3.5, true)
			if preparing:
				draw_arc(center, 62.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 40, Color.WHITE, 3.2, true)
			else:
				draw_arc(center, 30.0 + sin(active_left * 14.0) * 7.0, 0.0, TAU, 28, Color(0.92, 0.82, 1.0, 0.74), 2.4, true)
		return
	var reach: float = 84.0 if boss_kind == "marauder" else (64.0 if boss_kind == "scrap_titan" else (60.0 if boss_kind == "warden" else 68.0))
	for index: int in range(lane_starts.size()):
		var from_point: Vector2 = lane_starts[index]
		var to_point: Vector2 = lane_ends[index]
		draw_line(from_point, to_point, Color(hue.r, hue.g, hue.b, visible_alpha), reach, true)
		draw_line(from_point, to_point, hue, 3.0 if preparing else 5.0, true)
		if preparing:
			draw_line(from_point, from_point.lerp(to_point, progress), Color.WHITE, 3.0, true)
		else:
			draw_line(from_point, to_point, Color(0.94, 1.0, 0.89, 0.48), 1.5, true)
