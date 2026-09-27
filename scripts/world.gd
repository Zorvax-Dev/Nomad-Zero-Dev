extends Node2D
class_name StylizedWorld

const MAP_TEXTURE: Texture2D = preload("res://assets/map/desert_world_v50.webp")
const MAP_SCALE: float = 4.0
const BOUNDS: Rect2 = Rect2(0.0, 0.0, 4096.0, 3072.0)
const EDGE_MARGIN: float = 34.0
const PLAYER_START: Vector2 = Vector2(1536.0, 1024.0)
var _blockers: Array[Dictionary] = []

func _ready() -> void:
	var sprite := Sprite2D.new()
	sprite.name = "V50WorldMap"
	sprite.texture = MAP_TEXTURE
	sprite.centered = false
	sprite.position = Vector2.ZERO
	sprite.scale = Vector2(MAP_SCALE, MAP_SCALE)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sprite.z_index = -1000
	add_child(sprite)

	_build_blockers()

func _build_blockers() -> void:
	_blockers.clear()

	# V50 — collisions calées sur les volumes lisibles du fond final.
	# On ne collisionne que les gros landmarks et falaises : les petits cailloux
	# restent traversables afin d'éviter tout mur invisible sur mobile.

	# Camp nord-ouest.
	_add_ellipse(Vector2(585.0, 425.0), Vector2(205.0, 118.0))
	_add_ellipse(Vector2(430.0, 370.0), Vector2(62.0, 84.0))

	# Raffinerie nord-est.
	_add_ellipse(Vector2(2425.0, 455.0), Vector2(245.0, 132.0))
	_add_ellipse(Vector2(2600.0, 360.0), Vector2(78.0, 94.0))

	# Épave centrale.
	_add_ellipse(Vector2(1660.0, 1495.0), Vector2(250.0, 108.0))
	_add_ellipse(Vector2(1785.0, 1370.0), Vector2(78.0, 92.0))

	# Avant-poste central-est.
	_add_ellipse(Vector2(2435.0, 1535.0), Vector2(170.0, 102.0))

	# Ruine / arche du Canyon.
	_add_ellipse(Vector2(3620.0, 1295.0), Vector2(112.0, 90.0))

	# Cimetière d'épaves : station, Léviathan et fosse.
	_add_ellipse(Vector2(760.0, 2550.0), Vector2(150.0, 102.0))
	_add_ellipse(Vector2(2150.0, 2640.0), Vector2(270.0, 116.0))
	_add_ellipse(Vector2(3140.0, 2510.0), Vector2(166.0, 106.0))

	# Quelques gros affleurements qui structurent réellement les routes.
	_add_ellipse(Vector2(650.0, 1215.0), Vector2(118.0, 80.0))
	_add_ellipse(Vector2(1120.0, 850.0), Vector2(78.0, 54.0))
	_add_ellipse(Vector2(1950.0, 870.0), Vector2(82.0, 56.0))
	_add_ellipse(Vector2(2250.0, 1165.0), Vector2(112.0, 76.0))
	_add_ellipse(Vector2(1080.0, 1680.0), Vector2(68.0, 48.0))
	_add_ellipse(Vector2(2085.0, 1700.0), Vector2(72.0, 50.0))

	# Bord rocheux oriental : volumes serrés sur l'extrême droite pour conserver
	# les routes et les espaces de combat du Canyon.
	for y: float in [190.0, 650.0, 1110.0, 1580.0, 2060.0, 2550.0, 2960.0]:
		_add_ellipse(Vector2(4050.0, y), Vector2(190.0, 245.0))

func _add_ellipse(center: Vector2, radius: Vector2) -> void:
	_blockers.append({"type": "ellipse", "center": center, "radius": radius})

func echo_ruins_position() -> Vector2:
	return Vector2(3620.0, 1190.0)

func echo_resonator_position() -> Vector2:
	return Vector2(3800.0, 1080.0)

func graveyard_center() -> Vector2:
	return Vector2(2120.0, 2570.0)

func leviathan_position() -> Vector2:
	return Vector2(2150.0, 2495.0)

func salvage_station_position() -> Vector2:
	return Vector2(760.0, 2420.0)

func iron_pit_position() -> Vector2:
	return Vector2(3140.0, 2350.0)

func update_streaming(_focus: Vector2, _force: bool = false) -> void:
	pass

func _inside_bounds(point: Vector2, padding: float = 0.0) -> bool:
	var margin: float = EDGE_MARGIN + padding
	return point.x >= margin and point.y >= margin and point.x <= BOUNDS.end.x - margin and point.y <= BOUNDS.end.y - margin

func _zone_blocks(point: Vector2, padding: float = 0.0) -> bool:
	# V44.1: one analytic collision test per obstacle instead of 9 probes x every obstacle.
	# Blockers are already drawn slightly inside the visible art; padding only accounts for actor radius.
	for blocker: Dictionary in _blockers:
		var blocker_type: String = blocker.get("type", "")
		if blocker_type == "ellipse":
			var center: Vector2 = blocker.get("center", Vector2.ZERO)
			var radius: Vector2 = blocker.get("radius", Vector2.ONE) + Vector2.ONE * padding
			if radius.x <= 0.0 or radius.y <= 0.0:
				continue
			var nx: float = (point.x - center.x) / radius.x
			var ny: float = (point.y - center.y) / radius.y
			if nx * nx + ny * ny <= 1.0:
				return true
	return false

func is_walkable(point: Vector2, radius: float = 18.0) -> bool:
	if not _inside_bounds(point, radius):
		return false
	# The current mask is intentionally empty/white, so avoid per-pixel image reads entirely.
	# A reduced actor padding keeps collisions readable without the old invisible halo.
	return not _zone_blocks(point, radius * 0.62)

func _furthest_walkable(origin: Vector2, motion: Vector2, radius: float) -> Vector2:
	if motion.length_squared() <= 0.0001:
		return origin
	if is_walkable(origin + motion, radius):
		return origin + motion
	var low: float = 0.0
	var high: float = 1.0
	for _i: int in range(8):
		var mid: float = (low + high) * 0.5
		if is_walkable(origin + motion * mid, radius):
			low = mid
		else:
			high = mid
	return origin + motion * low

func resolve_motion(from_pos: Vector2, desired_pos: Vector2, radius: float = 18.0) -> Vector2:
	if is_walkable(desired_pos, radius):
		return desired_pos
	var motion: Vector2 = desired_pos - from_pos
	if motion.length_squared() < 0.001:
		return from_pos
	var contact: Vector2 = _furthest_walkable(from_pos, motion, radius)
	var safe_contact: Vector2 = from_pos.lerp(contact, 0.985)
	if not is_walkable(safe_contact, radius):
		safe_contact = from_pos
	var remaining: float = maxf(4.0, desired_pos.distance_to(contact))
	var direction: Vector2 = motion.normalized()
	var best: Vector2 = safe_contact
	var best_score: float = -INF
	var angles: Array[float] = [-90.0, 90.0, -58.0, 58.0, -32.0, 32.0]
	for angle: float in angles:
		var slide_dir: Vector2 = direction.rotated(deg_to_rad(angle))
		var candidate: Vector2 = _furthest_walkable(safe_contact, slide_dir * remaining * 1.3, radius)
		var moved: Vector2 = candidate - safe_contact
		if moved.length_squared() <= 0.5:
			continue
		var score: float = moved.length() + maxf(0.0, moved.dot(direction)) * 0.20
		if score > best_score:
			best_score = score
			best = candidate
	return best

func random_walkable_far(origin: Vector2, min_dist: float, max_dist: float, rng: RandomNumberGenerator) -> Vector2:
	for _i: int in range(96):
		var angle: float = rng.randf_range(0.0, TAU)
		var dist: float = rng.randf_range(min_dist, max_dist)
		var point: Vector2 = origin + Vector2(cos(angle), sin(angle)) * dist
		point.x = clampf(point.x, EDGE_MARGIN + 28.0, BOUNDS.end.x - EDGE_MARGIN - 28.0)
		point.y = clampf(point.y, EDGE_MARGIN + 28.0, BOUNDS.end.y - EDGE_MARGIN - 28.0)
		if is_walkable(point, 26.0):
			return point
	return PLAYER_START


func nearest_walkable(point: Vector2, radius: float = 18.0, search_radius: float = 260.0) -> Vector2:
	# Garantit qu'un spawn / déplacement ponctuel ne reste jamais dans un décor.
	if is_walkable(point, radius):
		return point
	var rings: Array[float] = [24.0, 42.0, 64.0, 88.0, 116.0, 150.0, 192.0, 238.0, search_radius]
	for ring: float in rings:
		if ring > search_radius + 0.01:
			continue
		var samples: int = 16 if ring < 100.0 else 24
		for i: int in range(samples):
			var angle: float = TAU * float(i) / float(samples)
			var candidate: Vector2 = point + Vector2(cos(angle), sin(angle)) * ring
			if is_walkable(candidate, radius):
				return candidate
	return PLAYER_START if is_walkable(PLAYER_START, radius) else point

func has_walkable_line(from_pos: Vector2, to_pos: Vector2, radius: float = 18.0) -> bool:
	var distance: float = from_pos.distance_to(to_pos)
	if distance <= 1.0:
		return is_walkable(to_pos, radius)
	var steps: int = maxi(2, ceili(distance / 28.0))
	for i: int in range(1, steps + 1):
		var sample: Vector2 = from_pos.lerp(to_pos, float(i) / float(steps))
		if not is_walkable(sample, radius):
			return false
	return true

func detour_direction(origin: Vector2, desired_direction: Vector2, radius: float = 20.0, probe_distance: float = 92.0, prefer_sign: float = 1.0) -> Vector2:
	# Navigation locale légère : choisit un côté qui avance réellement autour du décor.
	var forward: Vector2 = desired_direction.normalized()
	if forward.length_squared() <= 0.001:
		return Vector2.ZERO
	var angles: Array[float] = [28.0, -28.0, 52.0, -52.0, 78.0, -78.0, 104.0, -104.0]
	if prefer_sign < 0.0:
		angles = [-28.0, 28.0, -52.0, 52.0, -78.0, 78.0, -104.0, 104.0]
	var best_dir: Vector2 = Vector2.ZERO
	var best_score: float = -INF
	for degrees: float in angles:
		var candidate_dir: Vector2 = forward.rotated(deg_to_rad(degrees))
		var probe: Vector2 = origin + candidate_dir * probe_distance
		var reachable: Vector2 = _furthest_walkable(origin, candidate_dir * probe_distance, radius)
		var progress: float = origin.distance_to(reachable)
		if progress < probe_distance * 0.34:
			continue
		var score: float = progress + candidate_dir.dot(forward) * 34.0
		if is_walkable(probe, radius):
			score += 18.0
		if score > best_score:
			best_score = score
			best_dir = candidate_dir
	return best_dir

func open_area_ratio(point: Vector2, actor_radius: float = 18.0, clearance_radius: float = 72.0, samples: int = 16) -> float:
	# Mesure la qualité d'une zone, pas seulement le pixel central. Un spawn peut être
	# techniquement praticable tout en étant coincé derrière un décor ou dans un étranglement.
	if not is_walkable(point, actor_radius):
		return 0.0
	var open_count: int = 0
	var tested: int = 0
	var ring_samples: int = maxi(8, samples)
	for ring_scale: float in [0.48, 1.0]:
		var ring_radius: float = clearance_radius * ring_scale
		for i: int in range(ring_samples):
			var angle: float = TAU * float(i) / float(ring_samples)
			var candidate: Vector2 = point + Vector2(cos(angle), sin(angle)) * ring_radius
			tested += 1
			if is_walkable(candidate, actor_radius):
				open_count += 1
	return float(open_count) / float(maxi(1, tested))

func is_open_area(point: Vector2, actor_radius: float = 18.0, clearance_radius: float = 72.0, min_ratio: float = 0.72) -> bool:
	if not is_walkable(point, actor_radius):
		return false
	return open_area_ratio(point, actor_radius, clearance_radius, 16) >= min_ratio

func nearest_open_area(point: Vector2, actor_radius: float = 18.0, clearance_radius: float = 72.0, min_ratio: float = 0.72, search_radius: float = 360.0) -> Vector2:
	# Cherche un vrai espace de circulation. Les anneaux sont ordonnés afin de conserver
	# au maximum la position souhaitée tout en évitant les recoins et couloirs trop serrés.
	if is_open_area(point, actor_radius, clearance_radius, min_ratio):
		return point
	var rings: Array[float] = [28.0, 48.0, 72.0, 100.0, 136.0, 176.0, 224.0, 280.0, 340.0, search_radius]
	for ring: float in rings:
		if ring > search_radius + 0.01:
			continue
		var samples: int = 20 if ring < 120.0 else 32
		for i: int in range(samples):
			var angle: float = TAU * float(i) / float(samples)
			var candidate: Vector2 = point + Vector2(cos(angle), sin(angle)) * ring
			if is_open_area(candidate, actor_radius, clearance_radius, min_ratio):
				return candidate
	return nearest_walkable(point, actor_radius, search_radius)

func random_open_far(origin: Vector2, min_dist: float, max_dist: float, rng: RandomNumberGenerator, actor_radius: float = 22.0, clearance_radius: float = 78.0, min_ratio: float = 0.72) -> Vector2:
	# Spawns normaux, mini-boss et boss utilisent tous la même notion d'espace viable.
	for _i: int in range(128):
		var angle: float = rng.randf_range(0.0, TAU)
		var dist: float = rng.randf_range(min_dist, max_dist)
		var point: Vector2 = origin + Vector2(cos(angle), sin(angle)) * dist
		point.x = clampf(point.x, EDGE_MARGIN + clearance_radius, BOUNDS.end.x - EDGE_MARGIN - clearance_radius)
		point.y = clampf(point.y, EDGE_MARGIN + clearance_radius, BOUNDS.end.y - EDGE_MARGIN - clearance_radius)
		if is_open_area(point, actor_radius, clearance_radius, min_ratio):
			return point
	var fallback: Vector2 = random_walkable_far(origin, min_dist, max_dist, rng)
	return nearest_open_area(fallback, actor_radius, clearance_radius, min_ratio, 420.0)

func safe_pickup_position(point: Vector2, radius: float = 16.0) -> Vector2:
	# V44.47 : un objet doit être accessible ET entouré d'un espace suffisant pour que
	# le joueur puisse l'atteindre puis repartir sans se coincer contre une structure.
	return nearest_open_area(point, maxf(22.0, radius), 68.0, 0.76, 380.0)

func zone_name(point: Vector2) -> String:
	if point.y >= 2048.0:
		return "CIMETIÈRE D’ÉPAVES"
	if point.x >= 3072.0:
		return "CANYON DES ÉCHOS"
	if point.distance_to(Vector2(500.0, 520.0)) < 410.0:
		return "CAMP NOMADE"
	if point.distance_to(Vector2(2520.0, 520.0)) < 430.0:
		return "RAFFINERIE"
	if point.distance_to(Vector2(1600.0, 1475.0)) < 380.0:
		return "ÉPAVE DU PÈLERIN"
	if point.distance_to(Vector2(2460.0, 1480.0)) < 290.0:
		return "AVANT-POSTE"
	if point.distance_to(Vector2(1536.0, 1024.0)) < 520.0:
		return "PLAINE CENTRALE"
	return "DÉSERT OUVERT"

func zone_danger(point: Vector2) -> int:
	match zone_name(point):
		"CAMP NOMADE":
			return 2
		"PLAINE CENTRALE":
			return 2
		"ÉPAVE DU PÈLERIN":
			return 3
		"AVANT-POSTE":
			return 4
		"RAFFINERIE":
			return 5
		"CANYON DES ÉCHOS":
			return 4
		"CIMETIÈRE D’ÉPAVES":
			return 5
		_:
			return 2
