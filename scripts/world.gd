extends Node2D
class_name StylizedWorld

const MAP_TEXTURE: Texture2D = preload("res://assets/map/desert_world_v50_1.webp")
const MAP_SCALE: float = 1.0
const BOUNDS: Rect2 = Rect2(0.0, 0.0, 4096.0, 3072.0)
const EDGE_MARGIN: float = 34.0
const PLAYER_START: Vector2 = Vector2(1536.0, 1024.0)

# V50.1 — chaque élément important reste un asset séparé, net et bloquant.
const CAMP_TEXTURE: Texture2D = preload("res://assets/decor/v46_1_camp_nomad.png")
const REFINERY_TEXTURE: Texture2D = preload("res://assets/decor/v46_1_refinery.png")
const WRECK_TEXTURE: Texture2D = preload("res://assets/decor/v46_1_wreck.png")
const ROCK_TEXTURE: Texture2D = preload("res://assets/decor/v46_1_rock_main.png")
const ROCK_TEXTURE_MIRROR: Texture2D = preload("res://assets/decor/v46_1_rock_mirror.png")
const CANYON_ROCK_TEXTURE: Texture2D = preload("res://assets/decor/v47_canyon_rock.png")
const LEVIATHAN_TEXTURE: Texture2D = preload("res://assets/decor/v48_leviathan.png")
const SALVAGE_RIG_TEXTURE: Texture2D = preload("res://assets/decor/v48_salvage_rig.png")
const SCRAP_HEAP_TEXTURE: Texture2D = preload("res://assets/decor/v48_scrap_heap.png")
const IRON_PIT_TEXTURE: Texture2D = preload("res://assets/decor/v48_iron_pit.png")
const SHADOW_TEXTURE: Texture2D = preload("res://assets/effects/ground_shadow.png")

var _blockers: Array[Dictionary] = []

func _ready() -> void:
	var sprite := Sprite2D.new()
	sprite.name = "V50_1Terrain"
	sprite.texture = MAP_TEXTURE
	sprite.centered = false
	sprite.position = Vector2.ZERO
	sprite.scale = Vector2(MAP_SCALE, MAP_SCALE)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sprite.z_index = -1000
	add_child(sprite)

	_blockers.clear()
	_create_landmarks()

func _sort_offset(tex: Texture2D, scale_value: float) -> float:
	var source_offset: float = 250.0
	if tex == CAMP_TEXTURE: source_offset = 470.0
	elif tex == REFINERY_TEXTURE: source_offset = 438.0
	elif tex == WRECK_TEXTURE: source_offset = 290.0
	elif tex == CANYON_ROCK_TEXTURE: source_offset = 300.0
	elif tex == LEVIATHAN_TEXTURE: source_offset = 325.0
	elif tex == SALVAGE_RIG_TEXTURE: source_offset = 400.0
	elif tex == IRON_PIT_TEXTURE: source_offset = 245.0
	elif tex == SCRAP_HEAP_TEXTURE: source_offset = 270.0
	return source_offset * absf(scale_value)

func _add_shadow(node_name: String, pos: Vector2, scale_value: float) -> void:
	var shadow := Sprite2D.new()
	shadow.name = node_name + "GroundShadow"
	shadow.texture = SHADOW_TEXTURE
	shadow.centered = true
	shadow.position = pos + Vector2(0.0, 50.0 * scale_value)
	shadow.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	shadow.scale = Vector2(absf(scale_value) * 3.55, absf(scale_value) * 2.42)
	shadow.modulate = Color(0.12, 0.085, 0.055, 0.14)
	shadow.z_index = int(pos.y) - 3
	add_child(shadow)

func _add_landmark(node_name: String, tex: Texture2D, pos: Vector2, scale_value: float, flip_h: bool, collider_offset: Vector2, collider_radius: Vector2, shadowed: bool = true) -> void:
	# Le collider principal est créé dans la même fonction que le sprite :
	# impossible d'ajouter visuellement un landmark sans blocage associé.
	if shadowed:
		_add_shadow(node_name, pos, scale_value)

	var spr := Sprite2D.new()
	spr.name = node_name
	spr.texture = tex
	spr.centered = true
	spr.position = pos
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	spr.scale = Vector2(-scale_value if flip_h else scale_value, scale_value)
	spr.z_index = int(pos.y + _sort_offset(tex, scale_value))
	spr.modulate = Color.WHITE
	add_child(spr)

	_add_ellipse(pos + collider_offset, collider_radius)

func _create_landmarks() -> void:
	# Zone nord-ouest — camp nomade détaillé.
	_add_landmark("CampNorthWest", CAMP_TEXTURE, Vector2(520.0, 500.0), 0.43, false, Vector2(0.0, 56.0), Vector2(205.0, 126.0))
	_add_ellipse(Vector2(380.0, 462.0), Vector2(70.0, 86.0))
	_add_ellipse(Vector2(642.0, 470.0), Vector2(82.0, 72.0))

	# Zone nord-est — raffinerie, seule grande structure industrielle de cette zone.
	_add_landmark("RefineryNorthEast", REFINERY_TEXTURE, Vector2(2510.0, 520.0), 0.45, true, Vector2(0.0, 48.0), Vector2(242.0, 142.0))
	_add_ellipse(Vector2(2318.0, 530.0), Vector2(80.0, 72.0))
	_add_ellipse(Vector2(2670.0, 470.0), Vector2(90.0, 88.0))

	# Épave centrale — grosse silhouette, plusieurs volumes pour coller à la coque.
	_add_landmark("CentralWreck", WRECK_TEXTURE, Vector2(1640.0, 1490.0), 0.51, false, Vector2(-20.0, 28.0), Vector2(235.0, 94.0))
	_add_ellipse(Vector2(1780.0, 1382.0), Vector2(76.0, 82.0))

	# Rochers de circulation — tous indépendants et tous bloquants.
	_add_landmark("RockWest", ROCK_TEXTURE, Vector2(650.0, 1210.0), 0.48, false, Vector2(0.0, 34.0), Vector2(118.0, 80.0), false)
	_add_landmark("RockCenterLeft", ROCK_TEXTURE, Vector2(1120.0, 850.0), 0.30, false, Vector2(0.0, 26.0), Vector2(72.0, 50.0), false)
	_add_landmark("RockCenterRight", ROCK_TEXTURE_MIRROR, Vector2(1950.0, 865.0), 0.31, false, Vector2(0.0, 27.0), Vector2(76.0, 52.0), false)
	_add_landmark("RockEast", ROCK_TEXTURE_MIRROR, Vector2(2250.0, 1160.0), 0.46, false, Vector2(0.0, 33.0), Vector2(112.0, 76.0), false)
	_add_landmark("RockSouthWest", ROCK_TEXTURE_MIRROR, Vector2(1080.0, 1660.0), 0.27, false, Vector2(0.0, 24.0), Vector2(64.0, 46.0), false)
	_add_landmark("RockSouthEast", ROCK_TEXTURE, Vector2(2085.0, 1690.0), 0.28, false, Vector2(0.0, 25.0), Vector2(68.0, 48.0), false)

	# Canyon des Échos — uniquement le rock art détaillé.
	# Les anciennes formes plates EchoRuins/EchoSpire sont volontairement supprimées.
	_add_landmark("CanyonGateNorth", CANYON_ROCK_TEXTURE, Vector2(3270.0, 520.0), 0.37, false, Vector2(0.0, 34.0), Vector2(92.0, 64.0), false)
	_add_landmark("CanyonGateSouth", CANYON_ROCK_TEXTURE, Vector2(3290.0, 1545.0), 0.35, true, Vector2(0.0, 32.0), Vector2(88.0, 61.0), false)
	_add_landmark("CanyonMonolithWest", CANYON_ROCK_TEXTURE, Vector2(3520.0, 1160.0), 0.31, false, Vector2(0.0, 29.0), Vector2(78.0, 56.0), false)
	_add_landmark("CanyonMonolithCenter", CANYON_ROCK_TEXTURE, Vector2(3700.0, 1115.0), 0.28, true, Vector2(0.0, 27.0), Vector2(70.0, 51.0), false)
	_add_landmark("CanyonMonolithEast", CANYON_ROCK_TEXTURE, Vector2(3870.0, 1190.0), 0.30, false, Vector2(0.0, 28.0), Vector2(74.0, 53.0), false)
	_add_landmark("CanyonRockNorth", CANYON_ROCK_TEXTURE, Vector2(3550.0, 645.0), 0.29, true, Vector2(0.0, 27.0), Vector2(73.0, 52.0), false)
	_add_landmark("CanyonRockSouth", CANYON_ROCK_TEXTURE, Vector2(3500.0, 1515.0), 0.28, false, Vector2(0.0, 26.0), Vector2(70.0, 50.0), false)

	# Cimetière d'Épaves — chaque objet garde sa silhouette et son blocage propre.
	_add_landmark("SalvageStation", SALVAGE_RIG_TEXTURE, Vector2(860.0, 2600.0), 0.43, true, Vector2(0.0, 72.0), Vector2(126.0, 76.0))
	_add_ellipse(Vector2(780.0, 2545.0), Vector2(54.0, 54.0))

	_add_landmark("LeviathanWreck", LEVIATHAN_TEXTURE, Vector2(2140.0, 2660.0), 0.58, false, Vector2(0.0, 82.0), Vector2(150.0, 72.0))
	_add_ellipse(Vector2(2015.0, 2755.0), Vector2(76.0, 46.0))
	_add_ellipse(Vector2(2295.0, 2575.0), Vector2(64.0, 56.0))

	_add_landmark("IronPit", IRON_PIT_TEXTURE, Vector2(3080.0, 2490.0), 0.56, false, Vector2(0.0, 60.0), Vector2(100.0, 72.0))

	_add_landmark("ScrapHeapEast", SCRAP_HEAP_TEXTURE, Vector2(2660.0, 2860.0), 0.37, false, Vector2(0.0, 48.0), Vector2(78.0, 49.0))
	_add_landmark("ScrapHeapWest", SCRAP_HEAP_TEXTURE, Vector2(1380.0, 2840.0), 0.28, true, Vector2(0.0, 38.0), Vector2(59.0, 39.0))
	_add_landmark("ScrapHeapNorth", SCRAP_HEAP_TEXTURE, Vector2(2700.0, 2260.0), 0.24, true, Vector2(0.0, 33.0), Vector2(51.0, 35.0))

	# Bord rocheux visible de l'est : collision de sécurité uniquement sur l'extrême bord.
	for y: float in [180.0, 610.0, 1040.0, 1490.0, 1940.0, 2390.0, 2840.0]:
		_add_ellipse(Vector2(4055.0, y), Vector2(155.0, 205.0))

func _add_ellipse(center: Vector2, radius: Vector2) -> void:
	_blockers.append({"type": "ellipse", "center": center, "radius": radius})

func echo_ruins_position() -> Vector2:
	return Vector2(3700.0, 1045.0)

func echo_resonator_position() -> Vector2:
	return Vector2(3860.0, 1060.0)

func graveyard_center() -> Vector2:
	return Vector2(2140.0, 2570.0)

func leviathan_position() -> Vector2:
	return Vector2(2140.0, 2510.0)

func salvage_station_position() -> Vector2:
	return Vector2(860.0, 2435.0)

func iron_pit_position() -> Vector2:
	return Vector2(3080.0, 2325.0)

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
