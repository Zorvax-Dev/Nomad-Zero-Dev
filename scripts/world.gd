extends Node2D
class_name StylizedWorld

const MAP_TEXTURE: Texture2D = preload("res://assets/map/desert_world_v48_2c.png")
const MAP_SCALE: float = 2.0
const BOUNDS: Rect2 = Rect2(0.0, 0.0, 4096.0, 3072.0)
const EDGE_MARGIN: float = 34.0
const PLAYER_START: Vector2 = Vector2(1536.0, 1024.0)
const CAMP_TEXTURE: Texture2D = preload("res://assets/decor/v46_1_camp_nomad.png")
const REFINERY_TEXTURE: Texture2D = preload("res://assets/decor/v46_1_refinery.png")
const WRECK_TEXTURE: Texture2D = preload("res://assets/decor/v46_1_wreck.png")
const ROCK_TEXTURE: Texture2D = preload("res://assets/decor/v46_1_rock_main.png")
const ROCK_TEXTURE_MIRROR: Texture2D = preload("res://assets/decor/v46_1_rock_mirror.png")
const OUTPOST_TEXTURE: Texture2D = preload("res://assets/decor/v46_1_outpost.png")
const CANYON_ROCK_TEXTURE: Texture2D = preload("res://assets/decor/v47_canyon_rock.png")
const ECHO_RUINS_TEXTURE: Texture2D = preload("res://assets/decor/v47_echo_ruins.png")
const ECHO_SPIRE_TEXTURE: Texture2D = preload("res://assets/decor/v47_echo_spire.png")
const LEVIATHAN_TEXTURE: Texture2D = preload("res://assets/decor/v48_leviathan.png")
const SALVAGE_RIG_TEXTURE: Texture2D = preload("res://assets/decor/v48_salvage_rig.png")
const SCRAP_HEAP_TEXTURE: Texture2D = preload("res://assets/decor/v48_scrap_heap.png")
const IRON_PIT_TEXTURE: Texture2D = preload("res://assets/decor/v48_iron_pit.png")
const SHADOW_TEXTURE: Texture2D = preload("res://assets/effects/ground_shadow.png")

var _blockers: Array[Dictionary] = []

func _ready() -> void:
	var sprite := Sprite2D.new()
	sprite.name = "V48WorldMap"
	sprite.texture = MAP_TEXTURE
	sprite.centered = false
	sprite.position = Vector2.ZERO
	sprite.scale = Vector2(MAP_SCALE, MAP_SCALE)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sprite.z_index = -1000
	add_child(sprite)

	_create_decor_sprites()
	_build_blockers()

func _create_decor_sprites() -> void:
	_add_blocking_decor("CampNorthWest", CAMP_TEXTURE, Vector2(500.0, 500.0), 0.440859, false, [
		{"offset": Vector2(0.0, 60.0), "radius": Vector2(225.0, 150.0)},
		{"offset": Vector2(-150.0, -35.0), "radius": Vector2(92.0, 110.0)},
		{"offset": Vector2(110.0, -32.0), "radius": Vector2(120.0, 92.0)},
	])
	_add_blocking_decor("RefineryNorthEast", REFINERY_TEXTURE, Vector2(2520.0, 520.0), 0.465352, true, [
		{"offset": Vector2(5.0, 35.0), "radius": Vector2(265.0, 170.0)},
		{"offset": Vector2(-195.0, 20.0), "radius": Vector2(95.0, 90.0)},
		{"offset": Vector2(160.0, -50.0), "radius": Vector2(120.0, 115.0)},
	])
	_add_blocking_decor("WreckSouth", WRECK_TEXTURE, Vector2(1620.0, 1485.0), 0.538828, false, [
		{"offset": Vector2(-20.0, 25.0), "radius": Vector2(295.0, 128.0)},
		{"offset": Vector2(140.0, -120.0), "radius": Vector2(110.0, 105.0)},
		{"offset": Vector2(-300.0, -15.0), "radius": Vector2(90.0, 70.0)},
		{"offset": Vector2(250.0, 25.0), "radius": Vector2(92.0, 70.0)},
	])
	_add_blocking_decor("OutpostSouthEast", OUTPOST_TEXTURE, Vector2(2460.0, 1480.0), 0.37, true, [
		{"offset": Vector2(0.0, 35.0), "radius": Vector2(185.0, 126.0)},
	])
	_add_blocking_decor("RockWest", ROCK_TEXTURE, Vector2(650.0, 1205.0), 0.52, false, [
		{"offset": Vector2(0.0, 45.0), "radius": Vector2(135.0, 92.0)},
	])
	_add_blocking_decor("RockEast", ROCK_TEXTURE_MIRROR, Vector2(2250.0, 1150.0), 0.49, false, [
		{"offset": Vector2(0.0, 40.0), "radius": Vector2(130.0, 90.0)},
	])
	_add_blocking_decor("RockCenterLeft", ROCK_TEXTURE, Vector2(1120.0, 850.0), 0.32, false, [
		{"offset": Vector2(0.0, 30.0), "radius": Vector2(88.0, 60.0)},
	])
	_add_blocking_decor("RockCenterRight", ROCK_TEXTURE_MIRROR, Vector2(1950.0, 860.0), 0.34, false, [
		{"offset": Vector2(0.0, 32.0), "radius": Vector2(92.0, 62.0)},
	])
	_add_blocking_decor("RockSouthWest", ROCK_TEXTURE_MIRROR, Vector2(1080.0, 1660.0), 0.28, false, [
		{"offset": Vector2(0.0, 32.0), "radius": Vector2(76.0, 54.0)},
	])
	_add_blocking_decor("RockSouthEast", ROCK_TEXTURE, Vector2(2085.0, 1690.0), 0.30, false, [
		{"offset": Vector2(0.0, 35.0), "radius": Vector2(82.0, 56.0)},
	])
	# V47.0 — Canyon des Échos : extension orientale, sans déplacement des zones V46.
	_add_blocking_decor("CanyonGateNorth", CANYON_ROCK_TEXTURE, Vector2(3275.0, 515.0), 0.36, false, [
		{"offset": Vector2(0.0, 30.0), "radius": Vector2(105.0, 72.0)},
	])
	_add_blocking_decor("CanyonGateSouth", CANYON_ROCK_TEXTURE, Vector2(3290.0, 1540.0), 0.34, true, [
		{"offset": Vector2(0.0, 30.0), "radius": Vector2(100.0, 70.0)},
	])
	_add_blocking_decor("CanyonRockNorth", CANYON_ROCK_TEXTURE, Vector2(3540.0, 610.0), 0.31, true, [
		{"offset": Vector2(0.0, 32.0), "radius": Vector2(90.0, 62.0)},
	])
	_add_blocking_decor("CanyonRockSouth", CANYON_ROCK_TEXTURE, Vector2(3490.0, 1515.0), 0.29, false, [
		{"offset": Vector2(0.0, 33.0), "radius": Vector2(86.0, 60.0)},
	])
	_add_decor("EchoRuins", ECHO_RUINS_TEXTURE, Vector2(3630.0, 1310.0), 0.50, false)
	_add_decor("EchoSpire", ECHO_SPIRE_TEXTURE, Vector2(3920.0, 820.0), 0.55, false)
	_add_decor("CanyonRockEast", CANYON_ROCK_TEXTURE, Vector2(3870.0, 1570.0), 0.24, true)
	# V49.6 — densité visuelle revue avec uniquement les assets existants de la zone :
	# les volumes sont plus présents sans changer la palette ni introduire un nouveau style.
	_add_decor("LeviathanWreck", LEVIATHAN_TEXTURE, Vector2(2150.0, 2670.0), 0.62, false)
	_add_decor("SalvageStation", SALVAGE_RIG_TEXTURE, Vector2(900.0, 2620.0), 0.46, true)
	_add_decor("IronPit", IRON_PIT_TEXTURE, Vector2(3070.0, 2480.0), 0.60, false)
	_add_decor("ScrapHeapEast", SCRAP_HEAP_TEXTURE, Vector2(2660.0, 2860.0), 0.42, false)
	_add_decor("ScrapHeapWest", SCRAP_HEAP_TEXTURE, Vector2(1380.0, 2840.0), 0.30, true)
	_add_decor("ScrapHeapNorth", SCRAP_HEAP_TEXTURE, Vector2(2700.0, 2260.0), 0.25, true)

func _decor_sort_offset(tex: Texture2D, scale_value: float) -> float:
	# Le sprite est centré dans une grande image transparente : trier sur pos.y faisait
	# passer le héros devant un bâtiment bien avant d'avoir atteint son pied réel.
	var source_offset: float = 270.0
	if tex == CAMP_TEXTURE: source_offset = 476.0
	elif tex == REFINERY_TEXTURE: source_offset = 440.0
	elif tex == WRECK_TEXTURE: source_offset = 284.0
	elif tex == OUTPOST_TEXTURE: source_offset = 435.0
	elif tex == CANYON_ROCK_TEXTURE: source_offset = 300.0
	elif tex == ECHO_RUINS_TEXTURE: source_offset = 250.0
	elif tex == ECHO_SPIRE_TEXTURE: source_offset = 205.0
	elif tex == LEVIATHAN_TEXTURE: source_offset = 323.0
	elif tex == SALVAGE_RIG_TEXTURE: source_offset = 402.0
	elif tex == IRON_PIT_TEXTURE: source_offset = 242.0
	elif tex == SCRAP_HEAP_TEXTURE: source_offset = 270.0
	return source_offset * absf(scale_value)

func _add_decor(node_name: String, tex: Texture2D, pos: Vector2, scale_value: float, flip_h: bool) -> void:
	# V46.3: les structures reposent sur un sol localement tassé et le réseau de chemins
	# contourne les volumes de collision. Cette ombre reste légère et sans collision.
	if tex == CAMP_TEXTURE or tex == REFINERY_TEXTURE or tex == WRECK_TEXTURE or tex == OUTPOST_TEXTURE or tex == ECHO_RUINS_TEXTURE or tex == ECHO_SPIRE_TEXTURE or tex == LEVIATHAN_TEXTURE or tex == SALVAGE_RIG_TEXTURE or tex == IRON_PIT_TEXTURE:
		_add_landmark_shadow(node_name, pos, scale_value)

	var spr := Sprite2D.new()
	spr.name = node_name
	spr.texture = tex
	spr.centered = true
	spr.position = pos
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	spr.scale = Vector2(-scale_value if flip_h else scale_value, scale_value)
	spr.z_index = int(pos.y + _decor_sort_offset(tex, scale_value))
	spr.modulate = Color.WHITE
	add_child(spr)

func _add_blocking_decor(node_name: String, tex: Texture2D, pos: Vector2, scale_value: float, flip_h: bool, blockers: Array[Dictionary]) -> void:
	# Reconstruction visuelle : un élément important ne peut plus être ajouté sans
	# déclarer explicitement ses volumes de blocage dans le même appel.
	_add_decor(node_name, tex, pos, scale_value, flip_h)
	for blocker: Dictionary in blockers:
		var offset: Vector2 = blocker.get("offset", Vector2.ZERO)
		var radius: Vector2 = blocker.get("radius", Vector2.ZERO)
		if radius.x <= 0.0 or radius.y <= 0.0:
			push_error("Landmark %s possède un collider invalide." % node_name)
			continue
		_add_ellipse(pos + offset, radius)

func _add_landmark_shadow(node_name: String, pos: Vector2, scale_value: float) -> void:
	var shadow := Sprite2D.new()
	shadow.name = node_name + "GroundShadow"
	shadow.texture = SHADOW_TEXTURE
	shadow.centered = true
	shadow.position = pos + Vector2(0.0, 58.0 * scale_value)
	shadow.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	shadow.scale = Vector2(absf(scale_value) * 4.25, absf(scale_value) * 3.15)
	shadow.modulate = Color(0.11, 0.09, 0.075, 0.18)
	shadow.z_index = int(pos.y) - 2
	add_child(shadow)

func _build_blockers() -> void:
	_blockers.clear()
	# North-west camp : collisions désormais attachées directement au sprite.
	# North-east refinery : collisions attachées au sprite.
	# South wreck : collisions attachées au sprite.
	# South-east outpost : collision attachée au sprite.
	# Rock groups around the central lanes
	# V47.0 — Canyon des Échos. Les falaises laissent un corridor central traversable.
	for x: float in [3210.0, 3435.0, 3660.0, 3890.0, 4050.0]:
		_add_ellipse(Vector2(x, 205.0), Vector2(165.0, 205.0))
		_add_ellipse(Vector2(x, 1840.0), Vector2(170.0, 208.0))
	# Pierres d'entrée et points d'intérêt du canyon.
	_add_ellipse(Vector2(3630.0, 1335.0), Vector2(135.0, 100.0))
	_add_ellipse(Vector2(3920.0, 845.0), Vector2(105.0, 88.0))
	_add_ellipse(Vector2(3870.0, 1600.0), Vector2(68.0, 48.0))
	# Cimetière d’Épaves — empreintes au sol recalées sur les pixels visibles.
	# Les anciennes ellipses provenaient d'une échelle plus grande et créaient de
	# larges murs invisibles autour des nouveaux décors.
	_add_ellipse(Vector2(2140.0, 2765.0), Vector2(158.0, 92.0))
	_add_ellipse(Vector2(2015.0, 2860.0), Vector2(96.0, 58.0))
	_add_ellipse(Vector2(2305.0, 2585.0), Vector2(76.0, 66.0))
	_add_ellipse(Vector2(905.0, 2740.0), Vector2(132.0, 68.0))
	_add_ellipse(Vector2(800.0, 2618.0), Vector2(58.0, 56.0))
	_add_ellipse(Vector2(3070.0, 2550.0), Vector2(102.0, 76.0))
	_add_ellipse(Vector2(2665.0, 2920.0), Vector2(91.0, 58.0))
	_add_ellipse(Vector2(1385.0, 2880.0), Vector2(65.0, 45.0))
	_add_ellipse(Vector2(2705.0, 2295.0), Vector2(55.0, 39.0))
	_add_ellipse(Vector2(1250.0, 2260.0), Vector2(145.0, 74.0))
	# Soft rocky rim from the background image so the player cannot walk on those visible edges.
	_add_ellipse(Vector2(170.0, 180.0), Vector2(210.0, 105.0))
	_add_ellipse(Vector2(2860.0, 210.0), Vector2(220.0, 112.0))
	_add_ellipse(Vector2(235.0, 1885.0), Vector2(220.0, 100.0))
	_add_ellipse(Vector2(2845.0, 1845.0), Vector2(220.0, 104.0))

func _add_ellipse(center: Vector2, radius: Vector2) -> void:
	_blockers.append({"type": "ellipse", "center": center, "radius": radius})

func echo_ruins_position() -> Vector2:
	return Vector2(3630.0, 1165.0)

func echo_resonator_position() -> Vector2:
	return Vector2(3840.0, 1040.0)

func graveyard_center() -> Vector2:
	return Vector2(2050.0, 2570.0)

func leviathan_position() -> Vector2:
	return Vector2(2150.0, 2450.0)

func salvage_station_position() -> Vector2:
	return Vector2(900.0, 2460.0)

func iron_pit_position() -> Vector2:
	return Vector2(3160.0, 2310.0)

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
