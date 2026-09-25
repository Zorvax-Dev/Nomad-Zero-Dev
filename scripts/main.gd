extends Node2D

const WorldScript = preload("res://scripts/world.gd")
const PlayerScript = preload("res://scripts/player.gd")
const EnemyScript = preload("res://scripts/enemy.gd")
const ProjectileScript = preload("res://scripts/projectile.gd")
const XPOrbScript = preload("res://scripts/xp_orb.gd")
const SupplyScript = preload("res://scripts/supply_pickup.gd")
const JoystickScript = preload("res://scripts/virtual_joystick.gd")
const RiftFragmentScript = preload("res://scripts/rift_fragment.gd")
const BossHazardScript = preload("res://scripts/boss_hazard.gd")
const ZoneObjectiveMarkerScript = preload("res://scripts/zone_objective_marker.gd")
const LootPickupScript = preload("res://scripts/loot_pickup.gd")
const LootCacheScript = preload("res://scripts/loot_cache.gd")
const CanyonSecretScript = preload("res://scripts/canyon_secret.gd")

const MAP_TEXTURE: Texture2D = preload("res://assets/map/desert_world_v48_2c.png")
const HERO_PREVIEW: Texture2D = preload("res://assets/hero/hero_idle.png")
const PULSE_TEXTURE: Texture2D = preload("res://assets/effects/pulse.png")
const HIT_TEXTURE: Texture2D = preload("res://assets/effects/hit_burst.png")
const MUZZLE_TEXTURE: Texture2D = preload("res://assets/effects/muzzle_flash.png")
const SCREEN_GRADE_TEXTURE: Texture2D = preload("res://assets/ui/screen_grade.png")

const SFX_SABER_SWING: AudioStream = preload("res://assets/audio/saber_swing.wav")
const SFX_SABER_HIT: AudioStream = preload("res://assets/audio/saber_impact_v36.wav")
const SFX_SABER_HIT_HEAVY: AudioStream = preload("res://assets/audio/saber_impact_heavy_v36.wav")
const SFX_ENEMY_SHOOT: AudioStream = preload("res://assets/audio/blaster_enemy_v33.wav")
const SFX_HIT: AudioStream = preload("res://assets/audio/hit.wav")
const SFX_XP: AudioStream = preload("res://assets/audio/xp.wav")
const SFX_LEVEL: AudioStream = preload("res://assets/audio/level.wav")
const SFX_PULSE: AudioStream = preload("res://assets/audio/pulse.wav")
const SFX_HURT: AudioStream = preload("res://assets/audio/hurt.wav")
const SFX_UI: AudioStream = preload("res://assets/audio/ui.wav")
const SFX_BOSS_ARRIVAL: AudioStream = preload("res://assets/audio/boss_arrival_v39.wav")
const SFX_BOSS_PHASE: AudioStream = preload("res://assets/audio/boss_phase_v39.wav")
const SFX_BOSS_DEFEAT: AudioStream = preload("res://assets/audio/boss_defeat_v39.wav")
const SFX_MINIBOSS_ALERT: AudioStream = preload("res://assets/audio/miniboss_alert_v39.wav")
const SFX_LOOT_RARE: AudioStream = preload("res://assets/audio/loot_rare_v39.wav")

const VIEW: Vector2 = Vector2(1280.0, 720.0)
const SAFE_AREA_JS: String = """(function() {
  var probe = document.createElement('div');
  probe.style.cssText = 'position:fixed;visibility:hidden;pointer-events:none;' +
    'padding-left:env(safe-area-inset-left,0px);' +
    'padding-top:env(safe-area-inset-top,0px);' +
    'padding-right:env(safe-area-inset-right,0px);' +
    'padding-bottom:env(safe-area-inset-bottom,0px)';
  document.body.appendChild(probe);
  var style = window.getComputedStyle(probe);
  var values = [parseFloat(style.paddingLeft) || 0, parseFloat(style.paddingTop) || 0,
    parseFloat(style.paddingRight) || 0, parseFloat(style.paddingBottom) || 0,
    window.innerWidth || 0, window.innerHeight || 0,
    /iPhone/i.test(navigator.userAgent) ? 1 : 0];
  probe.remove();
  return JSON.stringify(values);
})()"""
const SAVE_PATH: String = "user://nomad_zero_profile.cfg"
const SAVE_BACKUP_PATH: String = "user://nomad_zero_profile.backup.cfg"
const SAVE_TEMP_PATH: String = "user://nomad_zero_profile.tmp.cfg"
const LEGACY_SAVE_PATH: String = "user://rift_nomad_stylized.cfg"
const SAVE_VERSION: int = 9
const RUN_SAVE_VERSION: int = 1
const AUTOSAVE_INTERVAL: float = 12.0
const APP_VERSION: String = "49.2.0"
const BUILD_NAME: String = "V49.2 • COMBAT LISIBILITÉ"
const BOSS_CUTOUT: Shader = preload("res://assets/bosses/boss_cutout.gdshader")
const BOSS_TEXTURES: Dictionary = {
	"sentinel": preload("res://assets/bosses/sentinel_idle.png"),
	"marauder": preload("res://assets/bosses/marauder_idle.png"),
	"archon": preload("res://assets/bosses/archon_idle.png"),
	"warden": preload("res://assets/bosses/sentinel_idle.png"),
	"reaper": preload("res://assets/bosses/marauder_idle.png"),
	"resonator": preload("res://assets/bosses/resonator_idle.png"),
	"scrap_titan": preload("res://assets/bosses/scrap_titan_idle.png")
}
const BOSS_KINDS: Array[String] = ["sentinel", "marauder", "archon", "warden", "reaper", "resonator", "scrap_titan"]
const MINIBOSS_KINDS: Array[String] = ["phantom", "colossus", "veil_guardian", "leviathan_grinder"]
const BACKUP_MAX_BYTES: int = 4 * 1024 * 1024
const WEB_BACKUP_PICKER_JS: String = """(function() {
  window.__nomadBackupStatus = '';
  window.__nomadBackupPayload = '';
  var input = document.createElement('input');
  input.type = 'file';
  input.accept = '.cfg,text/plain';
  input.style.display = 'none';
  document.body.appendChild(input);
  input.addEventListener('change', function() {
    var file = input.files && input.files[0];
    if (!file) { input.remove(); return; }
    if (file.size > 4194304) { window.__nomadBackupStatus = 'large'; input.remove(); return; }
    var reader = new FileReader();
    reader.onload = function() {
      window.__nomadBackupPayload = String(reader.result || '');
      window.__nomadBackupStatus = 'ready';
      input.remove();
    };
    reader.onerror = function() { window.__nomadBackupStatus = 'error'; input.remove(); };
    reader.readAsText(file, 'UTF-8');
  }, {once: true});
  input.click();
})()"""
const RUN_SAVE_PROPERTIES = [
	"kills", "level", "xp", "xp_needed",
	"run_time", "combo", "combo_timer", "attack_timer",
	"spawn_timer", "event_timer", "wave_number", "wave_duration",
	"wave_time_left", "wave_cleanup", "wave_intermission", "elites_killed",
	"stream_timer", "cleanup_timer", "run_fragments", "run_xp_multiplier",
	"run_life_on_kill", "run_fragment_bonus_chance", "run_synergies", "pending_level_choices",
	"active_zone_name", "zone_stay_timer", "camp_support_timer", "central_supply_timer",
	"zone_logic_accumulator", "run_modules", "run_module_count", "dynamic_event_active",
	"dynamic_event_kind", "dynamic_event_position", "dynamic_event_started", "dynamic_event_progress",
	"dynamic_event_target", "dynamic_event_spawn_timer", "dynamic_event_age", "dynamic_event_serial",
	"dynamic_event_kills", "dynamic_event_target_kills", "skill_traction_cooldown_timer", "skill_surge_timer",
	"skill_surge_cooldown_timer"
]
const PLAYER_SAVE_PROPERTIES = [
	"speed", "max_health", "health", "max_shield", "shield", "damage",
	"attack_interval", "pulse_cooldown", "pulse_timer", "force_wave_radius",
	"force_wave_damage_scale", "force_wave_knockback", "force_wave_auto_range",
	"dash_cooldown", "dash_timer", "armor", "regeneration",
	"shield_regeneration", "magnet_range", "critical_chance", "critical_multiplier",
	"multishot_count", "saber_range", "saber_arc_degrees"
]
const ENEMY_SAVE_PROPERTIES = [
	"speed", "max_health", "health", "damage", "attack_timer", "xp_value",
	"attack_speed_multiplier", "damage_taken_multiplier", "role_action_timer",
	"affix_action_timer", "exposed_timer"
]

enum State { MENU, PLAYING, PAUSED, GAME_OVER }
var state: State = State.MENU

var world: StylizedWorld
var player: NomadPlayer
var world_entities: Node2D
var mission_markers_root: Node2D
var mission_markers: Dictionary = {}
var boss_hazards_root: Node2D
var enemies_root: Node2D
var projectiles_root: Node2D
var pickups_root: Node2D
var secrets_root: Node2D
var fx_root: Node2D
var world_camera: Camera2D

var ui: CanvasLayer
var full_bleed_controls: Array[Control] = []
var last_layout_viewport: Vector2 = Vector2.ZERO
var last_layout_insets: Vector4 = Vector4(-1.0, -1.0, -1.0, -1.0)
var layout_poll_timer: float = 0.0
var menu_compact: bool = false
var menu: Control
var boss_dossier_overlay: Control
var boss_dossier_card: Panel
var boss_dossier_veil: ColorRect
var boss_dossier_tabs: Dictionary = {}
var boss_dossier_selected: String = "sentinel"
var boss_dossier_portrait: TextureRect
var boss_dossier_name_label: Label
var boss_dossier_wave_label: Label
var boss_dossier_phase_one_label: Label
var boss_dossier_phase_two_label: Label
var boss_dossier_tip_label: Label
var boss_dossier_reward_label: Label
var boss_dossier_count_label: Label
var hud: Control
var pause_panel: Control
var game_over: Control
var rotation_overlay: Control
var rotation_card: Panel
var rotation_icon: Label
var rotation_title: Label
var rotation_hint: Label
var rotation_blocked: bool = false
var joystick: NomadVirtualJoystick
var hud_status: Control
var hud_wave_panel: Panel
var hud_info_panel: Panel
var hud_pause_button: Button
var hud_name_label: Label
var hud_health_caption: Label
var hud_xp_caption: Label

var health_bar: ProgressBar
var xp_bar: ProgressBar
var hp_label: Label
var xp_label: Label
var level_label: Label
var kills_label: Label
var time_label: Label
var zone_label: Label
var danger_label: Label
# V44.42 — touches actives tactiles. Le joystick réserve tout le bloc.
var shield_bar: ProgressBar
var force_status_label: Label
var event_label: Label
var boss_bar: ProgressBar
var boss_label: Label
var boss_move_label: Label
var threat_label: Label
var toast_label: Label
var combo_label: Label
# V44.39 — couche de présentation cinématique et feedback de loot.
var presentation_overlay: Control
var presentation_veil: ColorRect
var presentation_top_bar: ColorRect
var presentation_bottom_bar: ColorRect
var presentation_card: Panel
var presentation_accent: ColorRect
var presentation_title: Label
var presentation_subtitle: Label
var presentation_tween: Tween
var loot_banner_panel: Panel
var loot_banner_rarity: Label
var loot_banner_name: Label
var loot_banner_hint: Label
var loot_banner_tween: Tween
var game_over_stats: Label
var menu_best_label: Label
var menu_fragment_label: Label
var menu_portrait_frame: Panel
var menu_hero_stand: TextureRect
var menu_hero_floor: ColorRect
var menu_meta_title: Label
var menu_meta_summary_label: Label
var resume_button: Button
var new_run_button: Button
var menu_run_hint: Label
var backup_export_button: Button
var backup_import_button: Button
var backup_status_label: Label
var backup_file_dialog: FileDialog
var backup_dialog_mode: String = ""
var pending_backup_text: String = ""
var web_backup_waiting: bool = false
var web_backup_poll_timer: float = 0.0
var meta_damage_button: Button
var meta_health_button: Button
var meta_instinct_button: Button
var meta_tree_overlay: Control
var meta_tree_card: Panel
var meta_tree_veil: ColorRect
var meta_tree_buttons: Dictionary = {}
var meta_tree_fragment_label: Label
var meta_tree_hint_label: Label
var upgrade_panel: Control
var upgrade_title_label: Label
var upgrade_buttons: Array[Button] = []
var pending_upgrade_options: Array[Dictionary] = []
var upgrade_pending: bool = false
var pending_level_choices: int = 0

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var attack_timer: float = 0.0
var spawn_timer: float = 0.0
var kills: int = 0
var level: int = 1
var xp: int = 0
var xp_needed: int = 26
var run_time: float = 0.0
var toast_timer: float = 0.0
var combo: int = 0
var combo_timer: float = 0.0
var shake_time: float = 0.0
var shake_strength: float = 0.0
var event_timer: float = 28.0
var wave_number: int = 1
var wave_duration: float = 50.0
var wave_time_left: float = 50.0
var wave_cleanup: bool = false
var wave_intermission: float = -1.0
var boss_enemy: NomadEnemy
var boss_event_timer: float = 4.2
var boss_event_count: int = 0
var elites_killed: int = 0
var stream_timer: float = 0.0
var cleanup_timer: float = 0.0
var overdrive_meter: float = 0.0
var overdrive_time: float = 0.0
var run_fragments: int = 0
var rift_fragments: int = 0
var run_xp_multiplier: float = 1.0
var run_life_on_kill: float = 0.0
var run_fragment_bonus_chance: float = 0.0
var run_synergies: Dictionary = {}
var zone_banner_timer: float = 0.0
var active_zone_name: String = ""
var zone_stay_timer: float = 0.0
var camp_support_timer: float = 0.0
var central_supply_timer: float = 0.0
var survival_relief_timer: float = 0.0
var zone_logic_accumulator: float = 0.0
var run_modules: Dictionary = {}
var run_module_count: int = 0
# V44.38 — événements de monde temporaires. Ils restent facultatifs et n'interrompent jamais une vague.
var dynamic_event_active: bool = false
var dynamic_event_kind: String = ""
var dynamic_event_position: Vector2 = Vector2.ZERO
var dynamic_event_started: bool = false
var dynamic_event_progress: float = 0.0
var dynamic_event_target: float = 1.0
var dynamic_event_spawn_timer: float = 0.0
var dynamic_event_age: float = 0.0
var dynamic_event_serial: int = 0
var dynamic_event_kills: int = 0
var dynamic_event_target_kills: int = 0
# V44.42 — SURCHARGE reste un bonus temporaire non destructif : les stats de base ne sont jamais modifiées.
var skill_traction_cooldown_timer: float = 0.0
var skill_surge_timer: float = 0.0
var skill_surge_cooldown_timer: float = 0.0
var skill_surge_fx_timer: float = 0.0
var loot_discovered: Dictionary = {}
var boss_signatures: Dictionary = {}
var canyon_secrets: Dictionary = {}
var canyon_mastery: bool = false
var overdrive_bar: ProgressBar
var overdrive_label: Label
var fragment_label: Label
var zone_banner_panel: Panel
var zone_banner_label: Label
var zone_banner_subtitle_label: Label
var zone_mood_overlay: ColorRect
var rift_overlay: ColorRect
const MAX_ACTIVE_ENEMIES: int = 18
const MAX_ACTIVE_PROJECTILES: int = 40
const MAX_ACTIVE_FX: int = 30
const HUD_REFRESH_INTERVAL: float = 0.11
const QUALITY_LOW: int = 0
const QUALITY_BALANCED: int = 1
const QUALITY_HIGH: int = 2

var best_kills: int = 0
var best_level: int = 1
var best_time: float = 0.0
var meta_damage_rank: int = 0
var meta_health_rank: int = 0
var meta_instinct_rank: int = 0
var meta_fury_rank: int = 0
var meta_resilience_rank: int = 0
var meta_scavenger_rank: int = 0
var meta_marauder_node: bool = false
var meta_sentinel_node: bool = false
var meta_archon_node: bool = false
var boss_encounters: Dictionary = {}
var boss_defeats: Dictionary = {}
var saved_run: Dictionary = {}

var sfx_players: Array[AudioStreamPlayer] = []
var sfx_cursor: int = 0
var hud_refresh_timer: float = 0.0
var haptic_cooldown: float = 0.0
var autosave_timer: float = AUTOSAVE_INTERVAL
var adaptive_quality: int = QUALITY_BALANCED
var performance_sample_timer: float = 1.0
var low_fps_streak: int = 0
var high_fps_streak: int = 0
var lifecycle_poll_timer: float = 0.25
var web_lifecycle_hidden: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_input_actions()
	rng.randomize()
	_init_mobile_optimization()
	_load_profile()
	_build_world_roots()
	_build_audio()
	_build_ui()
	get_viewport().size_changed.connect(_update_responsive_layout)
	_update_responsive_layout()
	_show_menu()

func _notification(what: int) -> void:
	# Mobile/web lifecycle safety: persist profile and never let a run continue in background.
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		_save_profile()
		if state == State.PLAYING and not upgrade_pending:
			_toggle_pause()
	elif what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_profile()
		get_tree().quit()

func _init_mobile_optimization() -> void:
	adaptive_quality = QUALITY_BALANCED if OS.has_feature("web") or OS.has_feature("mobile") else QUALITY_HIGH
	if OS.has_feature("web"):
		JavaScriptBridge.eval("""(function(){
  if (window.__nomadLifecycleInstalled) return;
  window.__nomadLifecycleInstalled = true;
  window.__nomadHidden = !!document.hidden;
  document.addEventListener('visibilitychange', function(){ window.__nomadHidden = !!document.hidden; });
  window.addEventListener('pagehide', function(){ window.__nomadHidden = true; });
  window.addEventListener('pageshow', function(){ window.__nomadHidden = !!document.hidden; });
})()""")

func _update_mobile_lifecycle(delta: float) -> void:
	if not OS.has_feature("web"):
		return
	lifecycle_poll_timer -= delta
	if lifecycle_poll_timer > 0.0:
		return
	lifecycle_poll_timer = 0.25
	var hidden: bool = bool(JavaScriptBridge.eval("!!window.__nomadHidden"))
	if hidden and not web_lifecycle_hidden:
		web_lifecycle_hidden = true
		_save_profile()
		if state == State.PLAYING and not upgrade_pending:
			_toggle_pause()
	elif not hidden and web_lifecycle_hidden:
		web_lifecycle_hidden = false

func _update_adaptive_quality(delta: float) -> void:
	if state != State.PLAYING or rotation_blocked or upgrade_pending:
		performance_sample_timer = 1.0
		return
	performance_sample_timer -= delta
	if performance_sample_timer > 0.0:
		return
	performance_sample_timer = 1.0
	var fps: float = float(Engine.get_frames_per_second())
	if fps <= 1.0:
		return
	if fps < 48.0:
		low_fps_streak += 1
		high_fps_streak = 0
	elif fps >= 57.0:
		high_fps_streak += 1
		low_fps_streak = maxi(0, low_fps_streak - 1)
	else:
		low_fps_streak = maxi(0, low_fps_streak - 1)
		high_fps_streak = maxi(0, high_fps_streak - 1)
	if low_fps_streak >= 3 and adaptive_quality > QUALITY_LOW:
		adaptive_quality -= 1
		low_fps_streak = 0
		high_fps_streak = 0
		_apply_enemy_visual_quality()
	elif high_fps_streak >= 9 and adaptive_quality < QUALITY_HIGH:
		adaptive_quality += 1
		low_fps_streak = 0
		high_fps_streak = 0
		_apply_enemy_visual_quality()

func _apply_enemy_visual_quality() -> void:
	if enemies_root == null:
		return
	for node: Node in enemies_root.get_children():
		var enemy: NomadEnemy = node as NomadEnemy
		if enemy != null and enemy.has_method("set_visual_quality"):
			enemy.set_visual_quality(adaptive_quality)

func _fx_budget() -> int:
	if adaptive_quality == QUALITY_LOW:
		return 12
	if adaptive_quality == QUALITY_BALANCED:
		return 20
	return MAX_ACTIVE_FX

func _hud_refresh_interval() -> float:
	if adaptive_quality == QUALITY_LOW:
		return 0.16
	if adaptive_quality == QUALITY_BALANCED:
		return 0.13
	return HUD_REFRESH_INTERVAL

func _copy_file_bytes(source_path: String, destination_path: String) -> bool:
	var source: FileAccess = FileAccess.open(source_path, FileAccess.READ)
	if source == null or source.get_length() <= 0 or source.get_length() > BACKUP_MAX_BYTES:
		return false
	var payload: PackedByteArray = source.get_buffer(source.get_length())
	if payload.is_empty():
		return false
	var destination: FileAccess = FileAccess.open(destination_path, FileAccess.WRITE)
	if destination == null:
		return false
	destination.store_buffer(payload)
	destination.flush()
	return true

func _copy_profile_to_backup() -> void:
	_copy_file_bytes(SAVE_PATH, SAVE_BACKUP_PATH)

func _remove_temp_save() -> void:
	if FileAccess.file_exists(SAVE_TEMP_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_TEMP_PATH))

func _write_profile_config_safely(config: ConfigFile) -> Error:
	# V45.0 STABLE : on n'écrase jamais directement le dernier profil valide.
	# 1) écriture temporaire, 2) validation complète, 3) sauvegarde du profil
	# précédent, 4) remplacement, 5) validation du fichier final.
	_remove_temp_save()
	var temp_error: Error = config.save(SAVE_TEMP_PATH)
	if temp_error != OK:
		return temp_error
	var temp_check: ConfigFile = ConfigFile.new()
	if temp_check.load(SAVE_TEMP_PATH) != OK or not _backup_config_is_valid(temp_check):
		_remove_temp_save()
		return ERR_FILE_CORRUPT

	var had_previous_profile: bool = false
	if FileAccess.file_exists(SAVE_PATH):
		var previous_check: ConfigFile = ConfigFile.new()
		if previous_check.load(SAVE_PATH) == OK and _backup_config_is_valid(previous_check):
			had_previous_profile = true
			_copy_profile_to_backup()

	if not _copy_file_bytes(SAVE_TEMP_PATH, SAVE_PATH):
		if FileAccess.file_exists(SAVE_BACKUP_PATH):
			_copy_file_bytes(SAVE_BACKUP_PATH, SAVE_PATH)
		_remove_temp_save()
		return ERR_FILE_CANT_WRITE

	var final_check: ConfigFile = ConfigFile.new()
	if final_check.load(SAVE_PATH) != OK or not _backup_config_is_valid(final_check):
		if FileAccess.file_exists(SAVE_BACKUP_PATH):
			_copy_file_bytes(SAVE_BACKUP_PATH, SAVE_PATH)
		_remove_temp_save()
		return ERR_FILE_CORRUPT

	# Au tout premier enregistrement, créer immédiatement un secours valide.
	if not had_previous_profile:
		_copy_profile_to_backup()
	_remove_temp_save()
	return OK

func _setup_input_actions() -> void:
	var actions: Dictionary = {
		"move_left": [KEY_A, KEY_Q, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_Z, KEY_UP],
		"move_down": [KEY_S, KEY_DOWN],
		"special": [KEY_SPACE],
		"dash": [KEY_SHIFT],
		"traction": [KEY_E],
		"surge": [KEY_R],
		"pause": [KEY_ESCAPE]
	}
	for action_name: String in actions.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
		for keycode_variant: Variant in actions[action_name]:
			var event: InputEventKey = InputEventKey.new()
			event.physical_keycode = int(keycode_variant)
			InputMap.action_add_event(action_name, event)

func _process(delta: float) -> void:
	haptic_cooldown = maxf(0.0, haptic_cooldown - delta)
	_update_mobile_lifecycle(delta)
	_update_adaptive_quality(delta)
	if web_backup_waiting and state == State.MENU:
		web_backup_poll_timer -= delta
		if web_backup_poll_timer <= 0.0:
			web_backup_poll_timer = 0.25
			_poll_web_backup()
	layout_poll_timer -= delta
	if layout_poll_timer <= 0.0:
		layout_poll_timer = 0.25
		_update_responsive_layout()
	if rotation_blocked or upgrade_pending:
		return
	match state:
		State.PLAYING:
			_update_game(delta)
		_:
			pass
	_update_camera_shake(delta)

func _unhandled_input(event: InputEvent) -> void:
	if rotation_blocked or upgrade_pending:
		return
	if state == State.MENU and meta_tree_overlay != null and meta_tree_overlay.visible:
		if event.is_action_pressed("pause"):
			meta_tree_overlay.visible = false
			get_viewport().set_input_as_handled()
		return
	if state == State.MENU and boss_dossier_overlay != null and boss_dossier_overlay.visible:
		if event.is_action_pressed("pause"):
			boss_dossier_overlay.visible = false
			get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("pause"):
		if state == State.PLAYING or state == State.PAUSED:
			_toggle_pause()

func _build_world_roots() -> void:
	world_entities = Node2D.new()
	world_entities.name = "GameWorld"
	world_entities.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(world_entities)

	world = WorldScript.new() as StylizedWorld
	world.name = "StylizedDesert"
	world_entities.add_child(world)
	mission_markers_root = Node2D.new()
	mission_markers_root.name = "ZoneObjectives"
	world_entities.add_child(mission_markers_root)
	_build_zone_objective_markers()
	boss_hazards_root = Node2D.new()
	boss_hazards_root.name = "BossHazards"
	world_entities.add_child(boss_hazards_root)

	enemies_root = Node2D.new()
	enemies_root.name = "Enemies"
	world_entities.add_child(enemies_root)

	projectiles_root = Node2D.new()
	projectiles_root.name = "Projectiles"
	world_entities.add_child(projectiles_root)

	pickups_root = Node2D.new()
	pickups_root.name = "Pickups"
	world_entities.add_child(pickups_root)

	secrets_root = Node2D.new()
	secrets_root.name = "CanyonSecrets"
	world_entities.add_child(secrets_root)

	fx_root = Node2D.new()
	fx_root.name = "Effects"
	world_entities.add_child(fx_root)

	world_entities.visible = false

func _build_audio() -> void:
	var audio_pool_size: int = 4 if OS.has_feature("web") else 6
	for i: int in range(audio_pool_size):
		var audio: AudioStreamPlayer = AudioStreamPlayer.new()
		audio.name = "SFX_%02d" % i
		add_child(audio)
		sfx_players.append(audio)

func _play_sfx(stream: AudioStream, volume_db: float = -10.0, pitch_min: float = 0.98, pitch_max: float = 1.02) -> void:
	if sfx_players.is_empty():
		return
	var audio: AudioStreamPlayer = sfx_players[sfx_cursor % sfx_players.size()]
	sfx_cursor += 1
	audio.stop()
	audio.stream = stream
	audio.volume_db = volume_db
	audio.pitch_scale = rng.randf_range(pitch_min, pitch_max)
	audio.play()

func _haptic(duration_ms: int, amplitude: float = 0.45, cooldown: float = 0.08) -> void:
	if haptic_cooldown > 0.0:
		return
	haptic_cooldown = cooldown
	Input.vibrate_handheld(duration_ms, amplitude)

func _build_ui() -> void:
	ui = CanvasLayer.new()
	ui.name = "UI"
	add_child(ui)
	_build_menu()
	_build_hud()
	_build_upgrade_panel()
	_build_pause()
	_build_game_over()
	_build_rotation_overlay()

func _build_rotation_overlay() -> void:
	rotation_overlay = Control.new()
	rotation_overlay.name = "PaysageRequis"
	rotation_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	rotation_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	ui.add_child(rotation_overlay)
	var backdrop: ColorRect = ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.025, 0.050, 0.068, 1.0)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	rotation_overlay.add_child(backdrop)
	rotation_card = Panel.new()
	rotation_card.add_theme_stylebox_override("panel", _style_panel(Color(0.047, 0.073, 0.085, 1.0), Color(0.37, 0.75, 0.79, 0.82), 24, 16))
	rotation_overlay.add_child(rotation_card)
	rotation_icon = _make_label("↻", Vector2.ZERO, Vector2.ZERO, 84, Color("79deea"), HORIZONTAL_ALIGNMENT_CENTER)
	rotation_card.add_child(rotation_icon)
	rotation_title = _make_label("MODE PAYSAGE", Vector2.ZERO, Vector2.ZERO, 25, Color("f6d6aa"), HORIZONTAL_ALIGNMENT_CENTER)
	rotation_card.add_child(rotation_title)
	rotation_hint = _make_label("Tourne ton téléphone pour jouer.\nDéverrouille la rotation si besoin.", Vector2.ZERO, Vector2.ZERO, 15, Color("b5d3d8"), HORIZONTAL_ALIGNMENT_CENTER)
	rotation_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rotation_card.add_child(rotation_hint)
	rotation_overlay.visible = false

func _refresh_rotation_guard(viewport_size: Vector2) -> void:
	rotation_overlay.position = Vector2.ZERO
	rotation_overlay.scale = Vector2.ONE
	rotation_overlay.size = viewport_size
	var card_size: Vector2 = Vector2(minf(420.0, viewport_size.x - 32.0), minf(300.0, viewport_size.y - 32.0))
	rotation_card.position = (viewport_size - card_size) * 0.5
	rotation_card.size = card_size
	rotation_icon.position = Vector2(16.0, 24.0)
	rotation_icon.size = Vector2(card_size.x - 32.0, 110.0)
	rotation_title.position = Vector2(16.0, 154.0)
	rotation_title.size = Vector2(card_size.x - 32.0, 46.0)
	rotation_hint.position = Vector2(16.0, 210.0)
	rotation_hint.size = Vector2(card_size.x - 32.0, 62.0)
	var portrait: bool = viewport_size.y >= viewport_size.x
	if OS.has_feature("web"):
		var browser_portrait: Variant = JavaScriptBridge.eval("window.matchMedia('(orientation: portrait)').matches")
		if typeof(browser_portrait) == TYPE_BOOL:
			portrait = portrait or bool(browser_portrait)
	rotation_overlay.visible = portrait
	if portrait == rotation_blocked:
		return
	rotation_blocked = portrait
	if portrait:
		if state == State.PLAYING:
			_save_profile()
		joystick.reset()
		joystick.enabled = false
		world_entities.process_mode = Node.PROCESS_MODE_DISABLED
	elif state == State.PLAYING and not upgrade_pending and not get_tree().paused:
		world_entities.process_mode = Node.PROCESS_MODE_PAUSABLE
		joystick.enabled = true

func _browser_safe_insets(viewport_size: Vector2) -> Vector4:
	if not OS.has_feature("web"):
		return Vector4.ZERO
	var result: Variant = JavaScriptBridge.eval(SAFE_AREA_JS)
	if typeof(result) != TYPE_STRING:
		return Vector4.ZERO
	var parsed: Variant = JSON.parse_string(String(result))
	if typeof(parsed) != TYPE_ARRAY:
		return Vector4.ZERO
	var values: Array = parsed as Array
	if values.size() < 7:
		return Vector4.ZERO
	var browser_width: float = maxf(1.0, float(values[4]))
	var browser_height: float = maxf(1.0, float(values[5]))
	var left: float = maxf(0.0, float(values[0]))
	var top: float = maxf(0.0, float(values[1]))
	var right: float = maxf(0.0, float(values[2]))
	var bottom: float = maxf(0.0, float(values[3]))
	# Safari peut renvoyer 0 dans une PWA. Sur iPhone paysage, garder
	# une marge conservatrice des deux côtés du Dynamic Island.
	if int(values[6]) == 1 and browser_width > browser_height:
		left = maxf(left, 60.0)
		right = maxf(right, 60.0)
	var sx: float = viewport_size.x / browser_width
	var sy: float = viewport_size.y / browser_height
	return Vector4(
		minf(left * sx, viewport_size.x * 0.2),
		minf(top * sy, viewport_size.y * 0.2),
		minf(right * sx, viewport_size.x * 0.2),
		minf(bottom * sy, viewport_size.y * 0.2)
	)

func _update_responsive_layout() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	_refresh_rotation_guard(viewport_size)
	var insets: Vector4 = _browser_safe_insets(viewport_size)
	if viewport_size == last_layout_viewport and insets == last_layout_insets:
		return
	last_layout_viewport = viewport_size
	last_layout_insets = insets
	var safe_size: Vector2 = viewport_size - Vector2(insets.x + insets.z, insets.y + insets.w)
	var ui_scale: float = maxf(0.01, minf(safe_size.x / VIEW.x, safe_size.y / VIEW.y))
	var ui_offset: Vector2 = Vector2(insets.x, insets.y) + (safe_size - VIEW * ui_scale) * 0.5
	menu_compact = ui_scale < 0.78
	if backup_export_button != null:
		backup_export_button.add_theme_font_size_override("font_size", 20 if menu_compact else 15)
		backup_import_button.add_theme_font_size_override("font_size", 16 if not pending_backup_text.is_empty() else (20 if menu_compact else 15))
		backup_status_label.add_theme_font_size_override("font_size", 16 if menu_compact else 11)
		_layout_menu_profile()
	_update_meta_buttons()
	if joystick != null and joystick.active:
		joystick.reset()
	for screen: Control in [menu, hud, upgrade_panel, pause_panel, game_over]:
		screen.position = ui_offset
		screen.scale = Vector2.ONE * ui_scale
	if boss_dossier_overlay != null:
		boss_dossier_overlay.position = Vector2.ZERO
		boss_dossier_overlay.scale = Vector2.ONE
		boss_dossier_overlay.size = viewport_size
		boss_dossier_veil.size = viewport_size
		var dossier_scale: float = maxf(0.01, minf(1.14, minf(safe_size.x / 1064.0, safe_size.y / 608.0)))
		boss_dossier_card.scale = Vector2.ONE * dossier_scale
		boss_dossier_card.position = Vector2(insets.x, insets.y) + (safe_size - boss_dossier_card.size * dossier_scale) * 0.5
	if meta_tree_overlay != null:
		meta_tree_overlay.position = Vector2.ZERO
		meta_tree_overlay.scale = Vector2.ONE
		meta_tree_overlay.size = viewport_size
		meta_tree_veil.size = viewport_size
		var tree_scale: float = maxf(0.01, minf(1.08, minf(safe_size.x / 1144.0, safe_size.y / 634.0)))
		meta_tree_card.scale = Vector2.ONE * tree_scale
		meta_tree_card.position = Vector2(insets.x, insets.y) + (safe_size - meta_tree_card.size * tree_scale) * 0.5
	# Le HUD possède sa propre grille : les textes et les touches restent lisibles
	# dans la zone sûre même quand le menu doit être réduit pour tenir en entier.
	var hud_scale: float = maxf(0.01, minf(1.0, minf(safe_size.x / 728.0, safe_size.y / 420.0)))
	hud.position = Vector2(insets.x, insets.y)
	hud.scale = Vector2.ONE * hud_scale
	hud.size = safe_size / hud_scale
	_layout_hud(hud.size, hud_scale)
	# Les fonds et les voiles débordent la zone sûre : pas de bandes noires.
	for backdrop: Control in full_bleed_controls:
		var owner: Control = backdrop.get_parent() as Control
		var backdrop_scale: float = owner.scale.x if owner != null else ui_scale
		var backdrop_offset: Vector2 = owner.position if owner != null else ui_offset
		backdrop.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		backdrop.position = -backdrop_offset / backdrop_scale
		backdrop.size = viewport_size / backdrop_scale

func _layout_hud(space: Vector2, scale_value: float) -> void:
	if hud_status == null or hud_wave_panel == null or hud_info_panel == null or hud_pause_button == null:
		return
	var edge: float = 10.0
	var gap: float = 8.0
	var status_width: float = clampf(space.x * 0.30, 268.0, 360.0)
	var info_width: float = clampf(space.x * 0.18, 154.0, 220.0)
	var pause_width: float = clampf(48.0 / scale_value, 48.0, 62.0)
	var wave_width: float = minf(320.0, maxf(150.0, space.x - edge * 2.0 - gap * 3.0 - status_width - info_width - pause_width))
	var info_x: float = space.x - edge - pause_width - gap - info_width
	var wave_x: float = clampf((space.x - wave_width) * 0.5, edge + status_width + gap, info_x - gap - wave_width)

	# Bloc joueur : compact et lisible, sans énorme cadre qui masque le décor.
	hud_status.position = Vector2(edge, 12.0)
	hud_status.size = Vector2(status_width, 108.0)
	hud_name_label.position = Vector2(14.0, 7.0)
	hud_name_label.size = Vector2(status_width - 124.0, 23.0)
	hud_name_label.add_theme_font_size_override("font_size", maxi(16, ceili(10.5 / scale_value)))
	level_label.position = Vector2(status_width - 108.0, 7.0)
	level_label.size = Vector2(94.0, 23.0)
	level_label.add_theme_font_size_override("font_size", maxi(15, ceili(10.5 / scale_value)))
	hud_health_caption.position = Vector2(14.0, 35.0)
	hud_health_caption.size = Vector2(44.0, 18.0)
	hud_health_caption.add_theme_font_size_override("font_size", maxi(11, ceili(9.0 / scale_value)))
	var bar_width: float = status_width - 28.0
	for control: Control in [health_bar, hp_label]:
		control.position = Vector2(14.0, 52.0)
		control.size = Vector2(bar_width, 24.0)
	hp_label.add_theme_font_size_override("font_size", maxi(14, ceili(10.0 / scale_value)))
	hud_xp_caption.position = Vector2(14.0, 82.0)
	hud_xp_caption.size = Vector2(38.0, 16.0)
	hud_xp_caption.add_theme_font_size_override("font_size", maxi(10, ceili(8.5 / scale_value)))
	for control: Control in [xp_bar, xp_label]:
		control.position = Vector2(54.0, 84.0)
		control.size = Vector2(status_width - 68.0, 14.0)
	xp_label.add_theme_font_size_override("font_size", maxi(10, ceili(8.0 / scale_value)))

	# Centre : une seule lecture principale, la vague. Le boss n'apparaît que si nécessaire.
	hud_wave_panel.position = Vector2(wave_x, 12.0)
	hud_wave_panel.size = Vector2(wave_width, 48.0)
	event_label.position = Vector2(6.0, 5.0)
	event_label.size = Vector2(wave_width - 12.0, 38.0)
	event_label.add_theme_font_size_override("font_size", maxi(17, ceili(10.5 / scale_value)) if wave_width < 216.0 else 20)
	boss_label.position = Vector2(wave_x, 64.0)
	boss_label.size = Vector2(wave_width, 22.0)
	boss_label.add_theme_font_size_override("font_size", 11 if wave_width < 216.0 else 13)
	boss_bar.position = Vector2(wave_x + 12.0, 88.0)
	boss_bar.size = Vector2(wave_width - 24.0, 9.0)
	boss_move_label.position = Vector2(wave_x, 101.0)
	boss_move_label.size = Vector2(wave_width, 24.0)
	boss_move_label.add_theme_font_size_override("font_size", 11 if wave_width < 216.0 else 13)

	# Stats : trois informations, rien de plus.
	hud_info_panel.position = Vector2(info_x, 12.0)
	hud_info_panel.size = Vector2(info_width, 74.0)
	kills_label.position = Vector2(12.0, 7.0)
	kills_label.size = Vector2(info_width * 0.50 - 14.0, 27.0)
	kills_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	kills_label.add_theme_font_size_override("font_size", maxi(17, ceili(11.0 / scale_value)))
	time_label.position = Vector2(info_width * 0.50, 7.0)
	time_label.size = Vector2(info_width * 0.50 - 12.0, 27.0)
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	time_label.add_theme_font_size_override("font_size", maxi(15, ceili(10.0 / scale_value)))
	fragment_label.position = Vector2(10.0, 39.0)
	fragment_label.size = Vector2(info_width - 20.0, 23.0)
	fragment_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fragment_label.add_theme_font_size_override("font_size", maxi(12, ceili(9.5 / scale_value)))

	hud_pause_button.position = Vector2(space.x - edge - pause_width, 12.0)
	hud_pause_button.size = Vector2(pause_width, maxf(50.0, 47.0 / scale_value))
	hud_pause_button.add_theme_font_size_override("font_size", maxi(19, ceili(12.0 / scale_value)))

	# Bas d'écran : uniquement contexte utile. Aucune description permanente de doctrine.
	zone_label.position = Vector2(edge, space.y - 32.0)
	zone_label.size = Vector2(minf(250.0, space.x * 0.28), 22.0)
	zone_label.add_theme_font_size_override("font_size", maxi(12, ceili(9.5 / scale_value)))
	danger_label.position = Vector2(edge, space.y - 58.0)
	danger_label.size = Vector2(minf(360.0, space.x * 0.34), 24.0)
	danger_label.add_theme_font_size_override("font_size", maxi(12, ceili(9.5 / scale_value)))
	if zone_banner_panel != null:
		var banner_width: float = minf(520.0, maxf(260.0, space.x * 0.42))
		zone_banner_panel.position = Vector2((space.x - banner_width) * 0.5, space.y - 148.0)
		zone_banner_panel.size = Vector2(banner_width, 58.0)
		zone_banner_label.position = Vector2(18.0, 8.0)
		zone_banner_label.size = Vector2(banner_width - 36.0, 26.0)
		zone_banner_label.add_theme_font_size_override("font_size", 16 if banner_width < 340.0 else 18)
		zone_banner_subtitle_label.position = Vector2(18.0, 34.0)
		zone_banner_subtitle_label.size = Vector2(banner_width - 36.0, 16.0)
		zone_banner_subtitle_label.add_theme_font_size_override("font_size", 10 if banner_width < 340.0 else 11)
	if threat_label != null:
		var threat_width: float = minf(400.0, maxf(220.0, space.x * 0.34))
		threat_label.position = Vector2((space.x - threat_width) * 0.5, space.y - 86.0)
		threat_label.size = Vector2(threat_width, 28.0)
		threat_label.add_theme_font_size_override("font_size", maxi(13, ceili(10.0 / scale_value)))

	toast_label.position = Vector2((space.x - minf(560.0, space.x - 28.0)) * 0.5, 136.0)
	toast_label.size = Vector2(minf(560.0, space.x - 28.0), 40.0)
	toast_label.add_theme_font_size_override("font_size", maxi(17, ceili(11.0 / scale_value)))
	combo_label.position = Vector2((space.x - minf(340.0, space.x - 28.0)) * 0.5, 174.0)
	combo_label.size = Vector2(minf(340.0, space.x - 28.0), 30.0)
	combo_label.add_theme_font_size_override("font_size", maxi(15, ceili(10.0 / scale_value)))

	if presentation_overlay != null:
		presentation_overlay.size = space
		presentation_veil.size = space
		presentation_top_bar.size = Vector2(space.x, 46.0)
		presentation_bottom_bar.size = Vector2(space.x, 46.0)
		var presentation_width: float = minf(680.0, space.x - 30.0)
		presentation_card.size = Vector2(presentation_width, 130.0)
		presentation_accent.size.y = 94.0
		presentation_title.position = Vector2(38.0, 20.0)
		presentation_title.size = Vector2(presentation_width - 66.0, 48.0)
		presentation_subtitle.position = Vector2(38.0, 72.0)
		presentation_subtitle.size = Vector2(presentation_width - 66.0, 30.0)
		presentation_title.add_theme_font_size_override("font_size", 32 if presentation_width < 620.0 else 36)
		presentation_subtitle.add_theme_font_size_override("font_size", 14 if presentation_width < 620.0 else 16)
		presentation_card.position = Vector2((space.x - presentation_width) * 0.5, (space.y - 130.0) * 0.5)
	if loot_banner_panel != null:
		var loot_width: float = minf(440.0, space.x - 30.0)
		loot_banner_panel.size = Vector2(loot_width, 70.0)
		loot_banner_rarity.position = Vector2(16.0, 7.0)
		loot_banner_rarity.size = Vector2(loot_width - 32.0, 17.0)
		loot_banner_name.position = Vector2(16.0, 23.0)
		loot_banner_name.size = Vector2(loot_width - 32.0, 27.0)
		loot_banner_hint.position = Vector2(16.0, 50.0)
		loot_banner_hint.size = Vector2(loot_width - 32.0, 15.0)
		loot_banner_panel.position = Vector2((space.x - loot_width) * 0.5, maxf(230.0, space.y - 118.0))
	joystick.size = space

func _layout_menu_profile() -> void:
	if menu_portrait_frame == null or menu_meta_title == null:
		return
	# V44.45c : un seul appel à l'action pour la Matrice. Les trois anciens
	# boutons ouvraient exactement le même écran et créaient du bruit visuel.
	menu_portrait_frame.position = Vector2(24.0, 88.0)
	menu_portrait_frame.size = Vector2(394.0, 190.0)
	menu_hero_floor.position = Vector2(22.0, 154.0)
	menu_hero_floor.size = Vector2(350.0, 24.0)
	menu_hero_stand.position = Vector2(103.0, -8.0)
	menu_hero_stand.size = Vector2(188.0, 188.0)
	menu_meta_title.position = Vector2(0.0, 292.0)
	menu_meta_title.size = Vector2(442.0, 24.0)
	if menu_meta_summary_label != null:
		menu_meta_summary_label.position = Vector2(22.0, 322.0)
		menu_meta_summary_label.size = Vector2(398.0, 42.0)

	# Un unique bouton plein format : aucune superposition possible.
	meta_damage_button.position = Vector2(22.0, 372.0)
	meta_damage_button.size = Vector2(398.0, 62.0)
	meta_health_button.visible = false
	meta_instinct_button.visible = false

	backup_export_button.position = Vector2(22.0, 458.0)
	backup_import_button.position = Vector2(226.0, 458.0)
	backup_export_button.size = Vector2(194.0, 48.0)
	backup_import_button.size = Vector2(194.0, 48.0)
	backup_status_label.position = Vector2(20.0, 520.0)
	backup_status_label.size = Vector2(402.0, 34.0)

func _style_panel(color: Color, border: Color, radius: int = 18, shadow_size: int = 10) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.22)
	style.shadow_size = mini(shadow_size, 10)
	style.shadow_offset = Vector2(0.0, 4.0)
	style.anti_aliasing = true
	return style

func _make_label(text_value: String, pos: Vector2, size_value: Vector2, font_size: int, color: Color, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label: Label = Label.new()
	label.text = text_value
	label.position = pos
	label.size = size_value
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.03, 0.04, 0.05, 0.62))
	label.add_theme_constant_override("outline_size", 1)
	return label

func _make_button(text_value: String, pos: Vector2, size_value: Vector2, primary: bool = false) -> Button:
	var button: Button = Button.new()
	button.text = text_value
	button.position = pos
	button.size = size_value
	button.add_theme_font_size_override("font_size", 22 if primary else 17)
	button.add_theme_color_override("font_color", Color("f6f3e9"))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	var normal: StyleBoxFlat = _style_panel(Color(0.050, 0.060, 0.066, 0.97) if not primary else Color(0.23, 0.16, 0.105, 0.99), Color(0.34, 0.49, 0.52, 0.70) if not primary else Color(0.76, 0.49, 0.27, 0.92), 15)
	var hover: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.075, 0.095, 0.102, 0.99) if not primary else Color(0.31, 0.20, 0.12, 1.0)
	hover.border_color = Color(0.55, 0.76, 0.78, 0.95) if not primary else Color(0.90, 0.66, 0.38, 0.96)
	var pressed: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.035, 0.043, 0.048, 1.0) if not primary else Color(0.18, 0.115, 0.075, 1.0)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.pressed.connect(_on_ui_click)
	return button

func _build_menu() -> void:
	menu = Control.new()
	menu.size = VIEW
	ui.add_child(menu)

	# Fond global uniquement : aucun visuel ne vient traverser les cartes UI.
	var background: TextureRect = TextureRect.new()
	background.texture = MAP_TEXTURE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.modulate = Color(0.72, 0.69, 0.64, 1.0)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu.add_child(background)
	full_bleed_controls.append(background)

	var grade: TextureRect = TextureRect.new()
	grade.texture = SCREEN_GRADE_TEXTURE
	grade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	grade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	grade.stretch_mode = TextureRect.STRETCH_SCALE
	grade.modulate = Color(1.0, 1.0, 1.0, 0.68)
	grade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu.add_child(grade)
	full_bleed_controls.append(grade)

	var scrim: ColorRect = ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.012, 0.017, 0.020, 0.66)
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu.add_child(scrim)
	full_bleed_controls.append(scrim)

	# ----- COLONNE GAUCHE : identité, record, jouer -----
	var main_card: Panel = Panel.new()
	main_card.position = Vector2(46.0, 48.0)
	main_card.size = Vector2(720.0, 624.0)
	main_card.add_theme_stylebox_override("panel", _style_panel(Color(0.018, 0.026, 0.031, 0.965), Color(0.98, 0.62, 0.24, 0.72), 30, 18))
	menu.add_child(main_card)

	var header_box: Panel = Panel.new()
	header_box.position = Vector2(26.0, 26.0)
	header_box.size = Vector2(668.0, 166.0)
	header_box.add_theme_stylebox_override("panel", _style_panel(Color(0.026, 0.035, 0.041, 0.98), Color(0.96, 0.57, 0.22, 0.20), 22, 3))
	main_card.add_child(header_box)

	header_box.add_child(_make_label("NØMAD ZERO", Vector2(0.0, 18.0), Vector2(668.0, 60.0), 46, Color("fff0d5"), HORIZONTAL_ALIGNMENT_CENTER))
	header_box.add_child(_make_label("SURVIS AU RIFT", Vector2(0.0, 80.0), Vector2(668.0, 26.0), 19, Color("79e7f7"), HORIZONTAL_ALIGNMENT_CENTER))
	var subtitle: Label = _make_label("Chaque expédition te rend plus fort. Récolte des fragments et améliore ton opérateur.", Vector2(42.0, 114.0), Vector2(584.0, 38.0), 12, Color("c7d1cf"), HORIZONTAL_ALIGNMENT_CENTER)
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	header_box.add_child(subtitle)

	var record_panel: Panel = Panel.new()
	record_panel.position = Vector2(26.0, 208.0)
	record_panel.size = Vector2(668.0, 108.0)
	record_panel.add_theme_stylebox_override("panel", _style_panel(Color(0.038, 0.050, 0.057, 0.93), Color(0.27, 0.72, 0.80, 0.36), 18, 4))
	main_card.add_child(record_panel)
	record_panel.add_child(_make_label("MEILLEURE EXPÉDITION", Vector2(22.0, 16.0), Vector2(624.0, 22.0), 13, Color("91a5aa"), HORIZONTAL_ALIGNMENT_LEFT))
	menu_best_label = _make_label("", Vector2(22.0, 46.0), Vector2(624.0, 38.0), 20, Color("f0e7d8"), HORIZONTAL_ALIGNMENT_LEFT)
	menu_best_label.size.x = 386.0
	record_panel.add_child(menu_best_label)
	var dossier_button: Button = _make_button("DOSSIER BOSS", Vector2(440.0, 44.0), Vector2(204.0, 50.0), false)
	dossier_button.add_theme_font_size_override("font_size", 17)
	dossier_button.pressed.connect(_open_boss_dossier)
	record_panel.add_child(dossier_button)

	resume_button = _make_button("CONTINUER", Vector2(26.0, 340.0), Vector2(668.0, 72.0), true)
	resume_button.visible = false
	resume_button.add_theme_font_size_override("font_size", 26)
	resume_button.pressed.connect(_resume_saved_run)
	main_card.add_child(resume_button)

	new_run_button = _make_button("JOUER", Vector2(26.0, 356.0), Vector2(668.0, 126.0), true)
	new_run_button.add_theme_font_size_override("font_size", 36)
	new_run_button.pressed.connect(_start_run)
	main_card.add_child(new_run_button)

	menu_run_hint = _make_label("Nouvelle expédition", Vector2(26.0, 508.0), Vector2(668.0, 28.0), 12, Color("aeb8b5"), HORIZONTAL_ALIGNMENT_CENTER)
	main_card.add_child(menu_run_hint)

	# ----- COLONNE DROITE : opérateur, fragments, améliorations -----
	var profile_card: Panel = Panel.new()
	profile_card.position = Vector2(792.0, 48.0)
	profile_card.size = Vector2(442.0, 624.0)
	profile_card.add_theme_stylebox_override("panel", _style_panel(Color(0.020, 0.029, 0.035, 0.97), Color(0.34, 0.74, 0.82, 0.58), 30, 18))
	menu.add_child(profile_card)

	profile_card.add_child(_make_label("OPÉRATEUR NØ", Vector2(24.0, 22.0), Vector2(210.0, 34.0), 24, Color("fff0d5"), HORIZONTAL_ALIGNMENT_LEFT))

	var fragment_panel: Panel = Panel.new()
	fragment_panel.position = Vector2(244.0, 18.0)
	fragment_panel.size = Vector2(174.0, 58.0)
	fragment_panel.add_theme_stylebox_override("panel", _style_panel(Color(0.065, 0.048, 0.090, 0.95), Color(0.69, 0.49, 0.96, 0.58), 14, 3))
	profile_card.add_child(fragment_panel)
	fragment_panel.add_child(_make_label("FRAGMENTS", Vector2(12.0, 6.0), Vector2(150.0, 16.0), 10, Color("bca8d9"), HORIZONTAL_ALIGNMENT_CENTER))
	menu_fragment_label = _make_label("0", Vector2(12.0, 23.0), Vector2(150.0, 26.0), 22, Color("e5ceff"), HORIZONTAL_ALIGNMENT_CENTER)
	fragment_panel.add_child(menu_fragment_label)

	menu_portrait_frame = Panel.new()
	menu_portrait_frame.position = Vector2(24.0, 88.0)
	menu_portrait_frame.size = Vector2(394.0, 190.0)
	menu_portrait_frame.clip_contents = true
	menu_portrait_frame.add_theme_stylebox_override("panel", _style_panel(Color(0.014, 0.020, 0.026, 0.98), Color(0.28, 0.48, 0.54, 0.22), 20, 2))
	profile_card.add_child(menu_portrait_frame)

	menu_hero_floor = ColorRect.new()
	menu_hero_floor.position = Vector2(22.0, 154.0)
	menu_hero_floor.size = Vector2(350.0, 24.0)
	menu_hero_floor.color = Color(0.08, 0.13, 0.16, 0.46)
	menu_hero_floor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu_portrait_frame.add_child(menu_hero_floor)

	menu_hero_stand = TextureRect.new()
	menu_hero_stand.texture = HERO_PREVIEW
	menu_hero_stand.position = Vector2(103.0, -8.0)
	menu_hero_stand.size = Vector2(188.0, 188.0)
	menu_hero_stand.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	menu_hero_stand.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	menu_hero_stand.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	menu_portrait_frame.add_child(menu_hero_stand)

	menu_meta_title = _make_label("AMÉLIORATIONS PERMANENTES", Vector2(0.0, 292.0), Vector2(442.0, 24.0), 15, Color("d9c2ff"), HORIZONTAL_ALIGNMENT_CENTER)
	profile_card.add_child(menu_meta_title)

	menu_meta_summary_label = _make_label("", Vector2(22.0, 322.0), Vector2(398.0, 42.0), 13, Color("c5ced0"), HORIZONTAL_ALIGNMENT_CENTER)
	menu_meta_summary_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	profile_card.add_child(menu_meta_summary_label)

	# V44.45c : un seul bouton ouvre la Matrice. Les rangs sont affichés au-dessus.
	meta_damage_button = _make_button("OUVRIR LA MATRICE", Vector2(22.0, 372.0), Vector2(398.0, 62.0), true)
	meta_damage_button.add_theme_font_size_override("font_size", 20)
	meta_damage_button.pressed.connect(_open_meta_tree)
	profile_card.add_child(meta_damage_button)
	# Variables conservées pour compatibilité avec le reste du script, mais ces boutons
	# ne sont plus affichés sur l'accueil.
	meta_health_button = _make_button("", Vector2.ZERO, Vector2.ZERO, false)
	meta_health_button.visible = false
	profile_card.add_child(meta_health_button)
	meta_instinct_button = _make_button("", Vector2.ZERO, Vector2.ZERO, false)
	meta_instinct_button.visible = false
	profile_card.add_child(meta_instinct_button)

	backup_export_button = _make_button("EXPORTER", Vector2(22.0, 458.0), Vector2(194.0, 48.0), false)
	backup_export_button.add_theme_font_size_override("font_size", 15)
	backup_export_button.pressed.connect(_export_backup_pressed)
	profile_card.add_child(backup_export_button)
	backup_import_button = _make_button("IMPORTER", Vector2(226.0, 458.0), Vector2(194.0, 48.0), false)
	backup_import_button.add_theme_font_size_override("font_size", 15)
	backup_import_button.pressed.connect(_import_backup_pressed)
	profile_card.add_child(backup_import_button)
	backup_status_label = _make_label("Sauvegarde locale : export et restauration", Vector2(20.0, 520.0), Vector2(402.0, 34.0), 11, Color("a5b6ba"), HORIZONTAL_ALIGNMENT_CENTER)
	profile_card.add_child(backup_status_label)
	var stable_build_label: Label = _make_label(BUILD_NAME, Vector2(20.0, 572.0), Vector2(402.0, 22.0), 11, Color("6f8f94"), HORIZONTAL_ALIGNMENT_CENTER)
	stable_build_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	profile_card.add_child(stable_build_label)
	_build_boss_dossier()
	_build_meta_tree()

func _build_boss_dossier() -> void:
	boss_dossier_overlay = Control.new()
	boss_dossier_overlay.size = VIEW
	boss_dossier_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	ui.add_child(boss_dossier_overlay)
	boss_dossier_veil = ColorRect.new()
	boss_dossier_veil.color = Color(0.006, 0.011, 0.017, 0.94)
	boss_dossier_veil.size = VIEW
	boss_dossier_veil.mouse_filter = Control.MOUSE_FILTER_STOP
	boss_dossier_overlay.add_child(boss_dossier_veil)
	boss_dossier_card = Panel.new()
	boss_dossier_card.position = Vector2(120.0, 68.0)
	boss_dossier_card.size = Vector2(1040.0, 584.0)
	boss_dossier_card.add_theme_stylebox_override("panel", _style_panel(Color(0.019, 0.030, 0.038, 0.99), Color("8da3a8"), 22, 8))
	boss_dossier_overlay.add_child(boss_dossier_card)
	var card: Panel = boss_dossier_card
	card.add_child(_make_label("DOSSIER  •  ADVERSAIRES MAJEURS", Vector2(24.0, 14.0), Vector2(780.0, 40.0), 26, Color("fff0d5")))
	card.add_child(_make_label("Chaque rencontre et victoire est conservée dans ton profil.", Vector2(24.0, 61.0), Vector2(765.0, 26.0), 16, Color("b8c9cd")))
	var close_button: Button = _make_button("FERMER", Vector2(844.0, 6.0), Vector2(166.0, 76.0), false)
	close_button.pressed.connect(_close_boss_dossier)
	card.add_child(close_button)
	var tab_gap: float = 8.0
	var tab_width: float = (992.0 - tab_gap * float(BOSS_KINDS.size() - 1)) / float(BOSS_KINDS.size())
	for index: int in range(BOSS_KINDS.size()):
		var kind: String = BOSS_KINDS[index]
		var tab: Button = _make_button(_boss_name(kind), Vector2(24.0 + float(index) * (tab_width + tab_gap), 102.0), Vector2(tab_width, 64.0), false)
		tab.add_theme_font_size_override("font_size", 9 if BOSS_KINDS.size() >= 7 else (10 if BOSS_KINDS.size() >= 6 else 12))
		tab.pressed.connect(_select_boss_dossier.bind(kind))
		card.add_child(tab)
		boss_dossier_tabs[kind] = tab
	var portrait_panel: Panel = Panel.new()
	portrait_panel.position = Vector2(24.0, 188.0)
	portrait_panel.size = Vector2(354.0, 358.0)
	portrait_panel.add_theme_stylebox_override("panel", _style_panel(Color(0.042, 0.058, 0.069, 0.96), Color("566f73"), 16, 2))
	card.add_child(portrait_panel)
	boss_dossier_portrait = TextureRect.new()
	boss_dossier_portrait.position = Vector2(18.0, 17.0)
	boss_dossier_portrait.size = Vector2(318.0, 318.0)
	boss_dossier_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	boss_dossier_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	boss_dossier_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	boss_dossier_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var cutout: ShaderMaterial = ShaderMaterial.new()
	cutout.shader = BOSS_CUTOUT
	boss_dossier_portrait.material = cutout
	portrait_panel.add_child(boss_dossier_portrait)
	var detail_panel: Panel = Panel.new()
	detail_panel.position = Vector2(399.0, 188.0)
	detail_panel.size = Vector2(616.0, 358.0)
	detail_panel.add_theme_stylebox_override("panel", _style_panel(Color(0.042, 0.058, 0.069, 0.96), Color("566f73"), 16, 2))
	card.add_child(detail_panel)
	boss_dossier_name_label = _make_label("", Vector2(22.0, 10.0), Vector2(574.0, 44.0), 30, Color("fff0d5"))
	detail_panel.add_child(boss_dossier_name_label)
	boss_dossier_wave_label = _make_label("", Vector2(22.0, 57.0), Vector2(574.0, 28.0), 19, Color("cbd7da"))
	detail_panel.add_child(boss_dossier_wave_label)
	detail_panel.add_child(_make_label("SCHÉMAS DE COMBAT", Vector2(22.0, 95.0), Vector2(574.0, 27.0), 17, Color("abbec3")))
	boss_dossier_phase_one_label = _make_label("", Vector2(22.0, 123.0), Vector2(574.0, 30.0), 22, Color("e7edef"))
	detail_panel.add_child(boss_dossier_phase_one_label)
	boss_dossier_phase_two_label = _make_label("", Vector2(22.0, 156.0), Vector2(574.0, 30.0), 22, Color("e7edef"))
	detail_panel.add_child(boss_dossier_phase_two_label)
	boss_dossier_tip_label = _make_label("", Vector2(22.0, 191.0), Vector2(568.0, 57.0), 19, Color("bcdad1"))
	boss_dossier_tip_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_panel.add_child(boss_dossier_tip_label)
	boss_dossier_reward_label = _make_label("", Vector2(22.0, 258.0), Vector2(574.0, 30.0), 21, Color("f5dfa7"))
	detail_panel.add_child(boss_dossier_reward_label)
	boss_dossier_count_label = _make_label("", Vector2(22.0, 308.0), Vector2(574.0, 32.0), 21, Color("e7edef"))
	detail_panel.add_child(boss_dossier_count_label)
	_update_boss_dossier()
	boss_dossier_overlay.visible = false

func _open_boss_dossier() -> void:
	_update_boss_dossier()
	boss_dossier_overlay.visible = true
	_on_ui_click()

func _close_boss_dossier() -> void:
	boss_dossier_overlay.visible = false

func _select_boss_dossier(kind: String) -> void:
	boss_dossier_selected = kind
	_update_boss_dossier()
	_on_ui_click()

func _update_boss_dossier() -> void:
	var profiles: Dictionary = {
		"sentinel": {"wave": "VAGUE 5", "one": "I  •  ÉVENTAIL / TIR PRÉCIS", "two": "II  •  RAILS PARALLÈLES", "tip": "Ses lignes violettes s'arrêtent aux obstacles. Change de couloir.", "reward": "SABRE  +8 DE PORTÉE"},
		"marauder": {"wave": "VAGUE 10", "one": "I  •  IMPACT / CHARGE", "two": "II  •  ENTAILLE CROISÉE", "tip": "Sa percée s'arrête aux obstacles. Évite la trace orange et riposte.", "reward": "DÉGÂTS  +5,5 %"},
		"archon": {"wave": "VAGUE 15", "one": "I  •  RAYON / TROIS ZONES", "two": "II  •  ANNEAU", "tip": "Ses failles verrouillent ta position : quitte les cercles verts.", "reward": "ONDE  RECHARGE -0,22 s"},
		"warden": {"wave": "VAGUE 20", "one": "I  •  GRILLE / SALVE", "two": "II  •  CAGE NULL", "tip": "Lis les trois rails cyan puis coupe leur axe. Sa cage punit les déplacements tardifs.", "reward": "BOUCLIER +18"},
		"reaper": {"wave": "VAGUE 25", "one": "I  •  BOND / FAUCHE", "two": "II  •  ONDE DE CENDRE", "tip": "Ne reste pas à mi-distance : son anneau frappe entre deux zones sûres.", "reward": "CADENCE +4 %"},
		"resonator": {"wave": "CANYON • VAGUES 10/20/30…", "one": "I  •  LIGNES D'ÉCHO / DOUBLE PULSATION", "two": "II  •  EFFONDREMENT RÉSONANT", "tip": "Ses attaques exploitent les couloirs du Canyon. Change de ligne tôt et garde un passage de fuite.", "reward": "ONDE + PORTÉE / RELIQUE ÉCHO"},
		"scrap_titan": {"wave": "CIMETIÈRE • VAGUES 10/20/30…", "one": "I  •  RAILS MAGNÉTIQUES / SALVE DE DÉBRIS", "two": "II  •  ANNEAU BROYEUR", "tip": "Ses rails occupent les allées métalliques. Coupe tôt leur axe et évite la mi-distance en phase II.", "reward": "ARMURE / CŒUR DU TITAN"}
	}
	var kind: String = boss_dossier_selected
	var data: Dictionary = profiles[kind]
	boss_dossier_portrait.texture = BOSS_TEXTURES[kind]
	boss_dossier_portrait.modulate = _boss_portrait_tint(kind)
	boss_dossier_name_label.text = _boss_name(kind)
	boss_dossier_name_label.add_theme_color_override("font_color", _boss_color(kind))
	boss_dossier_wave_label.text = String(data["wave"])
	boss_dossier_phase_one_label.text = String(data["one"])
	boss_dossier_phase_two_label.text = String(data["two"])
	boss_dossier_tip_label.text = String(data["tip"])
	boss_dossier_reward_label.text = String(data["reward"])
	var seen: int = int(boss_encounters.get(kind, 0))
	var defeated: int = int(boss_defeats.get(kind, 0))
	var signature_id: String = _boss_signature_id(kind)
	var signature_status: String = "RELIQUE ✓" if bool(boss_signatures.get(signature_id, false)) else "RELIQUE ?"
	boss_dossier_count_label.text = "À DÉCOUVRIR" if seen <= 0 else "RENCONTRÉ %d   •   VAINCU %d   •   %s" % [seen, defeated, signature_status]
	for boss_kind: String in BOSS_KINDS:
		var tab: Button = boss_dossier_tabs[boss_kind] as Button
		tab.modulate = _boss_color(boss_kind) if boss_kind == kind else Color("a5b4b6")

func _build_meta_tree() -> void:
	meta_tree_overlay = Control.new()
	meta_tree_overlay.name = "MatriceEvolution"
	meta_tree_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	ui.add_child(meta_tree_overlay)
	meta_tree_veil = ColorRect.new()
	meta_tree_veil.color = Color(0.006, 0.011, 0.017, 0.965)
	meta_tree_veil.size = VIEW
	meta_tree_veil.mouse_filter = Control.MOUSE_FILTER_STOP
	meta_tree_overlay.add_child(meta_tree_veil)
	meta_tree_card = Panel.new()
	meta_tree_card.position = Vector2(68.0, 48.0)
	meta_tree_card.size = Vector2(1144.0, 624.0)
	meta_tree_card.add_theme_stylebox_override("panel", _style_panel(Color(0.016, 0.025, 0.032, 0.995), Color(0.44, 0.68, 0.78, 0.72), 24, 12))
	meta_tree_overlay.add_child(meta_tree_card)
	meta_tree_card.add_child(_make_label("MATRICE D’ÉVOLUTION", Vector2(28.0, 18.0), Vector2(720.0, 40.0), 29, Color("fff0d5")))
	meta_tree_card.add_child(_make_label("Les améliorations achetées ici s’appliquent à chaque nouvelle expédition.", Vector2(29.0, 59.0), Vector2(720.0, 28.0), 15, Color("b7c9ce")))
	meta_tree_fragment_label = _make_label("", Vector2(770.0, 23.0), Vector2(190.0, 48.0), 22, Color("e5ceff"), HORIZONTAL_ALIGNMENT_CENTER)
	meta_tree_card.add_child(meta_tree_fragment_label)
	var close_button: Button = _make_button("FERMER", Vector2(976.0, 14.0), Vector2(142.0, 62.0), false)
	close_button.pressed.connect(_close_meta_tree)
	meta_tree_card.add_child(close_button)

	var branch_titles: Array[String] = ["VOIE DE PUISSANCE", "VOIE DE COQUE", "VOIE D’INSTINCT"]
	var branch_colors: Array[Color] = [Color("ff9a5c"), Color("72d7ff"), Color("c88cff")]
	for i: int in range(3):
		var x: float = 28.0 + float(i) * 371.0
		var column: Panel = Panel.new()
		column.position = Vector2(x, 104.0)
		column.size = Vector2(345.0, 456.0)
		column.add_theme_stylebox_override("panel", _style_panel(Color(0.025, 0.036, 0.044, 0.97), Color(branch_colors[i].r, branch_colors[i].g, branch_colors[i].b, 0.42), 18, 4))
		meta_tree_card.add_child(column)
		column.add_child(_make_label(branch_titles[i], Vector2(12.0, 12.0), Vector2(321.0, 30.0), 17, branch_colors[i], HORIZONTAL_ALIGNMENT_CENTER))
		var line_one: ColorRect = ColorRect.new()
		line_one.position = Vector2(170.0, 143.0)
		line_one.size = Vector2(5.0, 34.0)
		line_one.color = Color(branch_colors[i].r, branch_colors[i].g, branch_colors[i].b, 0.36)
		column.add_child(line_one)
		var line_two: ColorRect = ColorRect.new()
		line_two.position = Vector2(170.0, 290.0)
		line_two.size = Vector2(5.0, 34.0)
		line_two.color = Color(branch_colors[i].r, branch_colors[i].g, branch_colors[i].b, 0.36)
		column.add_child(line_two)

	var damage_core: Button = _make_button("", Vector2(46.0, 154.0), Vector2(309.0, 112.0), false)
	damage_core.pressed.connect(_buy_meta_upgrade.bind("damage"))
	meta_tree_card.add_child(damage_core)
	meta_tree_buttons["damage_core"] = damage_core
	var fury: Button = _make_button("", Vector2(46.0, 301.0), Vector2(309.0, 112.0), false)
	fury.pressed.connect(_buy_meta_specialization.bind("fury"))
	meta_tree_card.add_child(fury)
	meta_tree_buttons["fury"] = fury
	var marauder: Button = _make_button("", Vector2(46.0, 448.0), Vector2(309.0, 100.0), false)
	marauder.pressed.connect(_buy_meta_relic.bind("marauder"))
	meta_tree_card.add_child(marauder)
	meta_tree_buttons["marauder"] = marauder

	var health_core: Button = _make_button("", Vector2(417.0, 154.0), Vector2(309.0, 112.0), false)
	health_core.pressed.connect(_buy_meta_upgrade.bind("health"))
	meta_tree_card.add_child(health_core)
	meta_tree_buttons["health_core"] = health_core
	var resilience: Button = _make_button("", Vector2(417.0, 301.0), Vector2(309.0, 112.0), false)
	resilience.pressed.connect(_buy_meta_specialization.bind("resilience"))
	meta_tree_card.add_child(resilience)
	meta_tree_buttons["resilience"] = resilience
	var sentinel: Button = _make_button("", Vector2(417.0, 448.0), Vector2(309.0, 100.0), false)
	sentinel.pressed.connect(_buy_meta_relic.bind("sentinel"))
	meta_tree_card.add_child(sentinel)
	meta_tree_buttons["sentinel"] = sentinel

	var instinct_core: Button = _make_button("", Vector2(788.0, 154.0), Vector2(309.0, 112.0), false)
	instinct_core.pressed.connect(_buy_meta_upgrade.bind("instinct"))
	meta_tree_card.add_child(instinct_core)
	meta_tree_buttons["instinct_core"] = instinct_core
	var scavenger: Button = _make_button("", Vector2(788.0, 301.0), Vector2(309.0, 112.0), false)
	scavenger.pressed.connect(_buy_meta_specialization.bind("scavenger"))
	meta_tree_card.add_child(scavenger)
	meta_tree_buttons["scavenger"] = scavenger
	var archon: Button = _make_button("", Vector2(788.0, 448.0), Vector2(309.0, 100.0), false)
	archon.pressed.connect(_buy_meta_relic.bind("archon"))
	meta_tree_card.add_child(archon)
	meta_tree_buttons["archon"] = archon

	meta_tree_hint_label = _make_label("", Vector2(30.0, 574.0), Vector2(1084.0, 28.0), 14, Color("9fb5ba"), HORIZONTAL_ALIGNMENT_CENTER)
	meta_tree_card.add_child(meta_tree_hint_label)
	meta_tree_overlay.visible = false
	_update_meta_buttons()

func _open_meta_tree() -> void:
	_update_meta_buttons()
	meta_tree_overlay.visible = true
	_on_ui_click()

func _close_meta_tree() -> void:
	meta_tree_overlay.visible = false

func _build_hud() -> void:
	hud = Control.new()
	hud.size = VIEW
	ui.add_child(hud)

	var grade: TextureRect = TextureRect.new()
	grade.texture = SCREEN_GRADE_TEXTURE
	grade.position = Vector2.ZERO
	grade.size = VIEW
	grade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	grade.stretch_mode = TextureRect.STRETCH_SCALE
	grade.modulate = Color(1.0, 1.0, 1.0, 0.58)
	grade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(grade)
	full_bleed_controls.append(grade)

	zone_mood_overlay = ColorRect.new()
	zone_mood_overlay.position = Vector2.ZERO
	zone_mood_overlay.size = VIEW
	zone_mood_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	zone_mood_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(zone_mood_overlay)
	full_bleed_controls.append(zone_mood_overlay)

	hud_status = Panel.new()
	hud_status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_status.add_theme_stylebox_override("panel", _style_panel(Color(0.016, 0.025, 0.031, 0.86), Color(0.31, 0.53, 0.56, 0.28), 15, 4))
	hud.add_child(hud_status)
	hud_name_label = _make_label("NØMAD ZERO", Vector2(14.0, 7.0), Vector2(220.0, 23.0), 17, Color("e8d0aa"))
	hud_status.add_child(hud_name_label)
	level_label = _make_label("NIV. 1", Vector2(276.0, 7.0), Vector2(96.0, 23.0), 15, Color("dcebed"), HORIZONTAL_ALIGNMENT_RIGHT)
	hud_status.add_child(level_label)

	hud_health_caption = _make_label("VIE", Vector2(14.0, 35.0), Vector2(44.0, 18.0), 11, Color("d9a09a"))
	hud_status.add_child(hud_health_caption)
	health_bar = ProgressBar.new()
	health_bar.position = Vector2(14.0, 52.0)
	health_bar.size = Vector2(344.0, 24.0)
	health_bar.show_percentage = false
	_style_hud_bar(health_bar, Color("c85d57"), 7)
	hud_status.add_child(health_bar)
	hp_label = _make_label("150 / 150", Vector2(14.0, 52.0), Vector2(344.0, 24.0), 14, Color("fff6ef"), HORIZONTAL_ALIGNMENT_CENTER)
	hp_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_status.add_child(hp_label)

	hud_xp_caption = _make_label("XP", Vector2(14.0, 82.0), Vector2(38.0, 16.0), 10, Color("8bc8cf"))
	hud_status.add_child(hud_xp_caption)
	xp_bar = ProgressBar.new()
	xp_bar.position = Vector2(54.0, 84.0)
	xp_bar.size = Vector2(304.0, 14.0)
	xp_bar.show_percentage = false
	_style_hud_bar(xp_bar, Color("5aaeb8"), 5)
	hud_status.add_child(xp_bar)
	xp_label = _make_label("0 / 26", Vector2(54.0, 84.0), Vector2(304.0, 14.0), 10, Color("f5fdff"), HORIZONTAL_ALIGNMENT_CENTER)
	xp_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_status.add_child(xp_label)

	force_status_label = null
	shield_bar = ProgressBar.new()
	shield_bar.max_value = 1.0
	shield_bar.visible = false
	overdrive_label = null
	overdrive_bar = null

	hud_wave_panel = Panel.new()
	hud_wave_panel.add_theme_stylebox_override("panel", _style_panel(Color(0.020, 0.029, 0.036, 0.88), Color(0.43, 0.48, 0.55, 0.36), 14, 4))
	hud.add_child(hud_wave_panel)
	event_label = _make_label("VAGUE 1  •  00:50", Vector2(6.0, 5.0), Vector2(326.0, 38.0), 20, Color("d6dde0"), HORIZONTAL_ALIGNMENT_CENTER)
	event_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hud_wave_panel.add_child(event_label)
	boss_label = _make_label("", Vector2(468.0, 64.0), Vector2(338.0, 22.0), 13, Color("d8dfe2"), HORIZONTAL_ALIGNMENT_CENTER)
	hud.add_child(boss_label)
	boss_bar = ProgressBar.new()
	boss_bar.position = Vector2(480.0, 88.0)
	boss_bar.size = Vector2(314.0, 9.0)
	boss_bar.show_percentage = false
	_style_bar(boss_bar, Color("8d768f"), 5)
	boss_bar.visible = false
	hud.add_child(boss_bar)
	boss_move_label = _make_label("", Vector2(468.0, 101.0), Vector2(338.0, 24.0), 13, Color("fff0d5"), HORIZONTAL_ALIGNMENT_CENTER)
	boss_move_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boss_move_label.visible = false
	hud.add_child(boss_move_label)
	threat_label = _make_label("", Vector2(440.0, 668.0), Vector2(400.0, 28.0), 14, Color("ffcc7a"), HORIZONTAL_ALIGNMENT_CENTER)
	threat_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	threat_label.visible = false
	hud.add_child(threat_label)

	hud_info_panel = Panel.new()
	hud_info_panel.add_theme_stylebox_override("panel", _style_panel(Color(0.016, 0.027, 0.032, 0.84), Color(0.53, 0.46, 0.34, 0.28), 14, 4))
	hud.add_child(hud_info_panel)
	kills_label = _make_label("KO 0", Vector2(12.0, 7.0), Vector2(100.0, 27.0), 18, Color("fff0d2"))
	hud_info_panel.add_child(kills_label)
	time_label = _make_label("00:00", Vector2(116.0, 7.0), Vector2(106.0, 27.0), 15, Color("d6e0df"), HORIZONTAL_ALIGNMENT_RIGHT)
	hud_info_panel.add_child(time_label)
	fragment_label = _make_label("FRAG 0  •  MOD 0", Vector2(10.0, 39.0), Vector2(216.0, 23.0), 12, Color("cbbfd2"), HORIZONTAL_ALIGNMENT_CENTER)
	hud_info_panel.add_child(fragment_label)

	zone_label = _make_label("", Vector2(14.0, 682.0), Vector2(250.0, 22.0), 12, Color("ffffff"))
	zone_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(zone_label)
	danger_label = _make_label("", Vector2(14.0, 653.0), Vector2(360.0, 24.0), 12, Color("b6c5c8"))
	danger_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	danger_label.visible = false
	hud.add_child(danger_label)

	zone_banner_panel = Panel.new()
	zone_banner_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	zone_banner_panel.visible = false
	zone_banner_panel.modulate.a = 0.0
	zone_banner_panel.add_theme_stylebox_override("panel", _style_panel(Color(0.014, 0.020, 0.028, 0.84), Color(0.75, 0.64, 0.45, 0.42), 18, 8))
	hud.add_child(zone_banner_panel)
	zone_banner_label = _make_label("", Vector2(18.0, 8.0), Vector2(484.0, 26.0), 18, Color("fff1d7"), HORIZONTAL_ALIGNMENT_CENTER)
	zone_banner_panel.add_child(zone_banner_label)
	zone_banner_subtitle_label = _make_label("", Vector2(18.0, 34.0), Vector2(484.0, 18.0), 11, Color("b7c7cb"), HORIZONTAL_ALIGNMENT_CENTER)
	zone_banner_panel.add_child(zone_banner_subtitle_label)

	# Les compétences tactiles restent retirées : le bas droit appartient au mouvement.
	hud_pause_button = _make_button("Ⅱ", Vector2(1212.0, 12.0), Vector2(54.0, 50.0), false)
	hud_pause_button.add_theme_font_size_override("font_size", 20)
	hud_pause_button.pressed.connect(_toggle_pause)
	hud.add_child(hud_pause_button)

	toast_label = _make_label("", Vector2(360.0, 118.0), Vector2(560.0, 40.0), 18, Color("e6d3ac"), HORIZONTAL_ALIGNMENT_CENTER)
	toast_label.modulate.a = 0.0
	hud.add_child(toast_label)
	combo_label = _make_label("", Vector2(470.0, 158.0), Vector2(340.0, 30.0), 16, Color("dbc28b"), HORIZONTAL_ALIGNMENT_CENTER)
	combo_label.modulate.a = 0.0
	hud.add_child(combo_label)

	rift_overlay = ColorRect.new()
	rift_overlay.position = Vector2.ZERO
	rift_overlay.size = VIEW
	rift_overlay.color = Color(0.43, 0.28, 0.56, 0.0)
	rift_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(rift_overlay)
	hud.move_child(rift_overlay, 0)
	full_bleed_controls.append(rift_overlay)

	joystick = JoystickScript.new() as NomadVirtualJoystick
	joystick.position = Vector2.ZERO
	joystick.size = VIEW
	joystick.blocked_controls.append(hud_pause_button)
	hud.add_child(joystick)
	_build_presentation_hud()

func _build_presentation_hud() -> void:
	presentation_overlay = Control.new()
	presentation_overlay.name = "PresentationOverlay"
	presentation_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	presentation_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	presentation_overlay.modulate.a = 0.0
	hud.add_child(presentation_overlay)
	presentation_veil = ColorRect.new()
	presentation_veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	presentation_veil.color = Color(0.05, 0.02, 0.08, 0.0)
	presentation_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	presentation_overlay.add_child(presentation_veil)
	presentation_top_bar = ColorRect.new()
	presentation_top_bar.color = Color(0.006, 0.010, 0.014, 0.92)
	presentation_top_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	presentation_overlay.add_child(presentation_top_bar)
	presentation_bottom_bar = ColorRect.new()
	presentation_bottom_bar.color = Color(0.006, 0.010, 0.014, 0.92)
	presentation_bottom_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	presentation_overlay.add_child(presentation_bottom_bar)
	presentation_card = Panel.new()
	presentation_card.size = Vector2(680.0, 130.0)
	presentation_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	presentation_overlay.add_child(presentation_card)
	presentation_accent = ColorRect.new()
	presentation_accent.position = Vector2(17.0, 18.0)
	presentation_accent.size = Vector2(6.0, 94.0)
	presentation_accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	presentation_card.add_child(presentation_accent)
	presentation_title = _make_label("", Vector2(38.0, 20.0), Vector2(614.0, 48.0), 36, Color("fff3dd"), HORIZONTAL_ALIGNMENT_CENTER)
	presentation_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	presentation_card.add_child(presentation_title)
	presentation_subtitle = _make_label("", Vector2(38.0, 72.0), Vector2(614.0, 30.0), 16, Color("c5d4d6"), HORIZONTAL_ALIGNMENT_CENTER)
	presentation_subtitle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	presentation_card.add_child(presentation_subtitle)

	loot_banner_panel = Panel.new()
	loot_banner_panel.size = Vector2(440.0, 70.0)
	loot_banner_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	loot_banner_panel.modulate.a = 0.0
	hud.add_child(loot_banner_panel)
	loot_banner_rarity = _make_label("", Vector2(16.0, 7.0), Vector2(408.0, 17.0), 11, Color("a8d9b0"), HORIZONTAL_ALIGNMENT_CENTER)
	loot_banner_panel.add_child(loot_banner_rarity)
	loot_banner_name = _make_label("", Vector2(16.0, 23.0), Vector2(408.0, 27.0), 19, Color("fff3dd"), HORIZONTAL_ALIGNMENT_CENTER)
	loot_banner_panel.add_child(loot_banner_name)
	loot_banner_hint = _make_label("MODULE INTÉGRÉ AU BUILD", Vector2(16.0, 50.0), Vector2(408.0, 15.0), 10, Color("9dafb3"), HORIZONTAL_ALIGNMENT_CENTER)
	loot_banner_panel.add_child(loot_banner_hint)

func _build_upgrade_panel() -> void:
	upgrade_panel = Control.new()
	upgrade_panel.size = VIEW
	upgrade_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	ui.add_child(upgrade_panel)
	var scrim: ColorRect = ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.008, 0.014, 0.020, 0.88)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	upgrade_panel.add_child(scrim)
	full_bleed_controls.append(scrim)
	var card: Panel = Panel.new()
	card.position = Vector2(82.0, 102.0)
	card.size = Vector2(1116.0, 516.0)
	card.add_theme_stylebox_override("panel", _style_panel(Color(0.028, 0.038, 0.046, 0.985), Color(0.35, 0.78, 0.86, 0.68), 28, 18))
	upgrade_panel.add_child(card)
	upgrade_title_label = _make_label("NIVEAU 2  •  CHOISIS UNE AMÉLIORATION", Vector2(0.0, 26.0), Vector2(1116.0, 44.0), 27, Color("fff0d2"), HORIZONTAL_ALIGNMENT_CENTER)
	card.add_child(upgrade_title_label)
	card.add_child(_make_label("Chaque choix modifie réellement le build de cette expédition.", Vector2(0.0, 72.0), Vector2(1116.0, 24.0), 13, Color("9fb8bf"), HORIZONTAL_ALIGNMENT_CENTER))
	for i: int in range(3):
		var button: Button = _make_button("CHOIX", Vector2(38.0 + float(i) * 353.0, 118.0), Vector2(334.0, 326.0), false)
		button.process_mode = Node.PROCESS_MODE_ALWAYS
		button.add_theme_font_size_override("font_size", 18)
		button.pressed.connect(_select_level_upgrade.bind(i))
		card.add_child(button)
		upgrade_buttons.append(button)
	card.add_child(_make_label("COMMUN  •  RARE  •  ÉPIQUE", Vector2(0.0, 468.0), Vector2(1116.0, 20.0), 12, Color("81949a"), HORIZONTAL_ALIGNMENT_CENTER))
	upgrade_panel.visible = false

func _roll_upgrade_rarity() -> String:
	var epic_chance: float = minf(0.12, 0.045 + float(level) * 0.0022)
	var rare_chance: float = minf(0.31, 0.215 + float(level) * 0.0026)
	var roll: float = rng.randf()
	if roll < epic_chance:
		return "epic"
	if roll < epic_chance + rare_chance:
		return "rare"
	return "common"

func _rarity_multiplier(rarity: String) -> float:
	if rarity == "epic":
		return 1.75
	if rarity == "rare":
		return 1.32
	return 1.0

func _rarity_label(rarity: String) -> String:
	if rarity == "epic":
		return "ÉPIQUE"
	if rarity == "rare":
		return "RARE"
	return "COMMUN"

func _rarity_color(rarity: String) -> Color:
	if rarity == "epic":
		return Color("c276ff")
	if rarity == "rare":
		return Color("55d9f0")
	return Color("d8b77b")

func _make_upgrade_option(upgrade_id: String, rarity: String) -> Dictionary:
	var multiplier: float = _rarity_multiplier(rarity)
	var title: String = "AMPLIFICATEUR"
	var description: String = "Renforcement du Nomad"
	match upgrade_id:
		"damage":
			title = "LAME SURCHARGÉE"
			description = "+%d %% dégâts sabre" % roundi(8.5 * multiplier)
		"cadence":
			title = "RYTHME DE DUEL"
			description = "+%d %% cadence d’attaque" % roundi(6.5 * multiplier)
		"range":
			title = "ALLONGE DU RIFT"
			description = "+%d portée  •  arc élargi" % roundi(20.0 * multiplier)
		"chain":
			title = "FRAPPE EN CHAÎNE"
			description = "+1 cible par frappe"
		"critical":
			title = "POINT FAIBLE"
			description = "+%d %% chance critique" % roundi(3.5 * multiplier)
		"crit_power":
			title = "EXÉCUTION"
			description = "+%d %% puissance critique" % roundi(13.0 * multiplier)
		"speed":
			title = "PROPULSEURS"
			description = "+%d %% vitesse de déplacement" % roundi(4.5 * multiplier)
		"hull":
			title = "RENFORT BIO"
			var displayed_gain: float = minf(18.0 * multiplier, maxf(0.0, 560.0 - player.max_health)) if is_instance_valid(player) else 18.0 * multiplier
			description = "+%d PV max  •  soin immédiat" % roundi(displayed_gain)
		"shield":
			title = "ONDE DE FORCE"
			description = "recharge plus vite  •  onde plus large"
		"regen":
			title = "NANORÉPARATION"
			description = "+%.2f PV / seconde" % (0.07 * multiplier)
		"armor":
			title = "PLAQUES RÉACTIVES"
			description = "+%.1f %% réduction des dégâts" % (1.10 * multiplier)
		"magnet":
			title = "CHAMP D’ATTRACTION"
			description = "+%d aimant  •  EXP +%d %%" % [roundi(28.0 * multiplier), roundi(4.0 * multiplier)]
		"siphon":
			title = "SIPHON VITAL"
			description = "+%.1f PV par élimination" % (0.25 * multiplier)
		"fortune":
			title = "RÉSONANCE DU RIFT"
			description = "+%.1f %% chance de fragment" % (1.4 * multiplier)
		"repair":
			title = "SOINS DE CAMPAGNE"
			description = "Récupère jusqu'à 50 PV"
		"salvage":
			title = "RÉCUPÉRATION"
			description = "+4 fragments pour le profil"
		"charge":
			title = "RÉARMEMENT"
			description = "Recharge l'onde et le dash"
	return {"id": upgrade_id, "rarity": rarity, "multiplier": multiplier, "title": title, "description": description}

func _generate_upgrade_options() -> Array[Dictionary]:
	var pool: Array[String] = ["damage", "cadence", "range", "chain", "critical", "crit_power", "speed", "hull", "shield", "regen", "armor", "magnet", "siphon", "fortune"]
	if is_instance_valid(player):
		if player.damage >= 220.0:
			pool.erase("damage")
		if player.attack_interval <= 0.22:
			pool.erase("cadence")
		if player.saber_range >= 330.0:
			pool.erase("range")
		if player.multishot_count >= 5:
			pool.erase("chain")
		if player.critical_chance >= 0.40:
			pool.erase("critical")
		if player.critical_multiplier >= 2.80:
			pool.erase("crit_power")
		if player.speed >= 410.0:
			pool.erase("speed")
		if player.max_health >= 560.0:
			pool.erase("hull")
		if player.pulse_cooldown <= 2.6:
			pool.erase("shield")
		if player.regeneration >= 1.6:
			pool.erase("regen")
		if player.armor >= 0.31:
			pool.erase("armor")
		if run_xp_multiplier >= 1.65:
			pool.erase("magnet")
		if run_life_on_kill >= 1.0:
			pool.erase("siphon")
		if run_fragment_bonus_chance >= 0.10:
			pool.erase("fortune")
	var options: Array[Dictionary] = []
	while options.size() < 3 and not pool.is_empty():
		var index: int = rng.randi_range(0, pool.size() - 1)
		var upgrade_id: String = pool[index]
		pool.remove_at(index)
		options.append(_make_upgrade_option(upgrade_id, _roll_upgrade_rarity()))
	# Toujours trois choix même après avoir atteint les plafonds du build.
	for fallback_id: String in ["repair", "salvage", "charge"]:
		if options.size() >= 3:
			break
		options.append(_make_upgrade_option(fallback_id, "common"))
	return options

func _populate_upgrade_choices(reroll: bool = true) -> void:
	if reroll or pending_upgrade_options.is_empty():
		pending_upgrade_options = _generate_upgrade_options()
	upgrade_title_label.text = "NIVEAU %d  •  CHOISIS UNE AMÉLIORATION" % level
	for i: int in range(upgrade_buttons.size()):
		var button: Button = upgrade_buttons[i]
		if i >= pending_upgrade_options.size():
			button.visible = false
			continue
		button.visible = true
		var option: Dictionary = pending_upgrade_options[i]
		var rarity: String = String(option["rarity"])
		var border: Color = _rarity_color(rarity)
		button.text = "%s\n\n%s\n\n%s" % [_rarity_label(rarity), String(option["title"]), String(option["description"])]
		var normal: StyleBoxFlat = _style_panel(Color(0.045, 0.055, 0.064, 0.985), border, 20, 8)
		var hover: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
		hover.bg_color = Color(0.075, 0.090, 0.102, 1.0)
		hover.border_color = border.lightened(0.18)
		var pressed: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
		pressed.bg_color = Color(0.028, 0.034, 0.042, 1.0)
		button.add_theme_stylebox_override("normal", normal)
		button.add_theme_stylebox_override("hover", hover)
		button.add_theme_stylebox_override("pressed", pressed)
		button.add_theme_color_override("font_color", border.lightened(0.22))

func _present_upgrade_if_needed() -> void:
	if pending_level_choices <= 0 or upgrade_pending or state != State.PLAYING or not is_instance_valid(player):
		return
	# Le choix de niveau doit être un vrai arrêt du jeu, pas seulement une surcouche UI.
	upgrade_pending = true
	joystick.reset()
	joystick.enabled = false
	player.set_selection_lock(true)
	world_entities.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().paused = true
	_populate_upgrade_choices(pending_upgrade_options.is_empty())
	upgrade_panel.visible = true
	_save_profile()

func _select_level_upgrade(index: int) -> void:
	if not upgrade_pending or index < 0 or index >= pending_upgrade_options.size() or not is_instance_valid(player):
		return
	var option: Dictionary = pending_upgrade_options[index]
	_apply_level_upgrade(option)
	pending_level_choices = maxi(0, pending_level_choices - 1)
	_play_sfx(SFX_LEVEL, -7.0, 1.02, 1.08)
	if pending_level_choices > 0:
		_populate_upgrade_choices()
		_save_profile()
		return
	upgrade_pending = false
	pending_upgrade_options.clear()
	upgrade_panel.visible = false
	if is_instance_valid(player):
		player.set_selection_lock(false)
	world_entities.process_mode = Node.PROCESS_MODE_DISABLED if rotation_blocked else Node.PROCESS_MODE_PAUSABLE
	get_tree().paused = false
	if state == State.PLAYING and not rotation_blocked:
		joystick.enabled = true
	_save_profile()

func _apply_level_upgrade(option: Dictionary) -> void:
	var upgrade_id: String = String(option["id"])
	var rarity: String = String(option["rarity"])
	var multiplier: float = float(option["multiplier"])
	match upgrade_id:
		"damage":
			player.damage = minf(220.0, player.damage * (1.0 + 0.085 * multiplier))
		"cadence":
			player.attack_interval = maxf(0.22, player.attack_interval * (1.0 - 0.065 * multiplier))
		"range":
			player.saber_range = minf(330.0, player.saber_range + 20.0 * multiplier)
			player.saber_arc_degrees = minf(132.0, player.saber_arc_degrees + 4.0 * multiplier)
		"chain":
			player.multishot_count = mini(5, player.multishot_count + 1)
			if rarity == "epic":
				player.saber_range += 14.0
		"critical":
			player.critical_chance = minf(0.42, player.critical_chance + 0.030 * multiplier)
		"crit_power":
			player.critical_multiplier = minf(2.80, player.critical_multiplier + 0.11 * multiplier)
		"speed":
			player.speed = minf(410.0, player.speed * (1.0 + 0.045 * multiplier))
		"hull":
			var health_gain: float = minf(560.0 - player.max_health, 16.0 * multiplier)
			player.max_health += health_gain
			player.heal(health_gain * 1.25)
		"shield":
			player.pulse_cooldown = maxf(2.6, player.pulse_cooldown - 0.26 * multiplier)
			player.force_wave_radius += 14.0 * multiplier
			player.force_wave_damage_scale += 0.05 * multiplier
			player.force_wave_auto_range += 10.0 * multiplier
			player.restore_shield(18.0 * multiplier)
		"regen":
			player.regeneration = minf(1.6, player.regeneration + 0.07 * multiplier)
		"armor":
			player.armor = minf(0.32, player.armor + 0.011 * multiplier)
		"magnet":
			player.magnet_range = minf(500.0, player.magnet_range + 28.0 * multiplier)
			run_xp_multiplier = minf(1.65, run_xp_multiplier + 0.032 * multiplier)
		"siphon":
			run_life_on_kill = minf(1.0, run_life_on_kill + 0.25 * multiplier)
		"fortune":
			run_fragment_bonus_chance = minf(0.10, run_fragment_bonus_chance + 0.014 * multiplier)
		"repair":
			player.heal(38.0)
		"salvage":
			rift_fragments += 3
			run_fragments += 3
		"charge":
			player.pulse_timer = 0.0
			player.dash_timer = 0.0
	player.heal(minf(16.0, player.max_health * 0.025))
	player.restore_shield(8.0)
	_check_run_synergies()
	_limit_survival_stats()
	_show_toast("%s  •  %s" % [_rarity_label(rarity), String(option["title"])])

func _limit_survival_stats() -> void:
	# Migration d'une partie V44.25 : elle conserve son niveau et ses objets,
	# mais applique les plafonds utilisés par les nouvelles vagues.
	player.max_health = minf(player.max_health, 560.0)
	player.health = minf(player.health, player.max_health)
	player.regeneration = minf(player.regeneration, 1.6)
	player.speed = minf(player.speed, 410.0)
	player.damage = minf(player.damage, 220.0)
	player.critical_multiplier = minf(player.critical_multiplier, 2.8)
	player.armor = minf(player.armor, 0.32)
	player.saber_range = minf(player.saber_range, 330.0)
	player.magnet_range = minf(player.magnet_range, 500.0)
	player.critical_chance = minf(player.critical_chance, 0.42)
	player.attack_interval = maxf(player.attack_interval, 0.22)
	run_xp_multiplier = minf(run_xp_multiplier, 1.65)
	run_life_on_kill = minf(run_life_on_kill, 1.0)
	run_fragment_bonus_chance = minf(run_fragment_bonus_chance, 0.12)

func _check_run_synergies() -> void:
	if not run_synergies.has("precision_blade") and player.damage >= 36.0 and player.critical_chance >= 0.16:
		run_synergies["precision_blade"] = true
		player.critical_multiplier += 0.14
		_show_toast("SYNERGIE  •  LAME PRÉCISE")
	if not run_synergies.has("force_echo") and player.pulse_cooldown <= 3.9 and player.armor >= 0.09:
		run_synergies["force_echo"] = true
		player.force_wave_damage_scale += 0.18
		player.force_wave_radius += 26.0
		_show_toast("SYNERGIE  •  ÉCHO DE FORCE")
	if not run_synergies.has("wide_hunt") and player.saber_range >= 250.0 and player.multishot_count >= 3:
		run_synergies["wide_hunt"] = true
		player.damage *= 1.06
		_show_toast("SYNERGIE  •  CHASSE LARGE")

func _style_bar(bar: ProgressBar, fill_color: Color, radius: int = 8) -> void:
	var back: StyleBoxFlat = StyleBoxFlat.new()
	back.bg_color = Color(0.075, 0.09, 0.095, 0.94)
	back.corner_radius_top_left = radius
	back.corner_radius_top_right = radius
	back.corner_radius_bottom_left = radius
	back.corner_radius_bottom_right = radius
	var fill: StyleBoxFlat = back.duplicate() as StyleBoxFlat
	fill.bg_color = fill_color
	bar.add_theme_stylebox_override("background", back)
	bar.add_theme_stylebox_override("fill", fill)

func _style_hud_bar(bar: ProgressBar, fill_color: Color, radius: int = 8) -> void:
	var back: StyleBoxFlat = StyleBoxFlat.new()
	back.bg_color = Color(0.035, 0.050, 0.058, 0.98)
	back.border_color = Color(fill_color.r, fill_color.g, fill_color.b, 0.38)
	back.border_width_left = 1
	back.border_width_top = 1
	back.border_width_right = 1
	back.border_width_bottom = 1
	back.corner_radius_top_left = radius
	back.corner_radius_top_right = radius
	back.corner_radius_bottom_left = radius
	back.corner_radius_bottom_right = radius
	var fill: StyleBoxFlat = StyleBoxFlat.new()
	fill.bg_color = fill_color
	fill.corner_radius_top_left = radius
	fill.corner_radius_top_right = radius
	fill.corner_radius_bottom_left = radius
	fill.corner_radius_bottom_right = radius
	bar.add_theme_stylebox_override("background", back)
	bar.add_theme_stylebox_override("fill", fill)

func _build_pause() -> void:
	pause_panel = Control.new()
	pause_panel.size = VIEW
	pause_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	ui.add_child(pause_panel)
	var scrim: ColorRect = ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.006, 0.012, 0.018, 0.82)
	pause_panel.add_child(scrim)
	full_bleed_controls.append(scrim)
	var card: Panel = Panel.new()
	card.position = Vector2(390.0, 145.0)
	card.size = Vector2(500.0, 430.0)
	card.add_theme_stylebox_override("panel", _style_panel(Color(0.020, 0.030, 0.037, 0.985), Color(0.36, 0.56, 0.59, 0.50), 22, 12))
	pause_panel.add_child(card)
	card.add_child(_make_label("EXPÉDITION EN PAUSE", Vector2(0.0, 31.0), Vector2(500.0, 44.0), 29, Color("edf8f8"), HORIZONTAL_ALIGNMENT_CENTER))
	card.add_child(_make_label("La partie reste sauvegardée localement.", Vector2(50.0, 78.0), Vector2(400.0, 24.0), 13, Color("aebfc3"), HORIZONTAL_ALIGNMENT_CENTER))
	var resume: Button = _make_button("REPRENDRE", Vector2(62.0, 126.0), Vector2(376.0, 66.0), true)
	resume.pressed.connect(_toggle_pause)
	card.add_child(resume)
	var restart: Button = _make_button("NOUVELLE EXPÉDITION", Vector2(62.0, 214.0), Vector2(376.0, 56.0), false)
	restart.pressed.connect(_restart_from_pause)
	card.add_child(restart)
	var menu_button: Button = _make_button("MENU PRINCIPAL", Vector2(62.0, 286.0), Vector2(376.0, 56.0), false)
	menu_button.pressed.connect(_menu_from_pause)
	card.add_child(menu_button)
	card.add_child(_make_label("ÉCHAP  •  REPRENDRE     |     V49.2", Vector2(0.0, 375.0), Vector2(500.0, 22.0), 11, Color("87999e"), HORIZONTAL_ALIGNMENT_CENTER))

func _build_game_over() -> void:
	game_over = Control.new()
	game_over.size = VIEW
	ui.add_child(game_over)
	var scrim: ColorRect = ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.008, 0.013, 0.018, 0.88)
	game_over.add_child(scrim)
	full_bleed_controls.append(scrim)
	var card: Panel = Panel.new()
	card.position = Vector2(360.0, 116.0)
	card.size = Vector2(560.0, 488.0)
	card.add_theme_stylebox_override("panel", _style_panel(Color(0.026, 0.032, 0.037, 0.99), Color(0.67, 0.39, 0.29, 0.58), 24, 14))
	game_over.add_child(card)
	card.add_child(_make_label("EXPÉDITION TERMINÉE", Vector2(0.0, 34.0), Vector2(560.0, 48.0), 31, Color("ead7c9"), HORIZONTAL_ALIGNMENT_CENTER))
	card.add_child(_make_label("Les fragments et découvertes du profil sont conservés.", Vector2(56.0, 83.0), Vector2(448.0, 28.0), 14, Color("cdbfb5"), HORIZONTAL_ALIGNMENT_CENTER))
	var stat_panel: Panel = Panel.new()
	stat_panel.position = Vector2(58.0, 132.0)
	stat_panel.size = Vector2(444.0, 136.0)
	stat_panel.add_theme_stylebox_override("panel", _style_panel(Color(0.015, 0.022, 0.027, 0.86), Color(0.45, 0.51, 0.53, 0.30), 15, 3))
	card.add_child(stat_panel)
	game_over_stats = _make_label("", Vector2(20.0, 13.0), Vector2(404.0, 110.0), 18, Color("ebe5da"), HORIZONTAL_ALIGNMENT_CENTER)
	game_over_stats.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	stat_panel.add_child(game_over_stats)
	var retry: Button = _make_button("REPARTIR", Vector2(70.0, 300.0), Vector2(420.0, 68.0), true)
	retry.pressed.connect(_start_run)
	card.add_child(retry)
	var back: Button = _make_button("MENU PRINCIPAL", Vector2(70.0, 386.0), Vector2(420.0, 56.0), false)
	back.pressed.connect(_show_menu)
	card.add_child(back)

func _on_ui_click() -> void:
	_play_sfx(SFX_UI, -16.0, 0.98, 1.03)

func _show_menu() -> void:
	_save_profile()
	_cancel_pending_backup()
	get_tree().paused = false
	if is_instance_valid(player):
		player.set_selection_lock(false)
	state = State.MENU
	world_entities.visible = false
	world_entities.process_mode = Node.PROCESS_MODE_DISABLED
	menu.visible = true
	boss_dossier_overlay.visible = false
	if meta_tree_overlay != null:
		meta_tree_overlay.visible = false
	if upgrade_panel != null:
		upgrade_panel.visible = false
	upgrade_pending = false
	pending_level_choices = 0
	hud.visible = false
	pause_panel.visible = false
	game_over.visible = false
	if joystick != null:
		joystick.enabled = false
		joystick.reset()
	_clear_run_nodes()
	_update_menu_stats()

func _start_run() -> void:
	_cancel_pending_backup()
	get_tree().paused = false
	if joystick != null:
		joystick.enabled = false
		joystick.reset()
	state = State.MENU
	# Le bouton de nouvelle expédition remplace explicitement la partie conservée.
	saved_run.clear()
	_save_profile()
	menu.visible = false
	hud.visible = false
	hud.modulate.a = 1.0
	pause_panel.visible = false
	game_over.visible = false
	world_entities.visible = false
	world_entities.process_mode = Node.PROCESS_MODE_DISABLED
	_clear_run_nodes()
	_reset_run_state()
	_spawn_player()
	_spawn_initial_loot_caches()
	_spawn_canyon_secrets()
	for _i: int in range(4):
		_spawn_enemy()
	_update_hud()
	_begin_run()

func _reset_run_state() -> void:
	kills = 0
	level = 1
	xp = 0
	xp_needed = 26
	run_time = 0.0
	combo = 0
	combo_timer = 0.0
	attack_timer = 0.36
	spawn_timer = 1.25
	event_timer = 999.0
	wave_number = 1
	hud_refresh_timer = 0.0
	autosave_timer = AUTOSAVE_INTERVAL
	wave_duration = 52.0
	wave_time_left = wave_duration
	wave_cleanup = false
	wave_intermission = -1.0
	elites_killed = 0
	stream_timer = 0.0
	cleanup_timer = 0.0
	overdrive_meter = 0.0
	overdrive_time = 0.0
	run_fragments = 0
	run_xp_multiplier = 1.0
	run_life_on_kill = 0.0
	run_fragment_bonus_chance = 0.0
	run_synergies.clear()
	pending_level_choices = 0
	upgrade_pending = false
	pending_upgrade_options.clear()
	if upgrade_panel != null:
		upgrade_panel.visible = false
	zone_banner_timer = 0.0
	active_zone_name = ""
	if danger_label != null:
		danger_label.text = ""
	if zone_label != null:
		zone_label.text = ""
	zone_stay_timer = 0.0
	camp_support_timer = 1.8
	central_supply_timer = 0.0
	survival_relief_timer = 6.0
	zone_logic_accumulator = 0.0
	run_modules.clear()
	run_module_count = 0
	dynamic_event_active = false
	dynamic_event_kind = ""
	dynamic_event_position = Vector2.ZERO
	dynamic_event_started = false
	dynamic_event_progress = 0.0
	dynamic_event_target = 1.0
	dynamic_event_spawn_timer = 0.0
	dynamic_event_age = 0.0
	dynamic_event_kills = 0
	dynamic_event_target_kills = 0
	skill_traction_cooldown_timer = 0.0
	skill_surge_timer = 0.0
	skill_surge_cooldown_timer = 0.0
	skill_surge_fx_timer = 0.0
	_refresh_dynamic_event_marker()
	boss_enemy = null
	if boss_bar != null:
		boss_bar.visible = false
	if boss_label != null:
		boss_label.text = ""
	if boss_move_label != null:
		boss_move_label.visible = false
	boss_event_timer = 4.2
	boss_event_count = 0

func _begin_run(resumed: bool = false) -> void:
	state = State.PLAYING
	menu.visible = false
	boss_dossier_overlay.visible = false
	if meta_tree_overlay != null:
		meta_tree_overlay.visible = false
	game_over.visible = false
	upgrade_panel.visible = false
	world_entities.visible = true
	world_entities.process_mode = Node.PROCESS_MODE_DISABLED if rotation_blocked else Node.PROCESS_MODE_PAUSABLE
	hud.visible = true
	hud.modulate.a = 1.0
	pause_panel.visible = false
	joystick.enabled = not rotation_blocked
	_show_toast("VAGUE %d  •  REPRISE" % wave_number if resumed else "VAGUE 1  •  DÉPLOIEMENT")
	if not resumed:
		_show_presentation("NØMAD ZERO", "SURVIS • EXPLORE • CONSOLIDE TON BUILD", Color("efc58f"), 0.78, false)
	_save_profile()

func _is_valid_saved_run(candidate: Variant) -> bool:
	if not candidate is Dictionary:
		return false
	var checkpoint: Dictionary = candidate
	if checkpoint.get("version", -1) != RUN_SAVE_VERSION:
		return false
	if typeof(checkpoint.get("wave_number")) != TYPE_INT or int(checkpoint["wave_number"]) < 1:
		return false
	if typeof(checkpoint.get("level")) != TYPE_INT or int(checkpoint["level"]) < 1:
		return false
	var stats: Variant = checkpoint.get("player")
	if not stats is Dictionary or typeof(stats.get("position")) != TYPE_VECTOR2:
		return false
	if typeof(stats.get("health")) != TYPE_FLOAT or float(stats["health"]) <= 0.0:
		return false
	return true

func _capture_run() -> Dictionary:
	var checkpoint: Dictionary = {"version": RUN_SAVE_VERSION}
	for property_name: String in RUN_SAVE_PROPERTIES:
		checkpoint[property_name] = get(property_name)
	checkpoint["run_synergies"] = run_synergies.duplicate(true)
	checkpoint["upgrade_options"] = pending_upgrade_options.duplicate(true)
	var player_data: Dictionary = {"position": player.global_position}
	for property_name: String in PLAYER_SAVE_PROPERTIES:
		player_data[property_name] = player.get(property_name)
	checkpoint["player"] = player_data
	var enemies: Array[Dictionary] = []
	for node: Node in enemies_root.get_children():
		var enemy: NomadEnemy = node as NomadEnemy
		if enemy == null or not enemy.active or enemy.is_queued_for_deletion():
			continue
		var data: Dictionary = {"kind": enemy.kind, "elite": enemy.elite, "affix": enemy.affix, "position": enemy.global_position}
		if enemy.has_meta("world_event_id"):
			data["world_event_id"] = int(enemy.get_meta("world_event_id", -1))
			data["world_event_role"] = String(enemy.get_meta("world_event_role", ""))
		for property_name: String in ENEMY_SAVE_PROPERTIES:
			data[property_name] = enemy.get(property_name)
		enemies.append(data)
	checkpoint["enemies"] = enemies
	var pickups: Array[Dictionary] = []
	for node: Node in pickups_root.get_children():
		if node.is_queued_for_deletion():
			continue
		var pickup: Node2D = node as Node2D
		if pickup == null:
			continue
		if pickup is NomadXPOrb:
			var orb: NomadXPOrb = pickup as NomadXPOrb
			pickups.append({"kind": "xp", "position": orb.global_position, "value": orb.value, "age": orb.age})
		elif pickup is NomadRiftFragment:
			var fragment: NomadRiftFragment = pickup as NomadRiftFragment
			pickups.append({"kind": "fragment", "position": fragment.global_position, "value": fragment.value, "age": fragment.age})
		elif pickup is NomadSupplyPickup:
			var supply: NomadSupplyPickup = pickup as NomadSupplyPickup
			pickups.append({"kind": "supply", "position": supply.global_position, "supply_kind": supply.kind, "age": supply.age})
		elif pickup is NomadLootPickup:
			var loot: NomadLootPickup = pickup as NomadLootPickup
			pickups.append({"kind": "loot", "position": loot.global_position, "module_id": loot.module_id, "rarity": loot.rarity, "age": loot.age})
		elif pickup is NomadLootCache:
			var cache: NomadLootCache = pickup as NomadLootCache
			pickups.append({"kind": "loot_cache", "position": cache.global_position, "cache_rank": cache.cache_rank, "zone_hint": cache.zone_hint, "hold_time": cache.hold_time, "age": 0.0})
	checkpoint["pickups"] = pickups
	return checkpoint

func _resume_saved_run() -> void:
	if not _is_valid_saved_run(saved_run):
		saved_run.clear()
		_update_menu_stats()
		return
	_cancel_pending_backup()
	var checkpoint: Dictionary = saved_run.duplicate(true)
	get_tree().paused = false
	joystick.enabled = false
	joystick.reset()
	_clear_run_nodes()
	_reset_run_state()
	_spawn_player()
	for property_name: String in RUN_SAVE_PROPERTIES:
		if checkpoint.has(property_name):
			set(property_name, checkpoint[property_name])
	# V44.47 : ancienne sauvegarde = ancien placement potentiellement trop proche d'un décor.
	if dynamic_event_active:
		dynamic_event_position = world.nearest_open_area(dynamic_event_position, 30.0, 138.0, 0.74, 440.0)
	var player_data: Dictionary = checkpoint["player"]
	for property_name: String in PLAYER_SAVE_PROPERTIES:
		if player_data.has(property_name):
			player.set(property_name, player_data[property_name])
	player.global_position = world.nearest_open_area(player_data["position"], 22.0, 74.0, 0.72, 340.0)
	_limit_survival_stats()
	var options: Variant = checkpoint.get("upgrade_options", [])
	if options is Array:
		for option: Variant in options:
			if option is Dictionary and option.has_all(["id", "rarity", "multiplier", "title", "description"]):
				pending_upgrade_options.append(option)
	var enemies: Variant = checkpoint.get("enemies", [])
	if enemies is Array:
		for data: Variant in enemies:
			if data is Dictionary:
				_restore_enemy(data)
	var pickups: Variant = checkpoint.get("pickups", [])
	if pickups is Array:
		for data: Variant in pickups:
			if data is Dictionary:
				_restore_pickup(data)
	# Migration V44.35 : une ancienne partie reprise reçoit les caches du nouveau système.
	if not checkpoint.has("run_module_count"):
		_spawn_initial_loot_caches()
	_spawn_canyon_secrets()
	_refresh_dynamic_event_marker()
	world.update_streaming(player.global_position)
	_update_hud()
	_begin_run(true)
	if pending_level_choices > 0:
		_present_upgrade_if_needed()

func _restore_enemy(data: Dictionary) -> void:
	var kind: String = String(data.get("kind", ""))
	if kind not in ["blaster", "raider", "stalker", "sniper", "suppressor", "breaker", "heavy", "echo_scout", "veil_tech", "veil_guardian", "salvage_drone", "scrap_automaton", "mobile_turret", "leviathan_grinder", "phantom", "colossus", "sentinel", "marauder", "archon", "warden", "reaper", "resonator", "scrap_titan"] or typeof(data.get("position")) != TYPE_VECTOR2:
		return
	var enemy: NomadEnemy = EnemyScript.new() as NomadEnemy
	enemy.setup(kind, 1.0, bool(data.get("elite", false)), String(data.get("affix", "")))
	_configure_enemy_range(enemy)
	for property_name: String in ENEMY_SAVE_PROPERTIES:
		if data.has(property_name):
			enemy.set(property_name, data[property_name])
	if enemy.is_boss():
		enemy.global_position = world.nearest_open_area(data["position"], 30.0, 170.0, 0.76, 460.0)
	elif enemy.is_miniboss():
		enemy.global_position = world.nearest_open_area(data["position"], 28.0, 120.0, 0.72, 400.0)
	else:
		enemy.global_position = world.nearest_open_area(data["position"], 24.0, 74.0, 0.68, 320.0)
	if data.has("world_event_id"):
		enemy.set_meta("world_event_id", int(data.get("world_event_id", -1)))
		enemy.set_meta("world_event_role", String(data.get("world_event_role", "")))
	enemy.target = player
	enemy.world_nav = world
	enemy.died.connect(_on_enemy_died)
	enemy.request_shot.connect(_on_enemy_request_shot)
	enemy.damaged.connect(_on_enemy_damaged)
	enemy.phase_changed.connect(_on_boss_phase_changed)
	if enemy.has_method("set_visual_quality"):
		enemy.set_visual_quality(adaptive_quality)
	enemies_root.add_child(enemy)
	if enemy.is_boss():
		enemy.phase_two = enemy.health <= enemy.max_health * 0.5
		boss_encounters[kind] = maxi(1, int(boss_encounters.get(kind, 0)))
		boss_enemy = enemy
		boss_event_timer = 3.8
		_style_bar(boss_bar, _boss_color(kind), 5)

func _restore_pickup(data: Dictionary) -> void:
	if typeof(data.get("position")) != TYPE_VECTOR2:
		return
	var position_value: Vector2 = data["position"]
	var age_value: float = maxf(0.0, float(data.get("age", 0.0)))
	match String(data.get("kind", "")):
		"xp":
			var orb: NomadXPOrb = XPOrbScript.new() as NomadXPOrb
			orb.global_position = _safe_pickup_position(position_value, 14.0)
			orb.player = player
			orb.value = maxi(1, int(data.get("value", 1)))
			orb.age = age_value
			orb.collected.connect(_on_xp_collected)
			pickups_root.add_child(orb)
		"fragment":
			_spawn_rift_fragment(position_value, maxi(1, int(data.get("value", 1))), age_value)
		"supply":
			_spawn_supply(position_value, String(data.get("supply_kind", "med")), age_value)
		"loot":
			_spawn_loot_module(position_value, String(data.get("module_id", "field_patch")), String(data.get("rarity", "common")), age_value)
		"loot_cache":
			_spawn_loot_cache(position_value, maxi(1, int(data.get("cache_rank", 1))), String(data.get("zone_hint", "DÉSERT")), float(data.get("hold_time", 0.0)))

func _clear_run_nodes() -> void:
	# Detach immediately so caps/counts are correct in the same frame when restarting.
	for root: Node2D in [boss_hazards_root, enemies_root, projectiles_root, pickups_root, secrets_root, fx_root]:
		if root == null:
			continue
		for node: Node in root.get_children():
			root.remove_child(node)
			node.queue_free()
	if is_instance_valid(player):
		var parent: Node = player.get_parent()
		if parent != null:
			parent.remove_child(player)
		player.queue_free()
	player = null
	world_camera = null

func _spawn_player() -> void:
	player = PlayerScript.new() as NomadPlayer
	player.world_nav = world
	player.damage *= 1.0 + float(meta_damage_rank) * 0.045
	player.max_health += float(meta_health_rank) * 10.0
	player.health = player.max_health
	player.pulse_cooldown = maxf(3.0, player.pulse_cooldown - float(meta_health_rank) * 0.08)
	player.force_wave_radius += float(meta_health_rank) * 4.0
	player.critical_chance = minf(0.24, player.critical_chance + float(meta_instinct_rank) * 0.008)
	player.magnet_range += float(meta_instinct_rank) * 10.0
	player.dash_cooldown = maxf(1.75, player.dash_cooldown * (1.0 - float(meta_instinct_rank) * 0.012))
	# V44.37 : spécialisations permanentes de la Matrice.
	player.critical_multiplier += float(meta_fury_rank) * 0.05
	player.attack_interval = maxf(0.31, player.attack_interval * (1.0 - float(meta_fury_rank) * 0.012))
	player.armor = minf(0.20, player.armor + float(meta_resilience_rank) * 0.007)
	player.regeneration += float(meta_resilience_rank) * 0.045
	player.speed *= 1.0 + float(meta_scavenger_rank) * 0.012
	run_xp_multiplier = maxf(run_xp_multiplier, 1.0 + float(meta_scavenger_rank) * 0.025)
	run_fragment_bonus_chance = maxf(run_fragment_bonus_chance, float(meta_scavenger_rank) * 0.006)
	if meta_marauder_node:
		player.damage *= 1.08
		player.saber_range += 14.0
	if meta_sentinel_node:
		player.max_health += 40.0
		player.health = player.max_health
		player.armor = minf(0.30, player.armor + 0.03)
		player.force_wave_radius += 18.0
	if meta_archon_node:
		player.pulse_cooldown = maxf(3.0, player.pulse_cooldown - 0.30)
		player.magnet_range += 30.0
		player.dash_cooldown = maxf(1.70, player.dash_cooldown * 0.92)
	_apply_canyon_profile_bonuses()
	player.global_position = StylizedWorld.PLAYER_START
	player.died.connect(_on_player_died)
	player.damaged.connect(_on_player_damaged)
	player.dodged.connect(_on_player_dodged)
	player.dash_used.connect(_on_player_dash_used)
	world_entities.add_child(player)
	world_camera = Camera2D.new()
	world_camera.position_smoothing_enabled = true
	world_camera.position_smoothing_speed = 9.8
	world_camera.limit_left = 0
	world_camera.limit_top = 0
	world_camera.limit_right = int(StylizedWorld.BOUNDS.end.x)
	world_camera.limit_bottom = int(StylizedWorld.BOUNDS.end.y)
	world_camera.zoom = Vector2(0.66, 0.66)
	world_camera.enabled = true
	player.add_child(world_camera)

func _nearest_enemy_to(origin: Vector2, max_distance: float) -> NomadEnemy:
	var best: NomadEnemy = null
	var best_distance: float = max_distance * max_distance
	for node: Node in enemies_root.get_children():
		var enemy: NomadEnemy = node as NomadEnemy
		if enemy == null or not enemy.active:
			continue
		var distance: float = origin.distance_squared_to(enemy.global_position)
		if distance < best_distance:
			best_distance = distance
			best = enemy
	return best

func _update_game(delta: float) -> void:
	if not is_instance_valid(player):
		return
	run_time += delta
	autosave_timer -= delta
	if autosave_timer <= 0.0:
		autosave_timer = AUTOSAVE_INTERVAL
		_save_profile()
	player.set_touch_vector(joystick.vector)
	attack_timer -= delta
	spawn_timer -= delta
	event_timer -= delta
	skill_traction_cooldown_timer = maxf(0.0, skill_traction_cooldown_timer - delta)
	skill_surge_timer = maxf(0.0, skill_surge_timer - delta)
	skill_surge_cooldown_timer = maxf(0.0, skill_surge_cooldown_timer - delta)
	skill_surge_fx_timer = maxf(0.0, skill_surge_fx_timer - delta)
	if skill_surge_timer > 0.0 and skill_surge_fx_timer <= 0.0:
		skill_surge_fx_timer = 0.34 if adaptive_quality == QUALITY_HIGH else (0.48 if adaptive_quality == QUALITY_BALANCED else 0.70)
		_spawn_pulse_fx(Color(0.60, 0.34, 1.0, 0.30), 0.72, 0.24)
	overdrive_time = skill_surge_timer
	overdrive_meter = clampf(skill_surge_timer / maxf(0.01, _skill_surge_duration()), 0.0, 1.0)
	zone_banner_timer = maxf(0.0, zone_banner_timer - delta)
	stream_timer -= delta
	cleanup_timer -= delta
	toast_timer = maxf(0.0, toast_timer - delta)
	combo_timer = maxf(0.0, combo_timer - delta)
	if combo_timer <= 0.0:
		combo = 0
		combo_label.modulate.a = move_toward(combo_label.modulate.a, 0.0, delta * 4.0)
	if toast_timer <= 0.0:
		toast_label.modulate.a = move_toward(toast_label.modulate.a, 0.0, delta * 4.5)
	if attack_timer <= 0.0:
		attack_timer = player.attack_interval * (0.68 if skill_surge_timer > 0.0 else 1.0)
		_auto_attack()
	_update_zone_banner(delta)
	zone_logic_accumulator += delta
	if zone_logic_accumulator >= 0.125:
		var zone_step: float = zone_logic_accumulator
		zone_logic_accumulator = 0.0
		_update_zone_gameplay(zone_step)
	_update_dynamic_world_event(delta)
	if stream_timer <= 0.0:
		stream_timer = 0.22
		world.update_streaming(player.global_position)
	if cleanup_timer <= 0.0:
		cleanup_timer = 0.85
		_cleanup_distant_entities()
	_update_wave(delta)
	_update_boss_encounter(delta)
	if not wave_cleanup and wave_time_left > 8.0 and event_timer <= 0.0:
		if is_instance_valid(boss_enemy) and boss_enemy.active:
			event_timer = 999.0
		elif dynamic_event_active:
			event_timer = 999.0
		elif wave_number >= 4 and wave_number % 2 == 0 and wave_number % 5 != 0:
			_start_dynamic_world_event()
			event_timer = 999.0
		else:
			event_timer = 999.0
	_auto_force_wave()
	hud_refresh_timer -= delta
	if hud_refresh_timer <= 0.0:
		hud_refresh_timer = _hud_refresh_interval()
		_update_hud()

func _update_boss_encounter(delta: float) -> void:
	if not is_instance_valid(boss_enemy) or not boss_enemy.active or not is_instance_valid(player) or not player.active:
		return
	boss_event_timer -= delta
	if boss_event_timer > 0.0:
		return
	if boss_hazards_root.get_child_count() > 0 or boss_enemy.windup_left > 0.0:
		boss_event_timer = 0.35
		return
	var hazard: NomadBossHazard = _spawn_boss_hazard()
	if hazard == null:
		boss_event_timer = 2.2
		return
	if boss_event_count == 0:
		_show_toast("%s  •  %s" % [_boss_name(boss_enemy.kind), hazard.warning_name()])
	boss_event_count += 1
	boss_event_timer = 7.6 if boss_enemy.phase_two else 9.2

func _spawn_boss_hazard() -> NomadBossHazard:
	if not is_instance_valid(boss_enemy) or not boss_enemy.active or not is_instance_valid(player):
		return null
	var hazard: NomadBossHazard = BossHazardScript.new() as NomadBossHazard
	if not hazard.configure(boss_enemy, player, world):
		hazard.free()
		return null
	# Give the player one readable warning before the boss begins another move.
	boss_enemy.attack_timer = maxf(boss_enemy.attack_timer, hazard.warning_duration + 0.32)
	hazard.activated.connect(_on_boss_hazard_activated)
	boss_hazards_root.add_child(hazard)
	return hazard

func _on_boss_hazard_activated(kind: String) -> void:
	match kind:
		"marauder": _play_sfx(SFX_SABER_HIT_HEAVY, -19.0, 0.83, 0.87)
		"sentinel": _play_sfx(SFX_ENEMY_SHOOT, -18.0, 0.77, 0.81)
		"archon": _play_sfx(SFX_PULSE, -18.0, 0.87, 0.91)
		"warden": _play_sfx(SFX_ENEMY_SHOOT, -17.0, 1.06, 1.10)
		"reaper": _play_sfx(SFX_SABER_HIT_HEAVY, -18.0, 0.72, 0.78)
		"scrap_titan": _play_sfx(SFX_SABER_HIT_HEAVY, -17.0, 0.68, 0.74)
	_shake(2.4, 0.10)
	_haptic(21, 0.34, 0.12)

func _clear_boss_hazards() -> void:
	if boss_hazards_root == null:
		return
	for node: Node in boss_hazards_root.get_children():
		boss_hazards_root.remove_child(node)
		node.queue_free()

func _active_enemy_count() -> int:
	if enemies_root == null:
		return 0
	var count: int = 0
	for node: Node in enemies_root.get_children():
		var enemy: NomadEnemy = node as NomadEnemy
		if enemy != null and enemy.active and not enemy.is_queued_for_deletion():
			count += 1
	return count

# V44.48 — chaque ennemi consomme un budget de menace. Une vague peut donc
# contenir beaucoup de cibles légères OU quelques menaces lourdes, sans saturer
# l'écran avec les deux en même temps. Les boss ne rentrent pas dans ce budget.
func _enemy_threat_cost(enemy: NomadEnemy) -> float:
	if enemy == null or not enemy.active or enemy.is_boss():
		return 0.0
	var cost: float = 1.0
	match enemy.kind:
		"stalker": cost = 1.10
		"sniper": cost = 1.40
		"suppressor": cost = 1.45
		"heavy": cost = 2.10
		"breaker": cost = 2.35
		"echo_scout": cost = 1.30
		"veil_tech": cost = 1.80
		"veil_guardian": cost = 4.85
		"salvage_drone": cost = 1.15
		"scrap_automaton": cost = 2.25
		"mobile_turret": cost = 1.75
		"leviathan_grinder": cost = 4.90
		"phantom": cost = 3.80
		"colossus": cost = 4.50
		_: cost = 1.0
	if enemy.elite:
		cost *= 1.35
	return cost

func _active_enemy_threat() -> float:
	var total: float = 0.0
	for node: Node in enemies_root.get_children():
		var enemy: NomadEnemy = node as NomadEnemy
		if enemy != null and enemy.active and not enemy.is_queued_for_deletion():
			total += _enemy_threat_cost(enemy)
	return total

func _wave_threat_budget() -> float:
	var wave_index: float = float(maxi(0, wave_number - 1))
	var budget: float = 5.8 + minf(wave_index, 10.0) * 0.48 + maxf(0.0, wave_index - 10.0) * 0.20
	budget += minf(1.25, float(maxi(0, level - 1)) * 0.065)
	match _wave_pattern():
		"chasse": budget += 0.8
		"barrage": budget += 0.55
		"bastion": budget += 0.35
		"boss": budget -= 1.15
	# V47.3: les couloirs du Canyon réduisent naturellement les possibilités
	# d'esquive. On baisse légèrement la densité sans affaiblir les ennemis.
	if _player_zone() == "CANYON DES ÉCHOS":
		budget -= 0.65
	elif _player_zone() == "CIMETIÈRE D’ÉPAVES":
		budget -= 0.40
	return clampf(budget, 5.2, 15.5)

func _count_nearby_enemies(origin: Vector2, radius: float) -> int:
	var radius_sq: float = radius * radius
	var count: int = 0
	for node: Node in enemies_root.get_children():
		var enemy: NomadEnemy = node as NomadEnemy
		if enemy != null and enemy.active and origin.distance_squared_to(enemy.global_position) <= radius_sq:
			count += 1
	return count

func _count_nearby_supplies(origin: Vector2, radius: float, preferred_kind: String = "") -> int:
	if pickups_root == null:
		return 0
	var radius_sq: float = radius * radius
	var count: int = 0
	for node: Node in pickups_root.get_children():
		var supply: NomadSupplyPickup = node as NomadSupplyPickup
		if supply != null and not supply.is_queued_for_deletion():
			if preferred_kind.is_empty() or supply.kind == preferred_kind:
				if origin.distance_squared_to(supply.global_position) <= radius_sq:
					count += 1
	return count

func _request_emergency_support(_zone: String = "") -> void:
	if not is_instance_valid(player):
		return
	var health_ratio: float = player.health / maxf(1.0, player.max_health)
	var kind: String = "med"
	if health_ratio >= 0.26 and player.max_shield > 0.0 and player.shield < player.max_shield * 0.28:
		kind = "shield"
	elif health_ratio >= 0.38 and player.pulse_timer > 1.8 and player.dash_timer > 0.9:
		kind = "charge"
	_spawn_supply(player.global_position + Vector2(rng.randf_range(-58.0, 58.0), rng.randf_range(-40.0, 40.0)), kind)
	survival_relief_timer = 20.0 if kind == "med" else 18.0
	_show_toast("BALISE NOMADE  •  RAVITAILLEMENT D’URGENCE")

func _player_zone() -> String:
	if not is_instance_valid(player):
		return ""
	return world.zone_name(player.global_position)

func _zone_center(zone: String) -> Vector2:
	match zone:
		"CAMP NOMADE":
			return Vector2(500.0, 520.0)
		"RAFFINERIE":
			return Vector2(2520.0, 520.0)
		"ÉPAVE DU PÈLERIN":
			return Vector2(1600.0, 1475.0)
		"AVANT-POSTE":
			return Vector2(2460.0, 1480.0)
		"PLAINE CENTRALE":
			return Vector2(1536.0, 1024.0)
		"CANYON DES ÉCHOS":
			return Vector2(3600.0, 1050.0)
		"CIMETIÈRE D’ÉPAVES":
			return Vector2(2050.0, 2570.0)
		_:
			return StylizedWorld.PLAYER_START

func _zone_color(zone: String) -> Color:
	match zone:
		"CAMP NOMADE":
			return Color(0.56, 0.96, 0.72)
		"ÉPAVE DU PÈLERIN":
			return Color(1.0, 0.82, 0.48)
		"AVANT-POSTE":
			return Color(1.0, 0.84, 0.52)
		"RAFFINERIE":
			return Color(0.44, 0.90, 1.0)
		"PLAINE CENTRALE":
			return Color(0.86, 0.73, 1.0)
		"CANYON DES ÉCHOS":
			return Color(0.88, 0.58, 0.38)
		"CIMETIÈRE D’ÉPAVES":
			return Color(0.63, 0.72, 0.74)
		_:
			return Color(0.78, 0.80, 0.82)

func _zone_mood_color(zone: String) -> Color:
	match zone:
		"CAMP NOMADE": return Color(0.30, 0.44, 0.34, 0.060)
		"ÉPAVE DU PÈLERIN": return Color(0.48, 0.33, 0.16, 0.056)
		"AVANT-POSTE": return Color(0.38, 0.30, 0.14, 0.048)
		"RAFFINERIE": return Color(0.16, 0.33, 0.40, 0.058)
		"PLAINE CENTRALE": return Color(0.26, 0.20, 0.34, 0.050)
		"CANYON DES ÉCHOS": return Color(0.45, 0.24, 0.18, 0.060)
		"CIMETIÈRE D’ÉPAVES": return Color(0.20, 0.24, 0.28, 0.072)
		_: return Color(0.0, 0.0, 0.0, 0.0)

func _zone_banner_subtitle(zone: String) -> String:
	match zone:
		"CAMP NOMADE": return "zone de répit • soins légers et récupération"
		"ÉPAVE DU PÈLERIN": return "carcasse fracturée • couloirs de chasse et embuscades"
		"AVANT-POSTE": return "lignes de tir courtes • pression frontale"
		"RAFFINERIE": return "secteur industriel • feu nourri et silhouettes lourdes"
		"PLAINE CENTRALE": return "terrain neutre • combat ouvert et fragments opportuns"
		"CANYON DES ÉCHOS": return "goulet minéral • visée longue et traversées serrées"
		"CIMETIÈRE D’ÉPAVES": return "acier brisé • hostiles mécaniques et lecture plus dense"
		_: return ""

func _zone_hint_text(zone: String) -> String:
	match zone:
		"CAMP NOMADE": return "APPUI LOCAL • le camp te soigne si la pression reste faible"
		"ÉPAVE DU PÈLERIN": return "CONSEIL • garde du recul, les approches se ferment vite"
		"AVANT-POSTE": return "CONSEIL • coupe les angles pour casser les lignes de tir"
		"RAFFINERIE": return "ALERTE • présence accrue de profils lourds et suppressifs"
		"PLAINE CENTRALE": return "OPPORTUNITÉ • des fragments peuvent émerger sous pression"
		"CANYON DES ÉCHOS": return "ALERTE • visibilité longue, attention aux percées à distance"
		"CIMETIÈRE D’ÉPAVES": return "ALERTE • le secteur concentre drones, tourelles et automates"
		_: return ""

func _show_zone_banner(zone: String) -> void:
	if zone_banner_panel == null or zone_banner_label == null or zone_banner_subtitle_label == null or zone.is_empty():
		return
	zone_banner_panel.visible = true
	zone_banner_label.text = zone
	zone_banner_label.add_theme_color_override("font_color", _zone_color(zone).lightened(0.40))
	zone_banner_subtitle_label.text = _zone_banner_subtitle(zone)
	var accent: Color = _zone_color(zone)
	zone_banner_panel.add_theme_stylebox_override("panel", _style_panel(Color(0.014, 0.020, 0.028, 0.84), Color(accent.r, accent.g, accent.b, 0.46), 18, 8))

func _build_zone_objective_markers() -> void:
	# Le marqueur de monde ne sert plus qu’aux événements du Rift.
	mission_markers.clear()
	_add_zone_objective_marker("dynamic", Vector2(1536.0, 1024.0), "SIGNAL DU RIFT", Color(0.84, 0.48, 1.0), 82.0)
	var dynamic_marker: NomadZoneObjectiveMarker = _objective_marker("dynamic")
	if dynamic_marker != null:
		dynamic_marker.set_status(false, 0.0, 1.0, "")

func _add_zone_objective_marker(key: String, world_position: Vector2, title: String, color: Color, marker_radius: float) -> void:
	var marker: NomadZoneObjectiveMarker = ZoneObjectiveMarkerScript.new() as NomadZoneObjectiveMarker
	marker.name = "%sObjective" % key.capitalize()
	marker.global_position = world_position
	marker.configure(title, color, marker_radius)
	mission_markers_root.add_child(marker)
	mission_markers[key] = marker

func _objective_marker(key: String) -> NomadZoneObjectiveMarker:
	var candidate: Variant = mission_markers.get(key)
	if candidate is NomadZoneObjectiveMarker:
		return candidate as NomadZoneObjectiveMarker
	return null

func _on_zone_changed(zone: String) -> void:
	active_zone_name = zone
	zone_stay_timer = 0.0
	zone_banner_timer = 3.2
	_show_zone_banner(zone)
	match zone:
		"CAMP NOMADE":
			camp_support_timer = minf(camp_support_timer, 1.2)
		_:
			pass

func _update_zone_gameplay(delta: float) -> void:
	if not is_instance_valid(player):
		return
	var zone: String = _player_zone()
	if zone != active_zone_name:
		_on_zone_changed(zone)
	zone_stay_timer += delta
	camp_support_timer = maxf(0.0, camp_support_timer - delta)
	central_supply_timer = maxf(0.0, central_supply_timer - delta)
	survival_relief_timer = maxf(0.0, survival_relief_timer - delta)
	if zone == "CAMP NOMADE" and camp_support_timer <= 0.0:
		camp_support_timer = 7.5
		var nearby_threats: int = _count_nearby_enemies(player.global_position, 300.0)
		if wave_number < 8 or nearby_threats == 0:
			player.heal(minf(8.0, maxf(4.0, player.max_health * 0.015)))
			player.restore_shield(5.0)
		if player.health < player.max_health * 0.55 and rng.randf() < 0.16 and nearby_threats <= 2:
			_spawn_supply(player.global_position + Vector2(rng.randf_range(-55.0, 55.0), rng.randf_range(-30.0, 48.0)), "med")
	elif zone == "PLAINE CENTRALE" and central_supply_timer <= 0.0 and zone_stay_timer >= 8.0 and _active_enemy_count() >= 4 and rng.randf() < delta * 0.45:
		central_supply_timer = 18.0
		_spawn_rift_fragment(player.global_position + Vector2(rng.randf_range(-70.0, 70.0), rng.randf_range(-55.0, 55.0)), 1)
	elif zone == "AVANT-POSTE" and central_supply_timer <= 0.0 and zone_stay_timer >= 10.0 and _count_nearby_enemies(player.global_position, 255.0) <= 3 and rng.randf() < delta * 0.36:
		central_supply_timer = 22.0
		_spawn_supply(player.global_position + Vector2(rng.randf_range(-62.0, 62.0), rng.randf_range(-42.0, 44.0)), "charge")
	elif zone == "CIMETIÈRE D’ÉPAVES" and central_supply_timer <= 0.0 and zone_stay_timer >= 11.0 and _count_nearby_enemies(player.global_position, 255.0) <= 3 and rng.randf() < delta * 0.30:
		central_supply_timer = 24.0
		_spawn_supply(player.global_position + Vector2(rng.randf_range(-58.0, 58.0), rng.randf_range(-40.0, 44.0)), "shield" if rng.randf() < 0.55 else "charge")
	if survival_relief_timer <= 0.0 and player.health < player.max_health * 0.34 and _count_nearby_supplies(player.global_position, 180.0, "med") <= 0:
		_request_emergency_support(zone)
	_update_zone_status_text(zone)

func _update_zone_status_text(zone: String) -> void:
	if danger_label == null:
		return
	if dynamic_event_active:
		danger_label.visible = true
		danger_label.text = _dynamic_event_hud_text()
		danger_label.add_theme_color_override("font_color", Color("d8b5ff"))
	elif zone_stay_timer <= 5.0:
		var hint: String = _zone_hint_text(zone)
		danger_label.visible = not hint.is_empty()
		danger_label.text = hint
		danger_label.add_theme_color_override("font_color", _zone_color(zone).lightened(0.22))
	else:
		danger_label.visible = false
		danger_label.text = ""

func _update_wave(delta: float) -> void:
	if wave_cleanup:
		if _active_enemy_count() <= 0:
			if wave_intermission < 0.0:
				wave_intermission = 4.0
				player.heal(minf(18.0, player.max_health * 0.035))
				player.restore_shield(10.0)
				_show_toast("VAGUE %d TERMINÉE  •  RÉPIT" % wave_number)
				_haptic(24, 0.30, 0.18)
			else:
				wave_intermission = maxf(0.0, wave_intermission - delta)
				if wave_intermission <= 0.0:
					_start_next_wave()
		return
	wave_time_left = maxf(0.0, wave_time_left - delta)
	if wave_time_left <= 0.0:
		if dynamic_event_active:
			_cancel_dynamic_world_event("SIGNAL CLOS  •  FIN DE VAGUE")
		wave_cleanup = true
		wave_intermission = -1.0
		_show_toast("TEMPS ÉCOULÉ  •  ÉLIMINE LES DERNIERS CONTACTS")
		return
	var zone: String = _player_zone()
	var density_bonus: int = 0
	match zone:
		"PLAINE CENTRALE": density_bonus = 2
		"RAFFINERIE": density_bonus = 3
		"AVANT-POSTE": density_bonus = 2
		"CAMP NOMADE": density_bonus = -2
		"CIMETIÈRE D’ÉPAVES": density_bonus = 1
		"DÉSERT OUVERT": density_bonus = -1
		_: density_bonus = 0
	# V44.48 : la pression n'est plus pilotée uniquement par le nombre de corps.
	# Le budget de menace évite par exemple 15 ennemis + plusieurs Briseurs + élites
	# au même instant. La zone influe encore légèrement sur la densité maximale.
	var pattern: String = _wave_pattern()
	var health_relief: float = 0.0
	if is_instance_valid(player):
		var health_ratio: float = player.health / maxf(1.0, player.max_health)
		if health_ratio < 0.60:
			health_relief = (0.60 - health_ratio) / 0.60
			if dynamic_event_active:
				health_relief *= 0.75
	var count_cap: int = 7 + mini(8, floori(float(maxi(0, wave_number - 1)) * 0.42)) + clampi(density_bonus, -1, 1)
	if pattern == "chasse": count_cap += 1
	elif pattern == "boss": count_cap -= 2
	count_cap -= int(floor(health_relief * 2.4))
	count_cap = clampi(count_cap, 5, MAX_ACTIVE_ENEMIES)
	var threat_budget: float = _wave_threat_budget() * (1.0 - health_relief * 0.16)
	if _active_enemy_count() < count_cap and _active_enemy_threat() < threat_budget and spawn_timer <= 0.0:
		var spawn_pressure: float = 0.0
		if zone == "RAFFINERIE":
			spawn_pressure = 0.035
		elif zone == "PLAINE CENTRALE" or zone == "AVANT-POSTE":
			spawn_pressure = 0.020
		var wave_pressure: float = minf(0.16, float(maxi(wave_number - 1, 0)) * 0.008)
		var spawn_interval: float = 0.92 - wave_pressure - minf(0.055, float(level - 1) * 0.0025) - spawn_pressure
		spawn_interval *= 1.0 + health_relief * 0.22
		if pattern == "chasse": spawn_interval *= 0.78
		elif pattern == "barrage": spawn_interval *= 0.84
		elif pattern == "bastion": spawn_interval *= 0.92
		elif pattern == "boss": spawn_interval *= 1.08
		spawn_timer = maxf(0.42, spawn_interval)
		_spawn_enemy()

func _wave_pattern() -> String:
	# Derived from the saved wave number so older checkpoints keep their wave.
	if wave_number <= 1:
		return "normal"
	match wave_number % 5:
		2: return "chasse"
		3: return "barrage"
		4: return "bastion"
		0: return "boss"
		_: return "normal"

func _wave_pattern_label() -> String:
	match _wave_pattern():
		"chasse": return "CHASSE • PISTEURS"
		"barrage": return "BARRAGE • SUPPRESSEURS"
		"bastion": return "BASTION • BRISEURS"
		"boss": return "BRÈCHE • BOSS"
		_: return ""

func _configure_enemy_range(enemy: NomadEnemy) -> void:
	# V44.40: every ranged doctrine keeps a distinct preferred engagement distance.
	match enemy.kind:
		"blaster":
			enemy.ranged_attack_range = minf(370.0, 285.0 + float(maxi(0, wave_number - 15)) * 1.5)
			if _wave_pattern() == "barrage":
				enemy.ranged_attack_range += 35.0
		"sniper":
			enemy.ranged_attack_range = minf(565.0, 505.0 + float(maxi(0, wave_number - 6)) * 1.2)
		"suppressor":
			enemy.ranged_attack_range = minf(390.0, 345.0 + float(maxi(0, wave_number - 5)) * 0.8)
		"phantom":
			enemy.ranged_attack_range = minf(485.0, 430.0 + float(maxi(0, wave_number - 6)) * 0.8)
		"veil_tech":
			enemy.ranged_attack_range = minf(400.0, 350.0 + float(maxi(0, wave_number - 5)) * 0.75)
		"salvage_drone":
			enemy.ranged_attack_range = minf(365.0, 330.0 + float(maxi(0, wave_number - 5)) * 0.55)
		"mobile_turret":
			enemy.ranged_attack_range = minf(475.0, 430.0 + float(maxi(0, wave_number - 6)) * 0.65)

func _start_next_wave() -> void:
	wave_number += 1
	wave_duration = minf(68.0, 50.0 + float(wave_number - 1) * 1.5)
	wave_time_left = wave_duration
	wave_cleanup = false
	wave_intermission = -1.0
	spawn_timer = 0.0
	var wave_zone: String = _player_zone()
	var canyon_wave: bool = wave_zone == "CANYON DES ÉCHOS"
	var graveyard_wave: bool = wave_zone == "CIMETIÈRE D’ÉPAVES"
	var event_chance: float = 0.30 if canyon_wave else (0.34 if graveyard_wave else 0.42)
	event_timer = rng.randf_range(26.0, 33.0) if wave_number >= 4 and wave_number % 5 != 0 and rng.randf() < event_chance else 999.0
	var opening_cap: int = 5 if canyon_wave or graveyard_wave else 6
	var opening_count: int = mini(opening_cap, 3 + floori(float(wave_number) * 0.38))
	for _i: int in range(opening_count):
		_spawn_enemy()
	if wave_number >= 7 and wave_number % 7 == 0:
		if graveyard_wave:
			_spawn_enemy("salvage_drone", true)
			_spawn_enemy("scrap_automaton" if wave_number >= 9 else "mobile_turret", true)
		elif wave_number >= 9:
			_spawn_enemy("stalker", true)
			_spawn_enemy("suppressor", true)
		else:
			_spawn_enemy("raider", true)
			_spawn_enemy("blaster", true)
	var miniboss_due: bool = (canyon_wave and wave_number >= 8 and wave_number % 8 == 0 and wave_number % 5 != 0) or (graveyard_wave and wave_number >= 7 and wave_number % 7 == 0 and wave_number % 5 != 0) or ((not canyon_wave and not graveyard_wave) and wave_number >= 6 and wave_number % 6 == 0 and wave_number % 5 != 0)
	if miniboss_due:
		call_deferred("_spawn_wave_miniboss")
	var wave_message: String = _wave_pattern_label()
	if wave_number >= 7 and wave_number % 7 == 0:
		wave_message += " • ÉLITES"
	_show_toast("VAGUE %d  •  %s" % [wave_number, wave_message] if not wave_message.is_empty() else "VAGUE %d  •  %d s" % [wave_number, roundi(wave_duration)])
	if wave_number % 5 == 0:
		call_deferred("_spawn_wave_boss")

func _enemy_spawn_spacing(enemy_kind: String) -> float:
	if enemy_kind in BOSS_KINDS:
		return 220.0
	if enemy_kind in MINIBOSS_KINDS:
		return 156.0
	match enemy_kind:
		"heavy", "breaker", "veil_guardian", "scrap_automaton", "mobile_turret", "leviathan_grinder": return 112.0
		"stalker", "echo_scout", "salvage_drone": return 74.0
		"sniper", "suppressor", "veil_tech": return 88.0
		_: return 82.0

func _spawn_position_score(candidate: Vector2, spacing_radius: float) -> float:
	var min_distance: float = 99999.0
	var nearby_count: int = 0
	for node: Node in enemies_root.get_children():
		var other: NomadEnemy = node as NomadEnemy
		if other == null or not other.active or other.is_queued_for_deletion():
			continue
		var distance: float = candidate.distance_to(other.global_position)
		min_distance = minf(min_distance, distance)
		if distance < spacing_radius * 1.18:
			nearby_count += 1
	if min_distance > 90000.0:
		min_distance = spacing_radius * 2.1
	var player_distance: float = candidate.distance_to(player.global_position)
	var distance_score: float = clampf(player_distance, 420.0, 860.0) * 0.06
	return min_distance - float(nearby_count) * 36.0 + distance_score

func _find_spawn_position(enemy_kind: String, spawn_radius: float, clearance_radius: float, min_open_ratio: float, spawn_override: Variant = null) -> Vector2:
	if typeof(spawn_override) == TYPE_VECTOR2:
		var override_position: Vector2 = spawn_override
		return world.nearest_open_area(override_position, spawn_radius, clearance_radius, min_open_ratio, 460.0 if enemy_kind in BOSS_KINDS else 360.0)
	var best_position: Vector2 = world.random_open_far(player.global_position, 420.0, 820.0, rng, spawn_radius, clearance_radius, min_open_ratio)
	var best_score: float = -INF
	var spacing_radius: float = _enemy_spawn_spacing(enemy_kind)
	var attempts: int = 12 if adaptive_quality != QUALITY_LOW else 8
	for _i: int in range(attempts):
		var candidate: Vector2 = world.random_open_far(player.global_position, 420.0, 820.0, rng, spawn_radius, clearance_radius, min_open_ratio)
		var score: float = _spawn_position_score(candidate, spacing_radius)
		if score > best_score:
			best_score = score
			best_position = candidate
	return best_position

func _spawn_enemy(force_kind: String = "", force_elite: bool = false, spawn_override: Variant = null, forced_affix: String = "") -> NomadEnemy:
	if not is_instance_valid(player):
		return null
	if _active_enemy_count() >= MAX_ACTIVE_ENEMIES and force_kind not in BOSS_KINDS and force_kind not in MINIBOSS_KINDS:
		return null
	var enemy: NomadEnemy = EnemyScript.new() as NomadEnemy
	var roll: float = rng.randf()
	var enemy_kind: String = force_kind
	if enemy_kind.is_empty():
		var zone: String = world.zone_name(player.global_position)
		enemy_kind = "blaster"
		var pattern: String = _wave_pattern()
		# Wave doctrine takes priority, then local zone ecology refines normal waves.
		if pattern == "chasse":
			if zone == "CIMETIÈRE D’ÉPAVES":
				enemy_kind = "salvage_drone" if roll < 0.62 else "scrap_automaton"
			elif wave_number >= 4 and roll < 0.34:
				enemy_kind = "stalker"
			elif roll < 0.82:
				enemy_kind = "raider"
		elif pattern == "barrage":
			if zone == "CIMETIÈRE D’ÉPAVES":
				enemy_kind = "mobile_turret" if roll < 0.58 else "salvage_drone"
			elif wave_number >= 6 and roll < 0.18:
				enemy_kind = "sniper"
			elif wave_number >= 4 and roll < 0.50:
				enemy_kind = "suppressor"
			else:
				enemy_kind = "blaster"
		elif pattern == "bastion":
			if zone == "CIMETIÈRE D’ÉPAVES":
				enemy_kind = "scrap_automaton" if roll < 0.68 else "mobile_turret"
			elif wave_number >= 6 and roll < 0.34:
				enemy_kind = "breaker"
			elif level >= 4 and roll < 0.74:
				enemy_kind = "heavy"
			else:
				enemy_kind = "blaster"
		else:
			match zone:
				"CAMP NOMADE":
					if wave_number >= 8 and roll < 0.14:
						enemy_kind = "stalker"
					else:
						enemy_kind = "raider" if roll < 0.65 else "blaster"
				"ÉPAVE DU PÈLERIN":
					if wave_number >= 4 and roll < 0.34:
						enemy_kind = "stalker"
					elif wave_number >= 6 and roll > 0.90:
						enemy_kind = "breaker"
					elif roll < 0.70:
						enemy_kind = "raider"
					else:
						enemy_kind = "blaster"
				"AVANT-POSTE":
					if wave_number >= 6 and roll < 0.18:
						enemy_kind = "sniper"
					elif wave_number >= 4 and roll < 0.48:
						enemy_kind = "suppressor"
					elif level >= 4 and roll > 0.92:
						enemy_kind = "heavy"
					elif roll < 0.80:
						enemy_kind = "blaster"
					else:
						enemy_kind = "raider"
				"RAFFINERIE":
					if wave_number >= 5 and roll < 0.28:
						enemy_kind = "breaker"
					elif wave_number >= 4 and roll < 0.54:
						enemy_kind = "suppressor"
					elif level >= 4 and roll < 0.76:
						enemy_kind = "heavy"
					elif wave_number >= 7 and roll > 0.93:
						enemy_kind = "sniper"
					else:
						enemy_kind = "blaster"
				"CANYON DES ÉCHOS":
					if wave_number >= 4 and roll < 0.24:
						enemy_kind = "echo_scout"
					elif wave_number >= 5 and roll < 0.40:
						enemy_kind = "veil_tech"
					elif wave_number >= 7 and roll < 0.54:
						enemy_kind = "sniper"
					elif wave_number >= 8 and roll < 0.64:
						enemy_kind = "breaker"
					elif roll < 0.82:
						enemy_kind = "stalker"
					elif roll < 0.93:
						enemy_kind = "raider"
					else:
						enemy_kind = "blaster"
				"CIMETIÈRE D’ÉPAVES":
					if wave_number >= 2 and roll < 0.34:
						enemy_kind = "salvage_drone"
					elif wave_number >= 3 and roll < 0.61:
						enemy_kind = "mobile_turret"
					elif wave_number >= 4 and roll < 0.90:
						enemy_kind = "scrap_automaton"
					else:
						enemy_kind = "leviathan_grinder" if wave_number >= 8 and roll > 0.97 else "scrap_automaton"
				"PLAINE CENTRALE":
					if wave_number >= 4 and roll < 0.16:
						enemy_kind = "stalker"
					elif wave_number >= 5 and roll < 0.31:
						enemy_kind = "suppressor"
					elif wave_number >= 7 and roll > 0.92:
						enemy_kind = "breaker"
					elif level >= 4 and roll < 0.43:
						enemy_kind = "heavy"
					elif roll < 0.67:
						enemy_kind = "raider"
					else:
						enemy_kind = "blaster"
				_:
					if wave_number >= 6 and roll < 0.14:
						enemy_kind = "sniper"
					elif wave_number >= 4 and roll < 0.34:
						enemy_kind = "stalker"
					elif level >= 4 and roll > 0.92:
						enemy_kind = "heavy"
					elif roll < 0.62:
						enemy_kind = "raider"
	# Échelle séparée du nombre de KO : un bon joueur ne fait plus exploser la
	# difficulté juste parce qu'il nettoie vite. La menace suit surtout la vague.
	var wave_index: float = float(maxi(wave_number - 1, 0))
	var early_curve: float = minf(wave_index, 8.0) * 0.048
	var late_curve: float = maxf(0.0, wave_index - 8.0) * 0.029
	var level_curve: float = minf(22.0, float(maxi(level - 1, 0))) * 0.013
	var difficulty: float = clampf(0.90 + early_curve + late_curve + level_curve, 0.90, 4.6)
	var elite_chance: float = minf(0.22, 0.025 + float(level) * 0.0042 + maxf(0.0, wave_index - 8.0) * 0.0012)
	if _wave_pattern() == "boss": elite_chance = minf(0.28, elite_chance + 0.055)
	var elite_roll: bool = false if enemy_kind in BOSS_KINDS or enemy_kind in MINIBOSS_KINDS else (force_elite or (level >= 4 and rng.randf() < elite_chance))
	var affix: String = forced_affix
	if elite_roll and affix.is_empty():
		var affixes: Array[String] = ["swift", "bulwark", "overcharged", "void"]
		affix = affixes[rng.randi_range(0, affixes.size() - 1)]
	enemy.setup(enemy_kind, difficulty, elite_roll, affix)
	_configure_enemy_range(enemy)
	if enemy_kind not in BOSS_KINDS:
		enemy.attack_timer = maxf(enemy.attack_timer, rng.randf_range(0.12, 0.68))
		enemy.role_action_timer = maxf(enemy.role_action_timer, rng.randf_range(0.20, 1.05) if enemy_kind not in MINIBOSS_KINDS else rng.randf_range(0.55, 1.35))
		if elite_roll:
			enemy.role_action_timer += rng.randf_range(0.10, 0.35)
	# Les dégâts augmentent plus doucement que les PV au début, mais continuent à
	# progresser en fin de run pour éviter le personnage pratiquement immortel.
	var damage_curve: float = 0.94 + minf(wave_index, 10.0) * 0.024 + minf(maxf(0.0, wave_index - 10.0), 15.0) * 0.014 + maxf(0.0, wave_index - 25.0) * 0.018
	damage_curve = minf(damage_curve, 3.6)
	enemy.damage *= damage_curve
	if enemy_kind in BOSS_KINDS:
		var boss_health_bonus: float = 1.06 + minf(0.44, float(wave_number) * 0.010)
		enemy.max_health *= boss_health_bonus
		enemy.health = enemy.max_health
	enemy.target = player
	enemy.world_nav = world
	var spawn_radius: float = 24.0
	var clearance_radius: float = 76.0
	var min_open_ratio: float = 0.68
	if enemy_kind in BOSS_KINDS:
		spawn_radius = 30.0
		clearance_radius = 178.0
		min_open_ratio = 0.78
	elif enemy_kind in MINIBOSS_KINDS:
		spawn_radius = 28.0
		clearance_radius = 126.0
		min_open_ratio = 0.73
	elif enemy_kind in ["heavy", "breaker", "veil_guardian", "scrap_automaton", "mobile_turret", "leviathan_grinder"]:
		spawn_radius = 26.0
		clearance_radius = 90.0
		min_open_ratio = 0.68
	enemy.global_position = _find_spawn_position(enemy_kind, spawn_radius, clearance_radius, min_open_ratio, spawn_override)
	enemy.died.connect(_on_enemy_died)
	enemy.request_shot.connect(_on_enemy_request_shot)
	enemy.damaged.connect(_on_enemy_damaged)
	enemy.phase_changed.connect(_on_boss_phase_changed)
	if enemy.has_method("set_visual_quality"):
		enemy.set_visual_quality(adaptive_quality)
	enemies_root.add_child(enemy)
	return enemy

func _auto_attack() -> void:
	var available: Array[NomadEnemy] = []
	var range_sq: float = player.saber_range * player.saber_range
	for node: Node in enemies_root.get_children():
		var enemy: NomadEnemy = node as NomadEnemy
		if enemy != null and enemy.active and player.global_position.distance_squared_to(enemy.global_position) <= range_sq:
			available.append(enemy)
	if available.is_empty():
		return
	available.sort_custom(_enemy_distance_less)
	var primary: NomadEnemy = available[0]
	var attack_dir: Vector2 = (primary.global_position - player.global_position).normalized()
	player.play_attack(primary.global_position)
	_spawn_saber_slash_fx(player.global_position, attack_dir, player.saber_range, player.saber_arc_degrees, false)
	var max_targets: int = mini(2 + maxi(0, player.multishot_count - 1), available.size())
	var hit_count: int = 0
	var cone_cos: float = cos(deg_to_rad(player.saber_arc_degrees))
	for enemy: NomadEnemy in available:
		if hit_count >= max_targets:
			break
		var to_enemy: Vector2 = enemy.global_position - player.global_position
		if to_enemy.length_squared() <= 0.01:
			continue
		var dir: Vector2 = to_enemy.normalized()
		if dir.dot(attack_dir) < cone_cos:
			continue
		var surge_damage_multiplier: float = 1.36 if skill_surge_timer > 0.0 else 1.0
		var surge_crit_bonus: float = 0.12 if skill_surge_timer > 0.0 else 0.0
		var slash_damage: float = player.damage * surge_damage_multiplier * (1.0 + minf(0.16, float(combo) * 0.004))
		var was_critical: bool = rng.randf() < minf(0.72, player.critical_chance + surge_crit_bonus)
		if was_critical:
			slash_damage *= player.critical_multiplier
		enemy.take_damage(slash_damage, was_critical)
		if is_instance_valid(enemy) and enemy.active:
			enemy.apply_knockback(player.global_position, 440.0 if was_critical else 315.0)
		if was_critical:
			_shake(3.1, 0.065)
		hit_count += 1
	_play_sfx(SFX_SABER_SWING, -17.0, 0.98, 1.02)


func _enemy_distance_less(a: NomadEnemy, b: NomadEnemy) -> bool:
	if not is_instance_valid(player):
		return false
	return player.global_position.distance_squared_to(a.global_position) < player.global_position.distance_squared_to(b.global_position)

func _spawn_projectile(origin: Vector2, target: Node2D, damage: float, enemy_shot: bool, direction_override: Vector2 = Vector2.ZERO, tint_override: Color = Color(1.0, 0.18, 0.10), style_override: String = "standard") -> NomadProjectile:
	if projectiles_root.get_child_count() >= MAX_ACTIVE_PROJECTILES:
		var oldest: Node = projectiles_root.get_child(0)
		if oldest != null:
			projectiles_root.remove_child(oldest)
			oldest.queue_free()
	var shot: NomadProjectile = ProjectileScript.new() as NomadProjectile
	shot.global_position = origin
	shot.target = target
	shot.world_nav = world
	shot.damage = damage
	shot.enemy_shot = enemy_shot
	shot.tint_color = tint_override
	shot.visual_style = style_override
	shot.direction = direction_override.normalized() if direction_override.length_squared() > 0.001 else ((target.global_position - origin).normalized() if is_instance_valid(target) else Vector2.RIGHT)
	shot.speed = 855.0 if enemy_shot else 830.0
	shot.impact.connect(_on_projectile_impact)
	projectiles_root.add_child(shot)
	return shot

func _enemy_projectile_color(enemy: NomadEnemy) -> Color:
	if enemy.kind == "sniper": return Color(0.50, 0.78, 0.90)
	if enemy.kind == "suppressor": return Color(0.92, 0.53, 0.25)
	if enemy.kind == "phantom": return Color(0.50, 0.70, 0.88)
	if enemy.kind == "warden": return Color(0.40, 0.78, 0.86)
	if enemy.kind == "veil_tech": return Color(0.94, 0.60, 0.28)
	if enemy.kind == "salvage_drone": return Color(0.28, 0.82, 0.86)
	if enemy.kind == "mobile_turret": return Color(0.84, 0.61, 0.30)
	if enemy.kind == "scrap_titan": return Color(0.90, 0.52, 0.22)
	if enemy.kind == "sentinel": return Color(0.66, 0.52, 0.86)
	if enemy.affix == "void": return Color(0.62, 0.46, 0.82)
	if enemy.affix == "overcharged": return Color(0.96, 0.48, 0.24)
	return Color(0.88, 0.34, 0.22)

func _enemy_projectile_style(enemy: NomadEnemy) -> String:
	if enemy.kind == "sniper": return "sniper"
	if enemy.kind == "suppressor": return "suppressor"
	if enemy.kind == "phantom": return "phase"
	if enemy.kind == "warden": return "null"
	if enemy.kind == "veil_tech": return "overcharged"
	if enemy.kind == "salvage_drone": return "scrap"
	if enemy.kind == "mobile_turret": return "turret"
	if enemy.kind == "scrap_titan": return "titan"
	if enemy.affix == "void": return "void"
	if enemy.affix == "overcharged": return "overcharged"
	return "standard"

func _on_enemy_request_shot(enemy: NomadEnemy, target: Node2D) -> void:
	if not is_instance_valid(enemy) or not is_instance_valid(target):
		return
	var direction: Vector2 = (target.global_position - enemy.global_position).normalized()
	if enemy.kind == "sentinel" and enemy.windup_direction.length_squared() > 0.01:
		direction = enemy.windup_direction
	elif enemy.kind in ["blaster", "sniper", "suppressor", "phantom", "veil_tech", "salvage_drone", "mobile_turret"] and enemy.role_locked_direction.length_squared() > 0.01:
		direction = enemy.role_locked_direction
	elif enemy.kind == "warden" and enemy.windup_direction.length_squared() > 0.01:
		direction = enemy.windup_direction
	var origin: Vector2 = enemy.global_position + direction * 22.0 + Vector2(0.0, -6.0)
	enemy.play_fire_recoil(direction)
	var muzzle_color: Color = _enemy_projectile_color(enemy)
	var muzzle_style: String = _enemy_projectile_style(enemy)
	_spawn_muzzle(origin, direction.angle(), true, muzzle_color, muzzle_style)
	if enemy.kind == "sentinel":
		var violet: Color = Color(0.74, 0.42, 1.0)
		if enemy.windup_pattern == "sniper":
			var sniper_bolt: NomadProjectile = _spawn_projectile(origin, target, enemy.damage * 1.20, true, direction, violet, "sniper")
			sniper_bolt.speed = 1170.0
		elif enemy.windup_pattern == "rails":
			for offset: float in [-38.0, 38.0]:
				var rail_origin: Vector2 = origin + direction.orthogonal() * offset
				var rail_bolt: NomadProjectile = _spawn_projectile(rail_origin, target, enemy.damage * 0.85, true, direction, violet, "rail")
				rail_bolt.speed = 970.0
		else:
			var hp_ratio: float = enemy.health / maxf(1.0, enemy.max_health)
			var spreads: Array[float] = [-0.18, 0.0, 0.18]
			if hp_ratio <= 0.55:
				spreads = [-0.30, -0.15, 0.0, 0.15, 0.30]
			for spread: float in spreads:
				var spread_direction: Vector2 = direction.rotated(spread)
				_spawn_projectile(origin, target, enemy.damage * (0.68 if spreads.size() > 3 else 0.82), true, spread_direction, violet, "standard")
	elif enemy.kind == "warden":
		var null_tint: Color = Color(0.30, 0.92, 1.0)
		for spread: float in [-0.36, -0.18, 0.0, 0.18, 0.36]:
			var null_shot: NomadProjectile = _spawn_projectile(origin, target, enemy.damage * 0.52, true, direction.rotated(spread), null_tint, "null")
			null_shot.speed = 1010.0
	elif enemy.kind == "phantom":
		var phantom_tint: Color = Color(0.48, 0.80, 1.0)
		for spread: float in [-0.10, 0.0, 0.10]:
			var phase_shot: NomadProjectile = _spawn_projectile(origin, target, enemy.damage * 0.48, true, direction.rotated(spread), phantom_tint, "phase")
			phase_shot.speed = 1120.0
	elif enemy.kind == "veil_tech":
		var tech_tint: Color = Color(0.96, 0.58, 0.24)
		var tech_bolt: NomadProjectile = _spawn_projectile(origin, target, enemy.damage * 0.56, true, direction, tech_tint, "overcharged")
		tech_bolt.speed = 900.0
	elif enemy.kind == "salvage_drone":
		var drone_tint: Color = Color(0.26, 0.86, 0.90)
		for spread: float in [-0.055, 0.055]:
			var drone_shot: NomadProjectile = _spawn_projectile(origin, target, enemy.damage * 0.62, true, direction.rotated(spread), drone_tint, "scrap")
			drone_shot.speed = 1040.0
	elif enemy.kind == "mobile_turret":
		var turret_tint: Color = Color(0.91, 0.62, 0.28)
		for spread: float in [-0.10, 0.0, 0.10]:
			var turret_shot: NomadProjectile = _spawn_projectile(origin, target, enemy.damage * 0.46, true, direction.rotated(spread), turret_tint, "turret")
			turret_shot.speed = 930.0
	elif enemy.kind == "scrap_titan":
		var titan_tint: Color = Color(0.92, 0.52, 0.22)
		for spread: float in [-0.34, -0.17, 0.0, 0.17, 0.34]:
			var titan_shot: NomadProjectile = _spawn_projectile(origin, target, enemy.damage * 0.46, true, direction.rotated(spread), titan_tint, "titan")
			titan_shot.speed = 920.0
	elif enemy.kind == "blaster" and enemy.role_windup_pattern == "blaster_double":
		var blaster_tint: Color = Color(0.98, 0.66, 0.30)
		var side_axis: Vector2 = direction.orthogonal() * 9.0
		for offset: Vector2 in [-side_axis, side_axis]:
			var twin_origin: Vector2 = origin + offset
			var twin_shot: NomadProjectile = _spawn_projectile(twin_origin, target, enemy.damage * 0.58, true, direction, blaster_tint, "standard")
			twin_shot.speed = 900.0
	elif enemy.kind == "sniper":
		var sniper_tint: Color = Color(0.42, 0.86, 1.0)
		var sniper_spreads: Array[float] = [0.0]
		if enemy.affix == "overcharged":
			sniper_spreads = [-0.045, 0.045]
		for spread: float in sniper_spreads:
			var sniper_shot: NomadProjectile = _spawn_projectile(origin, target, enemy.damage * (0.78 if sniper_spreads.size() > 1 else 1.20), true, direction.rotated(spread), sniper_tint, "sniper")
			sniper_shot.speed = 1260.0
	elif enemy.kind == "suppressor":
		var suppressor_tint: Color = Color(1.0, 0.52, 0.18)
		var burst_spreads: Array[float] = [-0.10, 0.0, 0.10]
		if enemy.affix == "overcharged":
			burst_spreads = [-0.18, -0.09, 0.0, 0.09, 0.18]
		for spread: float in burst_spreads:
			var burst_shot: NomadProjectile = _spawn_projectile(origin, target, enemy.damage * (0.34 if burst_spreads.size() > 3 else 0.48), true, direction.rotated(spread), suppressor_tint, "suppressor")
			burst_shot.speed = 930.0
	elif enemy.affix == "overcharged":
		for spread: float in [-0.12, 0.0, 0.12]:
			_spawn_projectile(origin, target, enemy.damage * 0.62, true, direction.rotated(spread), Color(1.0, 0.44, 0.20), "overcharged")
	elif enemy.affix == "void":
		_spawn_projectile(origin, target, enemy.damage * 0.72, true, direction.rotated(-0.07), Color(0.68, 0.45, 0.92), "void")
		_spawn_projectile(origin, target, enemy.damage * 0.72, true, direction.rotated(0.07), Color(0.68, 0.45, 0.92), "void")
	else:
		_spawn_projectile(origin, target, enemy.damage, true)
	_play_sfx(SFX_ENEMY_SHOOT, -18.0, 0.99, 1.01)

func _on_projectile_impact(world_position: Vector2, _damage_amount: float, enemy_shot: bool, hit_color: Color) -> void:
	var impact_color: Color = Color(hit_color.r * 0.90 + 0.10, hit_color.g * 0.90 + 0.10, hit_color.b * 0.90 + 0.10, 0.84) if enemy_shot else Color(0.58, 0.90, 0.72, 0.86)
	_spawn_hit_fx(world_position, impact_color, 0.64 if enemy_shot else 0.78)
	_spawn_ground_impact_fx(world_position, impact_color, 0.80 if enemy_shot else 0.68)
	_spawn_combat_sparks(world_position, impact_color, 1 if enemy_shot else 2, 0.62)
	if enemy_shot:
		_shake(0.52, 0.038)
	else:
		_play_sfx(SFX_HIT, -18.0, 0.96, 1.04)

func _on_enemy_damaged(world_position: Vector2, amount: float, was_heavy: bool, was_critical: bool) -> void:
	var number_color: Color = Color("f4d9a0") if was_critical else (Color("e9c48b") if was_heavy else Color("ded6c7"))
	_spawn_damage_number(world_position + Vector2(0.0, -42.0), amount, number_color, was_critical)
	var hit_color: Color = Color(0.80, 0.91, 0.94) if was_critical else Color(0.62, 0.82, 0.86)
	var impact_intensity: float = 1.12 if was_critical else (0.98 if was_heavy else 0.76)
	_spawn_hit_fx(world_position, hit_color, impact_intensity)
	_spawn_saber_impact_fx(world_position, hit_color, 1.08 if was_critical else (0.94 if was_heavy else 0.78))
	_spawn_ground_impact_fx(world_position + Vector2(0.0, 18.0), Color(0.72, 0.63, 0.50, 0.58), 0.72 if was_heavy else 0.52)
	_spawn_combat_sparks(world_position, hit_color, 3 if was_critical else (2 if was_heavy else 1), 1.08 if was_critical else 0.86)
	_play_sfx(SFX_SABER_HIT_HEAVY if was_heavy or was_critical else SFX_SABER_HIT, -15.5 if was_heavy or was_critical else -19.5, 0.99, 1.01)
	_shake(1.85 if was_critical else (1.25 if was_heavy else 0.52), 0.060 if was_critical else 0.048)
	if was_critical:
		_haptic(16, 0.30, 0.065)

func _on_player_damaged(world_position: Vector2, amount: float) -> void:
	var heavy_hit: bool = is_instance_valid(player) and amount >= player.max_health * 0.12
	_spawn_damage_number(world_position + Vector2(0.0, -52.0), amount, Color("ffbf72") if heavy_hit else Color("ff7e72"))
	if heavy_hit:
		_spawn_combat_text(world_position + Vector2(0.0, -82.0), "IMPACT LOURD", Color("ffca7a"), 17)
	_spawn_hit_fx(world_position, Color(1.0, 0.32, 0.24), 1.28 if heavy_hit else 0.92)
	_play_sfx(SFX_HURT, -14.5 if heavy_hit else -16.0, 0.97, 1.01)
	_shake(6.4 if heavy_hit else 5.0, 0.17 if heavy_hit else 0.14)
	_haptic(42 if heavy_hit else 30, 0.58 if heavy_hit else 0.48, 0.11)

func _on_player_dodged(world_position: Vector2, amount: float) -> void:
	# A dash that actually crosses a hostile hit gets explicit feedback.
	_spawn_combat_text(world_position + Vector2(0.0, -62.0), "ESQUIVE", Color("a9f6ff"), 18)
	_spawn_combat_sparks(world_position, Color("88efff"), 3, 0.82)
	if is_instance_valid(player) and amount >= player.max_health * 0.10:
		_haptic(12, 0.24, 0.08)

func _grant_boss_reward(boss_kind: String) -> String:
	var reward: String = ""
	match boss_kind:
		"sentinel":
			if player.saber_range < 319.99:
				var before_range: float = player.saber_range
				player.saber_range = minf(320.0, player.saber_range + 7.0)
				reward = "SABRE +%.1f PORTÉE" % (player.saber_range - before_range)
		"marauder":
			if player.damage < 219.99:
				var before_damage: float = player.damage
				player.damage = minf(220.0, player.damage * 1.045)
				reward = "DÉGÂTS +%.1f" % ((player.damage / before_damage - 1.0) * 100.0) + " %"
		"archon":
			if player.pulse_cooldown > 2.61:
				var before_cooldown: float = player.pulse_cooldown
				player.pulse_cooldown = maxf(2.6, player.pulse_cooldown - 0.22)
				player.pulse_timer = 0.0
				reward = "ONDE -%.2f s" % (before_cooldown - player.pulse_cooldown)
		"warden":
			if player.max_shield < 249.0:
				player.max_shield = minf(250.0, player.max_shield + 18.0)
				player.shield = minf(player.max_shield, player.shield + 18.0)
				reward = "BOUCLIER +18"
		"reaper":
			if player.attack_interval > 0.225:
				var before_interval: float = player.attack_interval
				player.attack_interval = maxf(0.22, player.attack_interval * 0.965)
				reward = "CADENCE +%.1f %%" % ((before_interval / player.attack_interval - 1.0) * 100.0)
		"resonator":
			if player.force_wave_radius < 399.0:
				player.force_wave_radius = minf(400.0, player.force_wave_radius + 24.0)
				player.pulse_cooldown = maxf(2.6, player.pulse_cooldown - 0.12)
				player.pulse_timer = 0.0
				reward = "ONDE +24 PORTÉE"
		"scrap_titan":
			if player.armor < 0.315:
				player.armor = minf(0.32, player.armor + 0.015)
				player.magnet_range += 10.0
				reward = "ARMURE +1,5 %"
	if reward.is_empty():
		rift_fragments += 3
		run_fragments += 3
		reward = "+3 FRAGMENTS"
	_check_run_synergies()
	_limit_survival_stats()
	return reward

func _on_enemy_died(enemy: NomadEnemy, value: int) -> void:
	if not is_instance_valid(player):
		return
	var death_position: Vector2 = enemy.global_position
	var was_boss: bool = enemy.is_boss()
	var was_miniboss: bool = enemy.is_miniboss()
	var was_elite: bool = enemy.elite
	var event_id: int = int(enemy.get_meta("world_event_id", -1)) if enemy.has_meta("world_event_id") else -1
	var event_role: String = String(enemy.get_meta("world_event_role", "")) if enemy.has_meta("world_event_role") else ""
	_spawn_death_fx(death_position, enemy.kind, was_elite, was_boss)
	if dynamic_event_active and dynamic_event_started and event_id == dynamic_event_serial:
		if dynamic_event_kind in ["patrol", "ambush"]:
			dynamic_event_kills += 1
			dynamic_event_progress = float(dynamic_event_kills)
			if dynamic_event_kills >= dynamic_event_target_kills:
				_complete_dynamic_world_event(3 if dynamic_event_kind == "ambush" else 2, "MENACE ÉLIMINÉE")
		elif dynamic_event_kind == "miniboss" and event_role == "miniboss":
			_complete_dynamic_world_event(4, "TRAQUEUR DU RIFT ABATTU")
	kills += 1
	if run_life_on_kill > 0.0:
		player.heal(run_life_on_kill * (3.0 if was_boss else (2.2 if was_miniboss else (1.6 if was_elite else 1.0))))
	if not was_boss and not was_elite and run_fragment_bonus_chance > 0.0 and rng.randf() < run_fragment_bonus_chance:
		_spawn_rift_fragment(death_position + Vector2(rng.randf_range(-10.0, 10.0), -14.0), 1)
	combo += 1
	combo_timer = 2.4
	var current_zone: String = _player_zone()
	if current_zone == "ÉPAVE DU PÈLERIN" and rng.randf() < (0.10 if was_elite or was_boss else 0.05):
		_spawn_rift_fragment(death_position + Vector2(rng.randf_range(-8.0, 8.0), -18.0), 1)
	elif current_zone == "PLAINE CENTRALE" and rng.randf() < 0.12:
		var bonus_orb: NomadXPOrb = XPOrbScript.new() as NomadXPOrb
		bonus_orb.global_position = _safe_pickup_position(death_position + Vector2(0.0, -16.0), 14.0)
		bonus_orb.player = player
		bonus_orb.value = 1 + int(was_elite or was_boss)
		bonus_orb.collected.connect(_on_xp_collected)
		pickups_root.add_child(bonus_orb)
	if combo >= 5:
		combo_label.text = "CHAÎNE  ×%d" % combo
		combo_label.modulate.a = 1.0
	var orb_count: int = 3 if was_boss else (2 if was_miniboss else 1)
	for i: int in range(orb_count):
		var orb: NomadXPOrb = XPOrbScript.new() as NomadXPOrb
		orb.global_position = _safe_pickup_position(death_position + Vector2(float(i - 1) * 18.0, float(i % 2) * 10.0), 14.0)
		orb.player = player
		orb.value = maxi(1, int(round((float(value) / float(orb_count)) * run_xp_multiplier)))
		orb.collected.connect(_on_xp_collected)
		pickups_root.add_child(orb)
	if was_boss:
		boss_defeats[enemy.kind] = int(boss_defeats.get(enemy.kind, 0)) + 1
		if enemy.kind == "resonator":
			_spawn_canyon_secrets()
		_clear_boss_hazards()
		_spawn_rift_fragment(death_position + Vector2(0.0, -24.0), 5)
		boss_enemy = null
		boss_bar.visible = false
		boss_label.text = ""
		_spawn_supply(death_position + Vector2(-28.0, 10.0), "med")
		_spawn_supply(death_position + Vector2(28.0, 10.0), "shield")
		_spawn_supply(death_position + Vector2(0.0, -20.0), "charge")
		var reward: String = _grant_boss_reward(enemy.kind)
		_spawn_loot_roll(death_position + Vector2(48.0, -18.0), 4, "BOSS")
		_try_spawn_signature_loot(enemy.kind, death_position + Vector2(-48.0, -22.0))
		_spawn_boss_death_sequence(death_position, enemy.kind)
		_play_sfx(SFX_BOSS_DEFEAT, -4.0, 0.98, 1.02)
		_show_presentation("SIGNATURE NEUTRALISÉE", _boss_name(enemy.kind) + "  •  " + reward, _boss_color(enemy.kind), 1.12, true)
		_shake(7.4, 0.30)
		_haptic(72, 0.82, 0.34)
		_save_profile()
	elif was_miniboss:
		_spawn_rift_fragment(death_position + Vector2(0.0, -18.0), 2)
		_spawn_loot_roll(death_position + Vector2(34.0, -18.0), 3, "MINI-BOSS")
		_spawn_supply(death_position + Vector2(-30.0, 8.0), "charge" if enemy.kind in ["veil_guardian", "leviathan_grinder"] else ("shield" if enemy.kind == "phantom" else "med"))
		var mini_color: Color = Color("70cfff") if enemy.kind == "phantom" else (Color("b57cff") if enemy.kind == "veil_guardian" else (Color("d9793c") if enemy.kind == "leviathan_grinder" else Color("ff9a4c")))
		_show_presentation("MENACE ÉLITE NEUTRALISÉE", _miniboss_name(enemy.kind), mini_color, 0.72, false)
		_play_sfx(SFX_MINIBOSS_ALERT, -9.0, 0.88, 0.94)
		_shake(5.0, 0.18)
	elif was_elite:
		elites_killed += 1
		_spawn_rift_fragment(death_position, 1)
		if rng.randf() < 0.65:
			var supply_types: Array[String] = ["med", "shield", "charge"]
			_spawn_supply(death_position, supply_types[rng.randi_range(0, supply_types.size() - 1)])
		if rng.randf() < 0.09:
			_spawn_loot_roll(death_position + Vector2(18.0, -20.0), 2, _player_zone())
		_shake(3.2, 0.12)
	elif enemy.kind == "heavy" or enemy.kind == "breaker":
		_shake(3.5, 0.13)
		if rng.randf() < 0.24:
			_spawn_supply(death_position, "med" if rng.randf() < 0.55 else "charge")
	if is_instance_valid(player):
		var health_ratio: float = player.health / maxf(1.0, player.max_health)
		if not was_boss and not was_miniboss and not was_elite and health_ratio < 0.24 and rng.randf() < 0.05:
			_spawn_supply(death_position + Vector2(rng.randf_range(-14.0, 14.0), -12.0), "med")
		elif not was_boss and not was_miniboss and health_ratio < 0.42 and rng.randf() < 0.025:
			_spawn_supply(death_position + Vector2(rng.randf_range(-16.0, 16.0), -12.0), "shield")
	if rng.randf() < 0.012:
		_spawn_supply(death_position, "shield")

func _on_xp_collected(value: int) -> void:
	xp += value
	_play_sfx(SFX_XP, -23.0, 0.98, 1.06)
	while xp >= xp_needed:
		xp -= xp_needed
		_level_up()
	_present_upgrade_if_needed()

func _level_up() -> void:
	level += 1
	xp_needed = 30 + (level - 1) * 16 + maxi(0, level - 10) * 4
	pending_level_choices += 1
	player.heal(minf(20.0, player.max_health * 0.045))
	player.restore_shield(12.0)
	_play_sfx(SFX_LEVEL, -8.0, 1.0, 1.0)
	_shake(3.5, 0.13)
	_spawn_pulse_fx(Color(1.0, 0.78, 0.32, 0.82), 1.55, 0.42)
	_show_toast("NIVEAU %d  •  AMÉLIORATION DISPONIBLE" % level)
	_haptic(34, 0.48, 0.16)

func _can_use_active_skill() -> bool:
	return state == State.PLAYING and not upgrade_pending and not rotation_blocked and is_instance_valid(player) and player.active and not player.selection_locked

func _auto_force_wave() -> void:
	if state != State.PLAYING or not is_instance_valid(player) or not player.can_pulse():
		return
	var auto_range_sq: float = player.force_wave_auto_range * player.force_wave_auto_range
	for node: Node in enemies_root.get_children():
		var enemy: NomadEnemy = node as NomadEnemy
		if enemy != null and enemy.active and player.global_position.distance_squared_to(enemy.global_position) <= auto_range_sq:
			_use_pulse()
			return

func _use_pulse() -> void:
	if not _can_use_active_skill() or not player.trigger_pulse():
		return
	var radius: float = player.force_wave_radius
	var damage_amount: float = player.damage * player.force_wave_damage_scale
	var hit_any: bool = false
	for node: Node in enemies_root.get_children():
		var enemy: NomadEnemy = node as NomadEnemy
		if enemy == null or not enemy.active:
			continue
		var delta_to_enemy: Vector2 = enemy.global_position - player.global_position
		if delta_to_enemy.length() <= radius:
			hit_any = true
			enemy.take_damage(damage_amount)
			if is_instance_valid(enemy) and enemy.active:
				enemy.apply_knockback(player.global_position, player.force_wave_knockback)
	_play_sfx(SFX_PULSE, -11.0, 0.98, 1.02)
	_spawn_force_wave_fx(Color(0.48, 0.94, 1.0, 0.88), radius)
	_spawn_combat_text(player.global_position + Vector2(0.0, -72.0), "ONDE", Color("9cf6ff"), 17)
	_shake(7.0 if hit_any else 3.2, 0.20 if hit_any else 0.10)
	_haptic(46 if hit_any else 24, 0.62 if hit_any else 0.36, 0.15)

func _use_dash() -> void:
	if not _can_use_active_skill():
		return
	var direction: Vector2 = joystick.vector if joystick.vector.length_squared() > 0.01 else player.movement_direction()
	if player.trigger_dash(direction):
		_play_sfx(SFX_UI, -15.0, 1.15, 1.22)
		_spawn_combat_text(player.global_position + Vector2(0.0, -64.0), "PHASE", Color("a8f6ff"), 15)
		_shake(2.6, 0.10)
		_haptic(20, 0.30, 0.10)

func _skill_traction_cooldown() -> float:
	var cooldown: float = 9.0 - float(meta_instinct_rank) * 0.08 - float(meta_scavenger_rank) * 0.10
	if meta_archon_node:
		cooldown -= 0.8
	return maxf(5.8, cooldown)

func _spawn_traction_line(from_position: Vector2, to_position: Vector2) -> void:
	_trim_fx_budget()
	var tether: Line2D = Line2D.new()
	tether.width = 3.2
	tether.default_color = Color(0.66, 0.42, 1.0, 0.78)
	tether.add_point(Vector2.ZERO)
	tether.add_point(to_position - from_position)
	tether.global_position = from_position
	tether.z_index = 3620
	fx_root.add_child(tether)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(tether, "modulate:a", 0.0, 0.20)
	tween.tween_property(tether, "width", 1.0, 0.20)
	tween.finished.connect(tether.queue_free)

func _use_traction() -> void:
	if not _can_use_active_skill() or skill_traction_cooldown_timer > 0.0:
		return
	var radius: float = 380.0 + float(meta_scavenger_rank) * 5.0
	var affected: Array[NomadEnemy] = []
	for node: Node in enemies_root.get_children():
		var enemy: NomadEnemy = node as NomadEnemy
		if enemy != null and enemy.active and player.global_position.distance_to(enemy.global_position) <= radius:
			affected.append(enemy)
	if affected.is_empty():
		_show_toast("TRACTION  •  AUCUNE CIBLE À PORTÉE")
		return
	skill_traction_cooldown_timer = _skill_traction_cooldown()
	var damage_amount: float = player.damage * (0.62 if skill_surge_timer <= 0.0 else 0.78)
	var shown_lines: int = 0
	for enemy: NomadEnemy in affected:
		var enemy_position: Vector2 = enemy.global_position
		enemy.take_damage(damage_amount)
		if is_instance_valid(enemy) and enemy.active:
			enemy.apply_knockback(player.global_position, -720.0)
		if shown_lines < 8:
			_spawn_traction_line(enemy_position, player.global_position)
			shown_lines += 1
	_spawn_pulse_fx(Color(0.65, 0.36, 1.0, 0.72), 1.30, 0.26)
	_spawn_combat_text(player.global_position + Vector2(0.0, -74.0), "TRACTION", Color("d1b1ff"), 18)
	_play_sfx(SFX_PULSE, -14.0, 0.78, 0.84)
	_shake(5.4, 0.15)
	_haptic(34, 0.50, 0.12)

func _skill_surge_duration() -> float:
	return 5.0 + float(meta_fury_rank) * 0.10 + (0.35 if meta_marauder_node else 0.0)

func _skill_surge_cooldown() -> float:
	var cooldown: float = 16.0 - float(meta_fury_rank) * 0.24 - float(meta_instinct_rank) * 0.05
	if meta_archon_node:
		cooldown -= 1.2
	return maxf(11.5, cooldown)

func _use_surge() -> void:
	if not _can_use_active_skill() or skill_surge_timer > 0.0 or skill_surge_cooldown_timer > 0.0:
		return
	skill_surge_timer = _skill_surge_duration()
	skill_surge_cooldown_timer = _skill_surge_cooldown()
	skill_surge_fx_timer = 0.0
	attack_timer = minf(attack_timer, player.attack_interval * 0.22)
	_spawn_force_wave_fx(Color(0.62, 0.34, 1.0, 0.74), minf(180.0, player.force_wave_radius * 0.68))
	_spawn_combat_text(player.global_position + Vector2(0.0, -78.0), "SURCHARGE", Color("d5adff"), 19)
	_show_toast("SURCHARGE  •  DÉGÂTS +36 %  •  CADENCE +47 %")
	_play_sfx(SFX_BOSS_PHASE, -14.0, 1.12, 1.16)
	_shake(5.0, 0.16)
	_haptic(40, 0.58, 0.13)

func _on_player_dash_used(from_position: Vector2, to_position: Vector2) -> void:
	var delta: Vector2 = to_position - from_position
	for i: int in range(5):
		var ghost: Sprite2D = Sprite2D.new()
		ghost.texture = HERO_PREVIEW
		ghost.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		ghost.scale = Vector2(0.41, 0.41)
		ghost.modulate = Color(0.42, 0.91, 1.0, 0.28 - float(i) * 0.035)
		ghost.global_position = from_position + delta * (float(i) / 5.0)
		ghost.z_index = 3400
		fx_root.add_child(ghost)
		var tween: Tween = create_tween()
		tween.tween_property(ghost, "modulate:a", 0.0, 0.18 + float(i) * 0.02)
		tween.finished.connect(ghost.queue_free)

func _safe_pickup_position(position_value: Vector2, radius: float = 18.0) -> Vector2:
	if world == null:
		return position_value
	return world.safe_pickup_position(position_value, radius)

func _spawn_initial_loot_caches() -> void:
	# V44.44 : seulement trois noyaux de récupération, intégrés aux zones d'exploration.
	var caches: Array[Dictionary] = [
		{"position": Vector2(1215.0, 1110.0), "rank": 1, "zone": "PLAINE"},
		{"position": Vector2(1430.0, 1325.0), "rank": 2, "zone": "ÉPAVE"},
		{"position": Vector2(2265.0, 1455.0), "rank": 3, "zone": "AVANT-POSTE"}
	]
	for data: Dictionary in caches:
		_spawn_loot_cache(data["position"], int(data["rank"]), String(data["zone"]))

func _spawn_loot_cache(position_value: Vector2, cache_rank: int, zone_hint: String, hold_value: float = 0.0) -> void:
	if not is_instance_valid(player):
		return
	var cache: NomadLootCache = LootCacheScript.new() as NomadLootCache
	cache.global_position = _safe_pickup_position(position_value, 24.0)
	cache.player = player
	cache.configure(cache_rank, zone_hint)
	cache.hold_time = maxf(0.0, hold_value)
	cache.opened.connect(_on_loot_cache_opened)
	pickups_root.add_child(cache)

func _on_loot_cache_opened(cache_rank: int, world_position: Vector2, zone_hint: String) -> void:
	_spawn_loot_roll(world_position, cache_rank, zone_hint)
	if dynamic_event_active and dynamic_event_kind == "cache" and dynamic_event_started and world_position.distance_to(dynamic_event_position) <= 120.0:
		_complete_dynamic_world_event(0, "NOYAU RÉCUPÉRÉ")
	if cache_rank >= 3:
		_spawn_rift_fragment(world_position + Vector2(24.0, 10.0), cache_rank - 1)
	_play_sfx(SFX_LEVEL, -15.0, 1.02, 1.08)
	_haptic(24 + cache_rank * 5, 0.42 + float(cache_rank) * 0.06, 0.13)
	_spawn_pulse_fx(_loot_rarity_color("legendary" if cache_rank >= 4 else ("epic" if cache_rank >= 3 else "rare")), 0.78 + float(cache_rank) * 0.08, 0.22)
	_save_profile()

func _spawn_loot_roll(position_value: Vector2, cache_rank: int, zone_hint: String) -> void:
	var rarity: String = _roll_loot_rarity(cache_rank, zone_hint)
	var module_id: String = _random_module_for_rarity(rarity, zone_hint)
	_spawn_loot_module(position_value, module_id, rarity)

func _spawn_loot_module(position_value: Vector2, module_id: String, rarity: String, age_value: float = 0.0) -> void:
	if not is_instance_valid(player):
		return
	var loot: NomadLootPickup = LootPickupScript.new() as NomadLootPickup
	loot.global_position = _safe_pickup_position(position_value, 18.0)
	loot.player = player
	loot.configure(module_id, rarity)
	loot.age = age_value
	loot.collected.connect(_on_loot_collected)
	pickups_root.add_child(loot)

func _roll_loot_rarity(cache_rank: int, zone_hint: String) -> String:
	var rank: int = clampi(cache_rank, 1, 4)
	var legendary: float = [0.0, 0.004, 0.012, 0.028, 0.060][rank]
	var epic: float = [0.0, 0.038, 0.080, 0.150, 0.230][rank]
	var rare: float = [0.0, 0.220, 0.305, 0.380, 0.430][rank]
	if zone_hint in ["RAFFINERIE", "BOSS"]:
		legendary += 0.008
		epic += 0.020
	elif zone_hint in ["AVANT-POSTE", "ÉPAVE", "CANYON DES ÉCHOS", "CIMETIÈRE D’ÉPAVES"]:
		if zone_hint == "CIMETIÈRE D’ÉPAVES":
			epic += 0.016
		elif zone_hint == "CANYON DES ÉCHOS":
			epic += 0.014
		else:
			epic += 0.012
	var roll: float = rng.randf()
	if roll < legendary:
		return "legendary"
	if roll < legendary + epic:
		return "epic"
	if roll < legendary + epic + rare:
		return "rare"
	return "common"

func _random_module_for_rarity(rarity: String, zone_hint: String = "") -> String:
	if zone_hint == "CIMETIÈRE D’ÉPAVES" and rng.randf() < 0.56:
		match rarity:
			"rare": return "induction_cell"
			"epic": return "salvage_actuator"
			"legendary": return "leviathan_reactor"
			_: return "scrap_plating"
	var pool: Array[String]
	match rarity:
		"rare":
			pool = ["precision_core", "rapid_actuator", "rift_harvester", "hunter_lens"]
		"epic":
			pool = ["nomad_overclock", "phase_matrix", "void_coil", "predator_drive"]
		"legendary":
			pool = ["zero_core", "pilgrim_reactor", "hunter_protocol"]
		_:
			pool = ["field_patch", "edge_tuning", "servo_joint", "scavenger_magnet"]
	return pool[rng.randi_range(0, pool.size() - 1)]

func _module_name(module_id: String) -> String:
	match module_id:
		"field_patch": return "PLAQUE DE TERRAIN"
		"edge_tuning": return "AFFÛTAGE NOMADE"
		"servo_joint": return "SERVO-JOINT"
		"scavenger_magnet": return "AIMANT DE RÉCUPÉRATION"
		"precision_core": return "CŒUR DE PRÉCISION"
		"rapid_actuator": return "ACTIONNEUR RAPIDE"
		"rift_harvester": return "MOISSONNEUR DU RIFT"
		"hunter_lens": return "LENTILLE DE CHASSE"
		"nomad_overclock": return "SURCADENÇAGE NOMADE"
		"phase_matrix": return "MATRICE DE PHASE"
		"void_coil": return "BOBINE DU VIDE"
		"predator_drive": return "MOTEUR PRÉDATEUR"
		"zero_core": return "CŒUR ZÉRO"
		"pilgrim_reactor": return "RÉACTEUR DU PÈLERIN"
		"hunter_protocol": return "PROTOCOLE CHASSEUR"
		"sentinel_bastion": return "BASTION DE LA SENTINELLE"
		"marauder_ember": return "BRAISE DU MARAUDEUR"
		"archon_conduit": return "CONDUIT DE L'ARCHONTE"
		"warden_lattice": return "RÉSEAU DU GARDIEN NULL"
		"reaper_scythe": return "TRANCHANT DE CENDRE"
		"echo_relic": return "RELIQUE D'ÉCHO"
		"scrap_plating": return "PLAQUES DE FERRAILLE"
		"induction_cell": return "CELLULE D'INDUCTION"
		"salvage_actuator": return "ACTIONNEUR DE RÉCUPÉRATION"
		"leviathan_reactor": return "RÉACTEUR DU LÉVIATHAN"
		"titan_salvage_core": return "CŒUR DU TITAN FERRAILLEUR"
		_: return "MODULE INCONNU"

func _loot_rarity_label(rarity: String) -> String:
	match rarity:
		"rare": return "RARE"
		"epic": return "ÉPIQUE"
		"legendary": return "LÉGENDAIRE"
		"signature": return "RELIQUE DE BOSS"
		_: return "COMMUN"

func _loot_rarity_color(rarity: String) -> Color:
	match rarity:
		"rare": return Color("5cc9ff")
		"epic": return Color("c875ff")
		"legendary": return Color("ffb74d")
		"signature": return Color("ff6a45")
		_: return Color("a8d9b0")

func _on_loot_collected(module_id: String, rarity: String) -> void:
	if not is_instance_valid(player):
		return
	run_module_count += 1
	run_modules[module_id] = int(run_modules.get(module_id, 0)) + 1
	loot_discovered[module_id] = maxi(1, int(loot_discovered.get(module_id, 0)))
	if rarity == "signature":
		boss_signatures[module_id] = true
	_apply_loot_module(module_id)
	var color: Color = _loot_rarity_color(rarity)
	_spawn_pulse_fx(Color(color.r, color.g, color.b, 0.80), 1.25 if rarity in ["legendary", "signature"] else 0.94, 0.34)
	if rarity in ["epic", "legendary", "signature"]:
		_play_sfx(SFX_LOOT_RARE, -9.0 if rarity in ["legendary", "signature"] else -13.0, 0.98, 1.04)
	else:
		_play_sfx(SFX_XP, -15.0, 1.02, 1.08)
	_haptic(46 if rarity in ["legendary", "signature"] else 24, 0.68 if rarity in ["legendary", "signature"] else 0.38, 0.14)
	_show_loot_banner(module_id, rarity)
	if rarity == "signature":
		_show_presentation("RELIQUE ACQUISE", _module_name(module_id), color, 1.0, false)
	_save_profile()

func _apply_loot_module(module_id: String) -> void:
	match module_id:
		"field_patch":
			player.max_health += 12.0
			player.health += 12.0
		"edge_tuning":
			player.damage *= 1.038
		"servo_joint":
			player.speed += 8.0
			player.dash_cooldown = maxf(1.75, player.dash_cooldown - 0.06)
		"scavenger_magnet":
			player.magnet_range += 24.0
			run_fragment_bonus_chance += 0.006
		"precision_core":
			player.critical_chance += 0.020
			player.critical_multiplier += 0.05
		"rapid_actuator":
			player.attack_interval = maxf(0.24, player.attack_interval * 0.95)
		"rift_harvester":
			run_xp_multiplier += 0.07
			run_fragment_bonus_chance += 0.014
		"hunter_lens":
			player.saber_range += 16.0
			player.critical_chance += 0.012
		"nomad_overclock":
			player.damage *= 1.070
			player.attack_interval = maxf(0.24, player.attack_interval * 0.94)
		"phase_matrix":
			player.armor += 0.020
			player.regeneration += 0.11
		"void_coil":
			player.pulse_cooldown = maxf(2.6, player.pulse_cooldown - 0.36)
			player.force_wave_damage_scale += 0.10
			player.pulse_timer = 0.0
		"predator_drive":
			player.speed += 14.0
			player.damage *= 1.045
			player.critical_chance += 0.014
		"zero_core":
			player.damage *= 1.10
			player.critical_multiplier += 0.13
			player.pulse_cooldown = maxf(2.6, player.pulse_cooldown - 0.22)
		"pilgrim_reactor":
			player.max_health += 34.0
			player.health += 34.0
			player.regeneration += 0.20
		"hunter_protocol":
			player.saber_range += 28.0
			player.critical_chance += 0.035
			player.attack_interval = maxf(0.24, player.attack_interval * 0.92)
		"sentinel_bastion":
			player.max_health += 44.0
			player.health += 44.0
			player.armor += 0.040
		"marauder_ember":
			player.damage *= 1.12
			player.saber_range += 32.0
			player.critical_multiplier += 0.10
		"archon_conduit":
			player.pulse_cooldown = maxf(2.6, player.pulse_cooldown - 0.62)
			player.force_wave_radius += 36.0
			player.force_wave_damage_scale += 0.22
			player.pulse_timer = 0.0
		"warden_lattice":
			player.max_shield += 38.0
			player.shield += 38.0
			player.shield_regeneration += 0.16
			player.armor += 0.025
		"reaper_scythe":
			player.damage *= 1.12
			player.attack_interval = maxf(0.24, player.attack_interval * 0.92)
			player.critical_chance += 0.025
		"echo_relic":
			player.force_wave_radius += 34.0
			player.pulse_cooldown = maxf(2.6, player.pulse_cooldown - 0.38)
			player.critical_chance += 0.018
			player.magnet_range += 20.0
			player.pulse_timer = 0.0
		"scrap_plating":
			player.max_health += 10.0
			player.health += 10.0
			player.armor += 0.010
		"induction_cell":
			player.pulse_cooldown = maxf(2.6, player.pulse_cooldown - 0.18)
			player.max_shield += 10.0
			player.shield += 10.0
		"salvage_actuator":
			player.speed += 9.0
			player.attack_interval = maxf(0.22, player.attack_interval * 0.965)
		"leviathan_reactor":
			player.max_health += 22.0
			player.health += 22.0
			player.regeneration += 0.12
			player.magnet_range += 20.0
		"titan_salvage_core":
			player.max_shield += 28.0
			player.shield += 28.0
			player.armor += 0.025
			player.magnet_range += 26.0
	_check_run_synergies()
	_limit_survival_stats()

func _boss_signature_id(boss_kind: String) -> String:
	match boss_kind:
		"sentinel": return "sentinel_bastion"
		"marauder": return "marauder_ember"
		"archon": return "archon_conduit"
		"warden": return "warden_lattice"
		"reaper": return "reaper_scythe"
		"resonator": return "echo_relic"
		"scrap_titan": return "titan_salvage_core"
		_: return ""

func _try_spawn_signature_loot(boss_kind: String, position_value: Vector2) -> void:
	var module_id: String = _boss_signature_id(boss_kind)
	if module_id.is_empty():
		return
	var already_found: bool = bool(boss_signatures.get(module_id, false))
	var defeats: int = maxi(1, int(boss_defeats.get(boss_kind, 1)))
	var chance: float = 0.06 if already_found else minf(0.25, 0.10 + float(maxi(0, defeats - 1)) * 0.03)
	if rng.randf() <= chance:
		_spawn_loot_module(position_value, module_id, "signature")
		var signature_color: Color = _boss_color(boss_kind)
		_spawn_world_pulse_fx(position_value, Color(signature_color.r, signature_color.g, signature_color.b, 0.90), 1.75, 0.56)
		_show_presentation("SIGNATURE DÉTECTÉE", _module_name(module_id), signature_color, 0.92, false)

func _spawn_supply(position_value: Vector2, supply_kind: String, age_value: float = 0.0) -> void:
	if not is_instance_valid(player):
		return
	var supply: NomadSupplyPickup = SupplyScript.new() as NomadSupplyPickup
	supply.global_position = _safe_pickup_position(position_value, 18.0)
	supply.player = player
	supply.kind = supply_kind
	supply.age = age_value
	supply.collected.connect(_on_supply_collected)
	pickups_root.add_child(supply)

func _on_supply_collected(kind: String) -> void:
	if not is_instance_valid(player):
		return
	match kind:
		"med":
			player.heal(minf(52.0, maxf(26.0, player.max_health * 0.13)))
			_show_toast("MÉDIPACK  •  INTÉGRITÉ RESTAURÉE")
		"shield":
			player.restore_shield(26.0)
			_show_toast("CELLULE DE BOUCLIER  •  DÉFENSE RESTAURÉE")
		_:
			player.pulse_timer = maxf(0.0, player.pulse_timer - 3.2)
			player.dash_timer = maxf(0.0, player.dash_timer - 1.9)
			_show_toast("CELLULE D'ÉNERGIE  •  RECHARGES ACCÉLÉRÉES")
	_play_sfx(SFX_XP, -14.0, 1.10, 1.18)

func _dynamic_event_name(kind: String) -> String:
	match kind:
		"patrol": return "PATROUILLE HOSTILE"
		"ambush": return "EMBUSCADE"
		"corruption": return "ZONE CORROMPUE"
		"cache": return "NOYAU DE RÉCUPÉRATION"
		"miniboss": return "TRAQUEUR DU RIFT"
		_: return "SIGNAL DU RIFT"

func _dynamic_event_color(kind: String) -> Color:
	match kind:
		"patrol": return Color("6bd7ff")
		"ambush": return Color("ff9b4c")
		"corruption": return Color("c86cff")
		"cache": return Color("ffd35c")
		"miniboss": return Color("ff5d68")
		_: return Color("c875ff")

func _dynamic_event_direction() -> String:
	if not is_instance_valid(player):
		return ""
	var delta_to_event: Vector2 = dynamic_event_position - player.global_position
	if delta_to_event.length_squared() < 1.0:
		return "ICI"
	var horizontal: String = "EST" if delta_to_event.x >= 0.0 else "OUEST"
	var vertical: String = "SUD" if delta_to_event.y >= 0.0 else "NORD"
	var ax: float = absf(delta_to_event.x)
	var ay: float = absf(delta_to_event.y)
	if ax > ay * 1.8:
		return horizontal
	if ay > ax * 1.8:
		return vertical
	return "%s-%s" % [vertical, horizontal]

func _dynamic_event_hud_text() -> String:
	if not dynamic_event_active:
		return ""
	var name: String = _dynamic_event_name(dynamic_event_kind)
	if not dynamic_event_started:
		return "SIGNAL MONDE  •  %s  •  %s" % [name, _dynamic_event_direction()]
	match dynamic_event_kind:
		"patrol", "ambush":
			return "%s  •  %d / %d" % [name, dynamic_event_kills, dynamic_event_target_kills]
		"corruption":
			return "%s  •  %.1f / %.0f s" % [name, dynamic_event_progress, dynamic_event_target]
		"cache":
			return "%s  •  SÉCURISER" % name
		"miniboss":
			return "%s  •  CIBLE ACTIVE" % name
		_:
			return name

func _random_world_event_position() -> Vector2:
	var candidates: Array[Vector2] = [
		Vector2(930.0, 850.0), Vector2(1250.0, 650.0), Vector2(1710.0, 690.0),
		Vector2(2110.0, 980.0), Vector2(890.0, 1420.0), Vector2(1180.0, 1760.0),
		Vector2(1760.0, 1750.0), Vector2(2660.0, 1180.0), Vector2(2360.0, 920.0),
		Vector2(3250.0, 980.0), Vector2(3500.0, 1120.0), Vector2(3850.0, 1180.0),
		Vector2(1120.0, 2390.0), Vector2(1670.0, 2260.0), Vector2(2550.0, 2390.0), Vector2(3420.0, 2780.0)
	]
	var valid: Array[Vector2] = []
	for candidate: Vector2 in candidates:
		# Un événement doit disposer d'une vraie petite arène, pas uniquement d'un point libre.
		if not world.is_open_area(candidate, 30.0, 138.0, 0.74):
			continue
		if is_instance_valid(player) and candidate.distance_to(player.global_position) < 470.0:
			continue
		valid.append(candidate)
	if valid.is_empty():
		return world.random_open_far(player.global_position, 520.0, 980.0, rng, 30.0, 138.0, 0.74)
	return valid[rng.randi_range(0, valid.size() - 1)]

func _event_spawn_point(center: Vector2, min_radius: float = 95.0, max_radius: float = 230.0) -> Vector2:
	for _i: int in range(36):
		var angle: float = rng.randf_range(0.0, TAU)
		var distance: float = rng.randf_range(min_radius, max_radius)
		var candidate: Vector2 = center + Vector2.RIGHT.rotated(angle) * distance
		if world.is_open_area(candidate, 26.0, 64.0, 0.64):
			return candidate
	return world.random_open_far(center, min_radius, max_radius + 120.0, rng, 26.0, 64.0, 0.64)

func _active_dynamic_event_enemy_count() -> int:
	var count: int = 0
	for node: Node in enemies_root.get_children():
		var enemy: NomadEnemy = node as NomadEnemy
		if enemy != null and enemy.active and int(enemy.get_meta("world_event_id", -1)) == dynamic_event_serial:
			count += 1
	return count

func _tag_dynamic_event_enemy(enemy: NomadEnemy, role: String = "unit") -> void:
	if enemy == null:
		return
	enemy.set_meta("world_event_id", dynamic_event_serial)
	enemy.set_meta("world_event_role", role)

func _spawn_dynamic_event_enemy(kind: String = "", elite_mode: bool = false, role: String = "unit", forced_affix: String = "") -> NomadEnemy:
	var spawn_position: Vector2 = _event_spawn_point(dynamic_event_position)
	var enemy: NomadEnemy = _spawn_enemy(kind, elite_mode, spawn_position, forced_affix)
	_tag_dynamic_event_enemy(enemy, role)
	return enemy

func _start_dynamic_world_event() -> bool:
	if dynamic_event_active or not is_instance_valid(player) or wave_cleanup or is_instance_valid(boss_enemy):
		return false
	var pool: Array[String] = ["patrol", "cache"]
	if wave_number >= 6:
		pool.append("miniboss")
	dynamic_event_kind = pool[rng.randi_range(0, pool.size() - 1)]
	dynamic_event_position = _random_world_event_position()
	dynamic_event_active = true
	dynamic_event_started = false
	dynamic_event_progress = 0.0
	dynamic_event_target = 1.0
	dynamic_event_spawn_timer = 0.0
	dynamic_event_age = 0.0
	dynamic_event_kills = 0
	dynamic_event_target_kills = 0
	dynamic_event_serial += 1
	_refresh_dynamic_event_marker()
	var color: Color = _dynamic_event_color(dynamic_event_kind)
	_flash_rift_overlay(Color(color.r, color.g, color.b, 0.11))
	_show_toast("SIGNAL MONDE  •  %s" % _dynamic_event_name(dynamic_event_kind))
	_save_profile()
	return true

func _begin_dynamic_world_event() -> void:
	if not dynamic_event_active or dynamic_event_started:
		return
	dynamic_event_started = true
	dynamic_event_age = 0.0
	dynamic_event_spawn_timer = 0.0
	match dynamic_event_kind:
		"patrol":
			dynamic_event_target_kills = 4 + mini(2, floori(float(wave_number) / 8.0))
			dynamic_event_target = float(dynamic_event_target_kills)
			for i: int in range(dynamic_event_target_kills):
				var patrol_kind: String = "stalker" if wave_number >= 4 and i % 3 == 0 else ("raider" if i % 3 != 2 else "blaster")
				_spawn_dynamic_event_enemy(patrol_kind, i == 0 and wave_number >= 6)
		"ambush":
			dynamic_event_target_kills = 5 + mini(2, floori(float(wave_number) / 9.0))
			dynamic_event_target = float(dynamic_event_target_kills)
			for i: int in range(dynamic_event_target_kills):
				var kind: String = "suppressor" if wave_number >= 4 and i % 3 == 0 else ("blaster" if i % 2 == 0 else "raider")
				if i == dynamic_event_target_kills - 1 and wave_number >= 6:
					kind = "breaker"
				_spawn_dynamic_event_enemy(kind, i == 0 or (i == dynamic_event_target_kills - 1 and wave_number >= 8))
		"corruption":
			dynamic_event_target = 10.0 + minf(5.0, float(wave_number) * 0.28)
			dynamic_event_spawn_timer = 0.3
		"cache":
			dynamic_event_target = 1.0
			_spawn_loot_cache(dynamic_event_position, 4, "BOSS")
			dynamic_event_spawn_timer = 0.5
		"miniboss":
			dynamic_event_target = 1.0
			var hunter: NomadEnemy = _spawn_dynamic_event_enemy("breaker", true, "miniboss", "void")
			if hunter != null:
				hunter.max_health *= 1.85 + minf(0.35, float(wave_number) * 0.018)
				hunter.health = hunter.max_health
				hunter.damage *= 1.16
				hunter.speed *= 1.08
				hunter.xp_value *= 3
				_spawn_world_pulse_fx(hunter.global_position, Color(0.95, 0.24, 0.44, 0.78), 1.42, 0.46)
				_show_presentation("TRAQUEUR DU RIFT", "ANOMALIE MOBILE  •  PRIME ÉLEVÉE", Color("ff5d68"), 0.90, false)
				_play_sfx(SFX_MINIBOSS_ALERT, -8.0, 0.98, 1.02)
	if dynamic_event_kind != "miniboss":
		var event_color: Color = _dynamic_event_color(dynamic_event_kind)
		_show_presentation(_dynamic_event_name(dynamic_event_kind), "SIGNAL PRIORITAIRE  •  OBJECTIF FACULTATIF", event_color, 0.58, false)
		_play_sfx(SFX_PULSE if dynamic_event_kind in ["corruption", "cache"] else SFX_UI, -13.0, 0.94, 1.06)
	_refresh_dynamic_event_marker()
	_save_profile()

func _refresh_dynamic_event_marker() -> void:
	var marker: NomadZoneObjectiveMarker = _objective_marker("dynamic")
	if marker == null:
		return
	if not dynamic_event_active:
		marker.set_status(false, 0.0, 1.0, "")
		return
	var color: Color = _dynamic_event_color(dynamic_event_kind)
	marker.global_position = dynamic_event_position
	marker.configure(_dynamic_event_name(dynamic_event_kind), color, 104.0 if dynamic_event_kind != "corruption" else 122.0)
	if not dynamic_event_started:
		marker.set_status(true, 0.0, 1.0, "APPROCHE POUR INTERVENIR")
		return
	match dynamic_event_kind:
		"patrol", "ambush":
			marker.set_status(true, float(dynamic_event_kills), maxf(1.0, float(dynamic_event_target_kills)), "%d / %d CIBLES" % [dynamic_event_kills, dynamic_event_target_kills])
		"corruption":
			marker.set_status(true, dynamic_event_progress, dynamic_event_target, "STABILISATION  %.1f / %.0f s" % [dynamic_event_progress, dynamic_event_target])
		"cache":
			marker.set_status(true, 0.0, 1.0, "NOYAU CONTESTÉ")
		"miniboss":
			marker.set_status(true, 0.0, 1.0, "TRAQUEUR ACTIF")
		_:
			marker.set_status(true, dynamic_event_progress, maxf(1.0, dynamic_event_target), "")

func _update_dynamic_world_event(delta: float) -> void:
	if not dynamic_event_active or not is_instance_valid(player):
		return
	dynamic_event_age += delta
	var distance_to_event: float = player.global_position.distance_to(dynamic_event_position)
	if not dynamic_event_started:
		if dynamic_event_age >= 78.0:
			_cancel_dynamic_world_event("SIGNAL PERDU")
			return
		if distance_to_event <= 300.0:
			_begin_dynamic_world_event()
		_refresh_dynamic_event_marker()
		return
	if dynamic_event_age >= 96.0:
		_cancel_dynamic_world_event("ÉVÉNEMENT DISSIPÉ")
		return
	match dynamic_event_kind:
		"patrol", "ambush":
			dynamic_event_spawn_timer -= delta
			var remaining_needed: int = dynamic_event_target_kills - dynamic_event_kills - _active_dynamic_event_enemy_count()
			if remaining_needed > 0 and dynamic_event_spawn_timer <= 0.0 and _active_enemy_count() < MAX_ACTIVE_ENEMIES - 1 and _active_enemy_threat() < _wave_threat_budget() + 2.2:
				dynamic_event_spawn_timer = 0.72
				var reinforcement_kind: String = "stalker" if dynamic_event_kind == "patrol" and wave_number >= 4 and rng.randf() < 0.42 else ("raider" if dynamic_event_kind == "patrol" else ("suppressor" if wave_number >= 4 and rng.randf() < 0.44 else ("blaster" if rng.randf() < 0.56 else "raider")))
				_spawn_dynamic_event_enemy(reinforcement_kind, rng.randf() < 0.14)
		"corruption":
			if distance_to_event <= 132.0:
				dynamic_event_progress = minf(dynamic_event_target, dynamic_event_progress + delta)
			else:
				dynamic_event_progress = maxf(0.0, dynamic_event_progress - delta * 0.58)
			dynamic_event_spawn_timer -= delta
			if dynamic_event_spawn_timer <= 0.0 and _active_enemy_count() < MAX_ACTIVE_ENEMIES - 2 and _active_enemy_threat() < _wave_threat_budget() + 2.2:
				dynamic_event_spawn_timer = 2.35
				var corruption_kind: String = "suppressor" if wave_number >= 5 and rng.randf() < 0.26 else ("blaster" if rng.randf() < 0.62 else "raider")
				_spawn_dynamic_event_enemy(corruption_kind, rng.randf() < 0.14)
			if dynamic_event_progress >= dynamic_event_target:
				_complete_dynamic_world_event(3, "CORRUPTION STABILISÉE")
				return
		"cache":
			dynamic_event_spawn_timer -= delta
			if dynamic_event_spawn_timer <= 0.0 and _active_enemy_count() < MAX_ACTIVE_ENEMIES - 2 and _active_enemy_threat() < _wave_threat_budget() + 2.2:
				dynamic_event_spawn_timer = 4.2
				var cache_guard_kind: String = "sniper" if wave_number >= 6 and rng.randf() < 0.20 else ("suppressor" if wave_number >= 4 and rng.randf() < 0.36 else ("blaster" if rng.randf() < 0.70 else "raider"))
				_spawn_dynamic_event_enemy(cache_guard_kind, rng.randf() < 0.22)
		"miniboss":
			dynamic_event_spawn_timer -= delta
			if _active_dynamic_event_enemy_count() <= 0 and dynamic_event_spawn_timer <= 0.0 and _active_enemy_count() < MAX_ACTIVE_ENEMIES - 1 and _active_enemy_threat() < _wave_threat_budget() + 1.8:
				dynamic_event_spawn_timer = 1.2
				var hunter: NomadEnemy = _spawn_dynamic_event_enemy("breaker", true, "miniboss", "void")
				if hunter != null:
					hunter.max_health *= 1.85 + minf(0.35, float(wave_number) * 0.018)
					hunter.health = hunter.max_health
					hunter.damage *= 1.16
					hunter.speed *= 1.08
					hunter.xp_value *= 3
	_refresh_dynamic_event_marker()

func _complete_dynamic_world_event(reward_rank: int, message: String) -> void:
	if not dynamic_event_active:
		return
	var reward_position: Vector2 = dynamic_event_position
	var completed_kind: String = dynamic_event_kind
	if reward_rank > 0:
		_spawn_loot_roll(reward_position + Vector2(0.0, -26.0), reward_rank, "BOSS" if reward_rank >= 4 else world.zone_name(reward_position))
	var fragment_reward: int = 3 if reward_rank >= 4 else (2 if reward_rank >= 3 else 1)
	if reward_rank == 0:
		fragment_reward = 2
	_spawn_rift_fragment(reward_position + Vector2(28.0, 12.0), fragment_reward)
	dynamic_event_active = false
	dynamic_event_started = false
	dynamic_event_kind = ""
	dynamic_event_progress = 0.0
	dynamic_event_target = 1.0
	dynamic_event_spawn_timer = 0.0
	dynamic_event_age = 0.0
	dynamic_event_kills = 0
	dynamic_event_target_kills = 0
	event_timer = maxf(event_timer, rng.randf_range(28.0, 40.0))
	_refresh_dynamic_event_marker()
	var color: Color = _dynamic_event_color(completed_kind)
	_spawn_hit_fx(reward_position, color, 1.45)
	_shake(4.2, 0.15)
	_haptic(34, 0.50, 0.16)
	_show_toast("%s  •  RÉCOMPENSE DÉPLOYÉE" % message)
	_save_profile()

func _cancel_dynamic_world_event(message: String) -> void:
	if not dynamic_event_active:
		return
	var expired_id: int = dynamic_event_serial
	for node: Node in enemies_root.get_children():
		var enemy: NomadEnemy = node as NomadEnemy
		if enemy != null and int(enemy.get_meta("world_event_id", -1)) == expired_id and player.global_position.distance_to(enemy.global_position) > 520.0:
			enemies_root.remove_child(enemy)
			enemy.queue_free()
	dynamic_event_active = false
	dynamic_event_started = false
	dynamic_event_kind = ""
	dynamic_event_progress = 0.0
	dynamic_event_target = 1.0
	dynamic_event_spawn_timer = 0.0
	dynamic_event_age = 0.0
	dynamic_event_kills = 0
	dynamic_event_target_kills = 0
	event_timer = maxf(event_timer, 14.0)
	_refresh_dynamic_event_marker()
	_show_toast(message)
	_save_profile()

func _trigger_rift_surge() -> void:
	if state != State.PLAYING or not is_instance_valid(player) or wave_cleanup:
		return
	var event_roll: int = rng.randi_range(0, 3)
	if event_roll == 0:
		_show_toast("SURGE DE RIFT  •  CONTACTS EN APPROCHE")
		_flash_rift_overlay()
		_spawn_pulse_fx(Color(0.72, 0.38, 1.0, 0.62), 2.8, 0.55)
		var count: int = mini(7, 4 + floori(float(level) / 4.0))
		for i: int in range(count):
			var force_elite: bool = i == 0 and level >= 4
			_spawn_enemy("", force_elite)
	elif event_roll == 1:
		_show_toast("CHASSEURS DU VIDE  •  UNITÉS D'ÉLITE")
		_flash_rift_overlay(Color(0.78, 0.24, 0.60, 0.20))
		_spawn_pulse_fx(Color(0.92, 0.34, 0.72, 0.62), 2.4, 0.48)
		var elite_count: int = 2 + mini(2, floori(float(level) / 8.0))
		for _i: int in range(elite_count):
			_spawn_enemy("", true)
	elif event_roll == 2:
		_show_toast("CARGO DU RIFT  •  RAVITAILLEMENT CONTESTÉ")
		_flash_rift_overlay(Color(0.22, 0.66, 0.82, 0.14))
		_spawn_supply(player.global_position + Vector2(-70.0, -20.0), "med")
		_spawn_supply(player.global_position + Vector2(70.0, -20.0), "shield")
		_spawn_supply(player.global_position + Vector2(0.0, 64.0), "charge")
		for _i: int in range(3 + mini(3, floori(float(level) / 6.0))):
			_spawn_enemy("", false)
	else:
		_show_toast("ANOMALIE DU RIFT  •  FRAGMENT INSTABLE")
		_flash_rift_overlay(Color(0.96, 0.54, 0.18, 0.18))
		_spawn_rift_fragment(player.global_position + Vector2(rng.randf_range(-90.0, 90.0), rng.randf_range(-70.0, 70.0)), 1)
		_spawn_enemy("heavy", level >= 5)
		for _i: int in range(2 + mini(3, floori(float(level) / 7.0))):
			_spawn_enemy("", _i == 0 and level >= 7)
	_shake(4.0, 0.16)

func _boss_name(boss_kind: String) -> String:
	match boss_kind:
		"marauder": return "MARAUDEUR DU RIFT"
		"archon": return "ARCHONTE DU RIFT"
		"warden": return "GARDIEN NULL"
		"reaper": return "FAUCHEUR DE CENDRE"
		"resonator": return "RÉSONATEUR D'ÉCHO"
		"scrap_titan": return "TITAN FERRAILLEUR"
		_: return "SENTINELLE DU RIFT"

func _miniboss_name(kind: String) -> String:
	return "CHASSEUR PHASE" if kind == "phantom" else ("GARDIEN DES RUINES" if kind == "veil_guardian" else ("BROYEUR DU LÉVIATHAN" if kind == "leviathan_grinder" else "COLOSSE DE LA FAILLE"))

func _boss_portrait_tint(boss_kind: String) -> Color:
	match boss_kind:
		"warden": return Color(0.58, 1.0, 1.0)
		"reaper": return Color(1.0, 0.62, 0.78)
		"resonator": return Color(0.72, 0.88, 0.91)
		"scrap_titan": return Color(0.96, 0.88, 0.74)
		_: return Color.WHITE

func _boss_tagline(boss_kind: String) -> String:
	match boss_kind:
		"marauder": return "ASSAUT RAPPROCHÉ  •  CHARGES BRUTALES"
		"archon": return "TECHNOMANCIE  •  FAILLES INSTABLES"
		"warden": return "GRILLE NULL  •  VERROUILLAGE TACTIQUE"
		"reaper": return "BONDS DE CENDRE  •  EXÉCUTION RAPPROCHÉE"
		"resonator": return "RÉSONANCE DU CANYON  •  CONTRÔLE DES COULOIRS"
		"scrap_titan": return "MAGNÉTISME DE FERRAILLE  •  BROYAGE INDUSTRIEL"
		_: return "ARTILLERIE VIOLETTE  •  CONTRÔLE DE ZONE"

func _boss_attack_name(pattern: String) -> String:
	match pattern:
		"slam": return "IMPACT"
		"charge": return "CHARGE"
		"cross": return "ENTAILLE CROISÉE"
		"fan": return "ÉVENTAIL"
		"sniper": return "TIR PRÉCIS"
		"rails": return "RAILS PARALLÈLES"
		"beam": return "RAYON"
		"triad": return "TROIS ZONES"
		"halo": return "ANNEAU"
		"grid": return "GRILLE NULL"
		"burst": return "SALVE PRISMATIQUE"
		"cage": return "CAGE NULL"
		"leap": return "BOND DE CENDRE"
		"cleave": return "FAUCHE"
		"shockring": return "ONDE DE CENDRE"
		"echo_lines": return "LIGNES D'ÉCHO"
		"echo_pulse": return "DOUBLE PULSATION"
		"echo_collapse": return "EFFONDREMENT RÉSONANT"
		"magnet_rails": return "RAILS MAGNÉTIQUES"
		"scrap_burst": return "SALVE DE DÉBRIS"
		"crusher_ring": return "ANNEAU BROYEUR"
		_: return "ATTAQUE"

func _boss_color(boss_kind: String) -> Color:
	match boss_kind:
		"marauder": return Color("ff914f")
		"archon": return Color("a5eb68")
		"warden": return Color("55e8ff")
		"reaper": return Color("ff5f91")
		"resonator": return Color("83bdc9")
		"scrap_titan": return Color("d88442")
		_: return Color("b98bff")

func _on_boss_phase_changed(enemy: NomadEnemy, phase: int) -> void:
	if not is_instance_valid(enemy) or not enemy.active or enemy != boss_enemy:
		return
	var phase_color: Color = _boss_color(enemy.kind)
	_show_presentation("PHASE %s" % _roman(phase), _boss_name(enemy.kind) + "  •  PROTOCOLE RENFORCÉ", phase_color, 0.72, false)
	_play_sfx(SFX_BOSS_PHASE, -8.0, 0.98, 1.03)
	var flash_color: Color = phase_color
	flash_color.a = 0.18
	_flash_rift_overlay(flash_color)
	_spawn_hit_fx(enemy.global_position, _boss_color(enemy.kind), 1.5)
	_shake(5.0, 0.18)
	_haptic(45, 0.54, 0.25)

func _spawn_wave_miniboss() -> void:
	if not is_instance_valid(player) or is_instance_valid(boss_enemy):
		return
	var current_zone: String = world.zone_name(player.global_position)
	var canyon_run: bool = current_zone == "CANYON DES ÉCHOS"
	var graveyard_run: bool = current_zone == "CIMETIÈRE D’ÉPAVES"
	var kind: String = "veil_guardian" if canyon_run else ("leviathan_grinder" if graveyard_run else ("phantom" if int(wave_number / 6) % 2 == 1 else "colossus"))
	var mini_spawn: Variant = world.echo_ruins_position() if canyon_run and world.has_method("echo_ruins_position") else (world.leviathan_position() if graveyard_run and world.has_method("leviathan_position") else null)
	var mini: NomadEnemy = _spawn_enemy(kind, false, mini_spawn)
	if mini == null:
		return
	var mini_color: Color = Color("70cfff") if kind == "phantom" else (Color("b57cff") if kind == "veil_guardian" else (Color("d9793c") if kind == "leviathan_grinder" else Color("ff9a4c")))
	_show_presentation("MENACE ÉLITE", _miniboss_name(kind) + "  •  VAGUE %d" % wave_number, mini_color, 0.82, false)
	_play_sfx(SFX_MINIBOSS_ALERT, -7.0, 0.94, 1.0)
	_spawn_world_pulse_fx(mini.global_position, mini_color, 1.75, 0.42)
	_haptic(32, 0.42, 0.18)

func _spawn_wave_boss() -> void:
	if not is_instance_valid(player) or is_instance_valid(boss_enemy):
		return
	if dynamic_event_active:
		_cancel_dynamic_world_event("SIGNAL INTERROMPU  •  BRÈCHE MAJEURE")
	var boss_kind: String = "sentinel"
	var current_zone: String = world.zone_name(player.global_position)
	var in_canyon: bool = current_zone == "CANYON DES ÉCHOS"
	var in_graveyard: bool = current_zone == "CIMETIÈRE D’ÉPAVES"
	if in_graveyard and wave_number >= 10 and wave_number % 10 == 0:
		boss_kind = "scrap_titan"
	elif in_canyon and wave_number >= 10 and wave_number % 10 == 0:
		boss_kind = "resonator"
	else:
		match wave_number % 25:
			10: boss_kind = "marauder"
			15: boss_kind = "archon"
			20: boss_kind = "warden"
			0: boss_kind = "reaper"
	var boss_spawn: Variant = world.echo_resonator_position() if boss_kind == "resonator" and world.has_method("echo_resonator_position") else (world.iron_pit_position() if boss_kind == "scrap_titan" and world.has_method("iron_pit_position") else null)
	var boss: NomadEnemy = _spawn_enemy(boss_kind, false, boss_spawn)
	if boss == null:
		return
	boss_enemy = boss
	_clear_boss_hazards()
	boss_event_timer = 3.4
	boss_event_count = 0
	boss_encounters[boss_kind] = int(boss_encounters.get(boss_kind, 0)) + 1
	boss_bar.visible = true
	boss_label.text = _boss_name(boss_kind)
	_style_bar(boss_bar, _boss_color(boss_kind), 5)
	var arrival_color: Color = _boss_color(boss_kind)
	arrival_color.a = 0.86
	_show_presentation("SIGNATURE MAJEURE", boss_label.text + "  •  " + _boss_tagline(boss_kind) + "  •  VAGUE %d" % wave_number, arrival_color, 1.12, true)
	_play_sfx(SFX_BOSS_ARRIVAL, -5.0, 0.98, 1.02)
	_spawn_world_pulse_fx(boss.global_position, arrival_color, 2.45, 0.58)
	_spawn_world_pulse_fx(boss.global_position, Color(1.0, 1.0, 1.0, 0.48), 1.45, 0.34, 0.08)
	_shake(6.0, 0.22)
	_haptic(58, 0.72, 0.28)
	if wave_number >= 10:
		if boss_kind == "resonator":
			_spawn_enemy("echo_scout", true)
			_spawn_enemy("veil_tech", true)
		elif boss_kind == "scrap_titan":
			_spawn_enemy("salvage_drone", true)
			_spawn_enemy("mobile_turret", true)
		else:
			_spawn_enemy("blaster", true)
			_spawn_enemy("raider", true)
	_save_profile()

func _canyon_secret_sites() -> Dictionary:
	return {
		"veil_archive": Vector2(3395.0, 1035.0),
		"buried_reactor": Vector2(3765.0, 1595.0),
		"resonant_shard": Vector2(4000.0, 1215.0),
		"silent_vault": Vector2(3875.0, 585.0)
	}

func _canyon_secret_title(secret_id: String) -> String:
	match secret_id:
		"veil_archive": return "ARCHIVE DU VOILE"
		"buried_reactor": return "CŒUR ENFOUI"
		"resonant_shard": return "ÉCLAT RÉSONANT"
		"silent_vault": return "CHAMBRE SILENCIEUSE"
		_: return "TRACE INCONNUE"

func _canyon_secret_color(secret_id: String) -> Color:
	match secret_id:
		"veil_archive": return Color("87d8ff")
		"buried_reactor": return Color("f3a55b")
		"resonant_shard": return Color("b787ff")
		"silent_vault": return Color("e7ddff")
		_: return Color("a8d9b0")

func _spawn_canyon_secrets() -> void:
	if secrets_root == null or not is_instance_valid(player):
		return
	var existing: Dictionary = {}
	for node: Node in secrets_root.get_children():
		if node is NomadCanyonSecret:
			existing[(node as NomadCanyonSecret).secret_id] = true
	var sites: Dictionary = _canyon_secret_sites()
	for key: Variant in sites.keys():
		var secret_id: String = String(key)
		if bool(canyon_secrets.get(secret_id, false)) or bool(existing.get(secret_id, false)):
			continue
		if secret_id == "silent_vault" and int(boss_defeats.get("resonator", 0)) <= 0:
			continue
		var secret: NomadCanyonSecret = CanyonSecretScript.new() as NomadCanyonSecret
		secret.configure(secret_id)
		secret.player = player
		var desired: Vector2 = sites[secret_id]
		secret.global_position = world.nearest_open_area(desired, 22.0, 54.0, 0.60, 260.0)
		secret.discovered.connect(_on_canyon_secret_discovered)
		secrets_root.add_child(secret)

func _apply_canyon_secret_bonus(secret_id: String, immediate: bool = false) -> void:
	if not is_instance_valid(player):
		return
	match secret_id:
		"veil_archive":
			player.magnet_range += 8.0
			player.critical_chance = minf(0.42, player.critical_chance + 0.006)
		"buried_reactor":
			player.max_health += 8.0
			player.health = minf(player.max_health, player.health + (8.0 if immediate else 0.0))
			player.regeneration += 0.02
		"resonant_shard":
			player.force_wave_radius += 8.0
			player.pulse_cooldown = maxf(2.6, player.pulse_cooldown - 0.08)
			player.saber_range += 4.0
		"silent_vault":
			player.armor = minf(0.32, player.armor + 0.008)
			player.critical_multiplier += 0.025

func _apply_canyon_profile_bonuses() -> void:
	for secret_id: String in ["veil_archive", "buried_reactor", "resonant_shard", "silent_vault"]:
		if bool(canyon_secrets.get(secret_id, false)):
			_apply_canyon_secret_bonus(secret_id, false)
	if canyon_mastery and is_instance_valid(player):
		player.speed *= 1.02
		run_xp_multiplier *= 1.03
	if is_instance_valid(player):
		player.health = player.max_health

func _on_canyon_secret_discovered(secret_id: String, world_position: Vector2) -> void:
	if bool(canyon_secrets.get(secret_id, false)):
		return
	canyon_secrets[secret_id] = true
	_apply_canyon_secret_bonus(secret_id, true)
	var fragment_reward: int = 5
	match secret_id:
		"veil_archive": fragment_reward = 5
		"buried_reactor": fragment_reward = 6
		"resonant_shard": fragment_reward = 7
		"silent_vault": fragment_reward = 8
	rift_fragments += fragment_reward
	run_fragments += fragment_reward
	var color: Color = _canyon_secret_color(secret_id)
	_spawn_world_pulse_fx(world_position, Color(color.r, color.g, color.b, 0.72), 1.25, 0.34)
	_play_sfx(SFX_LOOT_RARE, -13.0, 0.98, 1.04)
	_haptic(32, 0.42, 0.12)
	_show_presentation("DÉCOUVERTE", _canyon_secret_title(secret_id) + "  •  +%d FRAG." % fragment_reward, color, 0.72, false)
	var complete: bool = true
	for required_id: String in ["veil_archive", "buried_reactor", "resonant_shard", "silent_vault"]:
		if not bool(canyon_secrets.get(required_id, false)):
			complete = false
			break
	if complete and not canyon_mastery:
		canyon_mastery = true
		if is_instance_valid(player):
			player.speed *= 1.02
			run_xp_multiplier *= 1.03
		rift_fragments += 8
		run_fragments += 8
		_show_presentation("CANYON CARTOGRAPHIÉ", "INSTINCT DU PISTEUR  •  BONUS PERMANENT", Color("d7c1ff"), 1.0, true)
	_save_profile()

func _spawn_force_wave_fx(color: Color, radius: float) -> void:
	if not is_instance_valid(player):
		return
	_spawn_pulse_fx(color, maxf(1.9, radius / 118.0), 0.32)
	for ring_index: int in range(2):
		_trim_fx_budget()
		var ring: Line2D = Line2D.new()
		ring.width = 5.5 - float(ring_index) * 1.4
		ring.default_color = Color(color.r, color.g, color.b, 0.85 - float(ring_index) * 0.22)
		ring.closed = true
		var points: int = 28
		var start_radius: float = 28.0 + float(ring_index) * 16.0
		for step: int in range(points):
			var ang: float = TAU * float(step) / float(points)
			ring.add_point(Vector2.RIGHT.rotated(ang) * start_radius)
		ring.global_position = player.global_position
		ring.z_index = 3450 + ring_index
		fx_root.add_child(ring)
		var ring_scale: float = radius / maxf(start_radius * 1.6, 1.0)
		var ring_tween: Tween = create_tween()
		ring_tween.set_parallel(true)
		ring_tween.tween_property(ring, "scale", Vector2.ONE * ring_scale, 0.24 + float(ring_index) * 0.05)
		ring_tween.tween_property(ring, "modulate:a", 0.0, 0.26 + float(ring_index) * 0.06)
		ring_tween.finished.connect(ring.queue_free)
	for i: int in range(8):
		_trim_fx_budget()
		var ray: Line2D = Line2D.new()
		var ray_angle: float = TAU * float(i) / 8.0 + rng.randf_range(-0.08, 0.08)
		var direction: Vector2 = Vector2.RIGHT.rotated(ray_angle)
		ray.width = rng.randf_range(2.2, 3.8)
		ray.default_color = Color(0.90, 1.0, 1.0, 0.92)
		ray.add_point(direction * 18.0)
		ray.add_point(direction * rng.randf_range(radius * 0.56, radius * 0.84))
		ray.global_position = player.global_position
		ray.z_index = 3465
		fx_root.add_child(ray)
		var ray_tween: Tween = create_tween()
		ray_tween.set_parallel(true)
		ray_tween.tween_property(ray, "modulate:a", 0.0, 0.18)
		ray_tween.tween_property(ray, "scale", Vector2.ONE * 1.12, 0.18)
		ray_tween.finished.connect(ray.queue_free)
	_spawn_combat_sparks(player.global_position, color, 6, 1.18)

func _spawn_saber_slash_fx(origin_value: Vector2, direction: Vector2, range_value: float, arc_degrees: float, empowered: bool = false) -> void:
	var dir: Vector2 = direction.normalized() if direction.length_squared() > 0.01 else Vector2.RIGHT
	var center_angle: float = dir.angle()
	var span: float = deg_to_rad(clampf(arc_degrees * 0.70, 44.0, 82.0))
	for layer: int in range(2):
		_trim_fx_budget()
		var slash: Line2D = Line2D.new()
		slash.width = (5.8 if empowered else 4.8) if layer == 0 else 1.8
		slash.default_color = Color(0.58, 0.84, 0.88, 0.62) if layer == 0 else Color(0.96, 0.97, 0.94, 0.92)
		var arc_radius: float = clampf(range_value * (0.31 + float(layer) * 0.055), 78.0, 122.0)
		var forward_offset: Vector2 = dir * (36.0 + float(layer) * 8.0)
		for step: int in range(10):
			var ratio: float = float(step) / 9.0
			var angle: float = center_angle - span * 0.5 + span * ratio
			slash.add_point(forward_offset + Vector2.RIGHT.rotated(angle) * arc_radius)
		slash.global_position = origin_value
		slash.z_index = 3650 + layer
		fx_root.add_child(slash)
		var slash_tween: Tween = create_tween()
		slash_tween.set_parallel(true)
		slash_tween.tween_property(slash, "modulate:a", 0.0, 0.095 + float(layer) * 0.025)
		slash_tween.tween_property(slash, "scale", Vector2.ONE * (1.025 + float(layer) * 0.012), 0.11)
		slash_tween.finished.connect(slash.queue_free)

func _spawn_saber_impact_fx(position_value: Vector2, color: Color, intensity: float = 1.0) -> void:
	_trim_fx_budget()
	var cut: Line2D = Line2D.new()
	var base_angle: float = rng.randf_range(-0.8, 0.8)
	var direction: Vector2 = Vector2.RIGHT.rotated(base_angle)
	var normal: Vector2 = direction.orthogonal()
	cut.width = 4.4 * intensity
	cut.default_color = Color(1.0, 1.0, 1.0, 0.92)
	cut.add_point(-direction * 10.0 * intensity - normal * 4.0)
	cut.add_point(direction * 12.0 * intensity + normal * 4.0)
	cut.global_position = position_value
	cut.z_index = 3670
	fx_root.add_child(cut)
	var cut_tween: Tween = create_tween()
	cut_tween.set_parallel(true)
	cut_tween.tween_property(cut, "modulate:a", 0.0, 0.10)
	cut_tween.tween_property(cut, "scale", Vector2.ONE * 1.25, 0.10)
	cut_tween.finished.connect(cut.queue_free)
	_spawn_combat_sparks(position_value, color, 2 if intensity < 1.15 else 3, 0.95 * intensity)

func _spawn_pulse_fx(color: Color, end_scale: float, duration: float) -> void:
	if not is_instance_valid(player):
		return
	_spawn_world_pulse_fx(player.global_position, color, end_scale, duration)

func _spawn_hit_fx(position_value: Vector2, color: Color, intensity: float = 1.0) -> void:
	_trim_fx_budget()
	var fx: Sprite2D = Sprite2D.new()
	fx.texture = HIT_TEXTURE
	fx.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	fx.global_position = position_value
	var start_scale: float = 0.13 * intensity
	fx.scale = Vector2(start_scale, start_scale)
	fx.modulate = Color(color.r, color.g, color.b, minf(color.a, 0.82))
	fx.z_index = 3640
	fx_root.add_child(fx)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(fx, "scale", Vector2(0.35, 0.35) * intensity, 0.105)
	tween.tween_property(fx, "modulate:a", 0.0, 0.13)
	tween.finished.connect(fx.queue_free)

func _spawn_ground_impact_fx(position_value: Vector2, color: Color, intensity: float = 1.0) -> void:
	if adaptive_quality == QUALITY_LOW and _active_enemy_count() >= 12:
		return
	_trim_fx_budget()
	var ring: Line2D = Line2D.new()
	ring.width = 1.6 * intensity
	ring.default_color = Color(color.r, color.g, color.b, 0.34)
	for i: int in range(15):
		var a: float = TAU * float(i) / 14.0
		ring.add_point(Vector2(cos(a) * 14.0, sin(a) * 6.0) * intensity)
	ring.global_position = position_value
	ring.z_index = 3625
	fx_root.add_child(ring)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(ring, "scale", Vector2.ONE * 1.65, 0.17)
	tween.tween_property(ring, "modulate:a", 0.0, 0.17)
	tween.finished.connect(ring.queue_free)

func _spawn_combat_sparks(position_value: Vector2, color: Color, count: int, intensity: float = 1.0) -> void:
	if adaptive_quality == QUALITY_LOW:
		count = mini(count, 1)
	elif adaptive_quality == QUALITY_BALANCED:
		count = mini(count, 3)
	var active_enemies: int = _active_enemy_count()
	if active_enemies >= 16:
		count = mini(count, 1)
	elif active_enemies >= 11:
		count = mini(count, 2)
	for _i: int in range(count):
		_trim_fx_budget()
		var spark: Line2D = Line2D.new()
		var angle: float = rng.randf_range(0.0, TAU)
		var length: float = rng.randf_range(15.0, 28.0) * intensity
		var direction: Vector2 = Vector2.RIGHT.rotated(angle)
		spark.width = rng.randf_range(1.4, 2.5) * intensity
		spark.default_color = Color(color.r, color.g, color.b, 0.92)
		spark.add_point(Vector2.ZERO)
		spark.add_point(direction * length)
		spark.global_position = position_value + direction * rng.randf_range(1.0, 7.0)
		spark.z_index = 3660
		fx_root.add_child(spark)
		var end_position: Vector2 = spark.position + direction * rng.randf_range(14.0, 32.0) * intensity
		var tween: Tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(spark, "position", end_position, 0.12)
		tween.tween_property(spark, "modulate:a", 0.0, 0.14)
		tween.finished.connect(spark.queue_free)

func _spawn_death_fx(position_value: Vector2, kind: String, was_elite: bool, was_boss: bool) -> void:
	var color: Color = Color(0.46, 0.92, 1.0)
	if kind == "raider" or kind == "marauder":
		color = Color(1.0, 0.48, 0.24)
	elif kind == "stalker":
		color = Color(0.34, 1.0, 0.60)
	elif kind == "sniper":
		color = Color(0.38, 0.84, 1.0)
	elif kind == "suppressor":
		color = Color(1.0, 0.56, 0.22)
	elif kind == "breaker":
		color = Color(1.0, 0.30, 0.15)
	elif kind == "heavy" or kind == "sentinel":
		color = Color(0.64, 0.82, 1.0)
	elif kind == "archon":
		color = Color(0.61, 1.0, 0.36)
	elif kind == "phantom" or kind == "warden":
		color = Color(0.35, 0.90, 1.0)
	elif kind == "colossus":
		color = Color(1.0, 0.58, 0.20)
	elif kind == "reaper":
		color = Color(1.0, 0.30, 0.56)
	elif kind in ["salvage_drone", "mobile_turret"]:
		color = Color(0.38, 0.82, 0.84)
	elif kind in ["scrap_automaton", "leviathan_grinder", "scrap_titan"]:
		color = Color(0.88, 0.50, 0.24)
	if was_elite:
		color = Color(1.0, 0.74, 0.30)
	if was_boss:
		color = _boss_color(kind)
	_spawn_hit_fx(position_value, color, 1.35 if was_boss else (1.04 if was_elite else 0.78))
	_spawn_ground_impact_fx(position_value + Vector2(0.0, 18.0), Color(0.67, 0.57, 0.44, 0.58), 1.55 if was_boss else (1.12 if was_elite else 0.84))
	_spawn_combat_sparks(position_value, color, 5 if was_boss else (3 if was_elite else 2), 1.24 if was_boss else 0.90)

func _spawn_muzzle(position_value: Vector2, angle: float, enemy_shot: bool, tint: Color = Color(0.88, 0.34, 0.22), style: String = "standard") -> void:
	if adaptive_quality == QUALITY_LOW and enemy_shot and _active_enemy_count() >= 10:
		return
	_trim_fx_budget()
	var fx: Sprite2D = Sprite2D.new()
	fx.texture = MUZZLE_TEXTURE
	fx.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	fx.global_position = position_value
	fx.rotation = angle
	var base_scale: Vector2 = Vector2(0.15, 0.10)
	if style == "sniper" or style == "rail": base_scale = Vector2(0.21, 0.075)
	elif style == "suppressor": base_scale = Vector2(0.17, 0.12)
	fx.scale = base_scale
	fx.modulate = Color(tint.r, tint.g, tint.b, 0.84) if enemy_shot else Color(0.52, 0.90, 0.68, 0.82)
	fx.z_index = 3680
	fx_root.add_child(fx)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(fx, "scale", fx.scale * 1.45, 0.042)
	tween.tween_property(fx, "modulate:a", 0.0, 0.065)
	tween.finished.connect(fx.queue_free)

func _spawn_combat_text(position_value: Vector2, message: String, color: Color, font_size: int = 17) -> void:
	_trim_fx_budget()
	var label: Label = Label.new()
	label.text = message
	label.position = position_value - Vector2(72.0, 16.0)
	label.size = Vector2(144.0, 32.0)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.02, 0.02, 0.02, 0.90))
	label.add_theme_constant_override("outline_size", 3)
	label.z_index = 3810
	fx_root.add_child(label)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 34.0, 0.52)
	tween.tween_property(label, "modulate:a", 0.0, 0.40).set_delay(0.18)
	tween.finished.connect(label.queue_free)

func _spawn_damage_number(position_value: Vector2, amount: float, color: Color, critical: bool = false) -> void:
	if not critical:
		var crowd_limit: int = 9 if adaptive_quality == QUALITY_LOW else (11 if adaptive_quality == QUALITY_BALANCED else 12)
		if _active_enemy_count() >= crowd_limit:
			return
	var label: Label = Label.new()
	label.text = str(roundi(amount))
	label.position = position_value - Vector2(34.0, 18.0)
	label.size = Vector2(68.0, 32.0)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 20 if critical else 15)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.02, 0.02, 0.02, 0.88))
	label.add_theme_constant_override("outline_size", 3)
	if critical:
		label.text = str(roundi(amount))
		label.add_theme_constant_override("outline_size", 4)
	label.z_index = 3800
	fx_root.add_child(label)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 42.0, 0.48)
	tween.tween_property(label, "modulate:a", 0.0, 0.48).set_delay(0.10)
	tween.finished.connect(label.queue_free)

func _trim_fx_budget() -> void:
	# V44.49 : le budget visuel s'adapte aux FPS sans toucher aux collisions ni aux dégâts.
	# queue_free() alone does not reduce child_count until end-of-frame; detach first.
	while fx_root.get_child_count() >= _fx_budget():
		var node: Node = fx_root.get_child(0)
		if node == null:
			break
		fx_root.remove_child(node)
		node.queue_free()

func _cleanup_distant_entities() -> void:
	if not is_instance_valid(player): return
	var p: Vector2 = player.global_position
	for node: Node in enemies_root.get_children():
		var enemy: NomadEnemy = node as NomadEnemy
		if enemy == null or not enemy.active or enemy.is_boss():
			continue
		if dynamic_event_active and int(enemy.get_meta("world_event_id", -1)) == dynamic_event_serial:
			continue
		if p.distance_squared_to(enemy.global_position) > 1320.0 * 1320.0:
			enemies_root.remove_child(enemy)
			enemy.queue_free()
	for node: Node in pickups_root.get_children():
		var pickup: Node2D = node as Node2D
		if pickup == null or pickup is NomadLootCache:
			continue
		if p.distance_squared_to(pickup.global_position) > 1200.0 * 1200.0:
			pickups_root.remove_child(pickup)
			pickup.queue_free()


func _shake(strength: float, duration: float) -> void:
	shake_strength = maxf(shake_strength, strength)
	shake_time = maxf(shake_time, duration)

func _update_camera_shake(delta: float) -> void:
	if not is_instance_valid(world_camera):
		return
	if shake_time > 0.0:
		shake_time = maxf(0.0, shake_time - delta)
		world_camera.offset = Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))
	else:
		world_camera.offset = world_camera.offset.lerp(Vector2.ZERO, minf(1.0, delta * 18.0))
		shake_strength = 0.0

func _update_threat_indicator() -> void:
	if threat_label == null or not is_instance_valid(player) or enemies_root == null:
		return
	var selected: NomadEnemy = null
	var selected_distance: float = INF
	for node: Node in enemies_root.get_children():
		var enemy: NomadEnemy = node as NomadEnemy
		if enemy == null or not enemy.active or not enemy.has_active_telegraph():
			continue
		var distance: float = player.global_position.distance_to(enemy.global_position)
		if distance < selected_distance:
			selected = enemy
			selected_distance = distance
	if selected == null:
		threat_label.visible = false
		threat_label.text = ""
		return
	var delta_to_threat: Vector2 = selected.global_position - player.global_position
	var direction_text: String = ""
	var arrow: String = ""
	if absf(delta_to_threat.x) > absf(delta_to_threat.y):
		direction_text = "EST" if delta_to_threat.x >= 0.0 else "OUEST"
		arrow = "→" if delta_to_threat.x >= 0.0 else "←"
	else:
		direction_text = "SUD" if delta_to_threat.y >= 0.0 else "NORD"
		arrow = "↓" if delta_to_threat.y >= 0.0 else "↑"
	var label_text: String = selected.telegraph_label()
	if label_text.is_empty():
		label_text = "MENACE"
	threat_label.text = "⚠  %s  %s  •  %s" % [arrow, label_text, direction_text]
	threat_label.add_theme_color_override("font_color", Color("9eeeff") if label_text == "SNIPER" else (Color("c690ff") if label_text == "VOID" or label_text == "BOSS" else Color("ffcc7a")))
	var viewport_size: Vector2 = get_viewport_rect().size
	var zoom_value: Vector2 = world_camera.zoom if is_instance_valid(world_camera) else Vector2(0.66, 0.66)
	var half_world: Vector2 = Vector2(viewport_size.x / maxf(0.1, zoom_value.x), viewport_size.y / maxf(0.1, zoom_value.y)) * 0.5
	threat_label.visible = absf(delta_to_threat.x) > half_world.x * 0.88 or absf(delta_to_threat.y) > half_world.y * 0.82

func _update_hud() -> void:
	if not is_instance_valid(player):
		return
	health_bar.max_value = player.max_health
	health_bar.value = player.health
	xp_bar.max_value = xp_needed
	xp_bar.value = xp
	hp_label.text = "%d / %d" % [roundi(player.health), roundi(player.max_health)]
	xp_label.text = "%d / %d" % [xp, xp_needed]
	level_label.text = "NIV. %d" % level
	kills_label.text = "KO %d" % kills
	var minutes: int = floori(run_time / 60.0)
	var seconds: int = int(run_time) % 60
	time_label.text = "%02d:%02d" % [minutes, seconds]
	zone_label.text = _player_zone()
	zone_label.add_theme_color_override("font_color", _zone_color(zone_label.text))
	_update_threat_indicator()
	fragment_label.text = "FRAG %d  •  MOD %d" % [rift_fragments, run_module_count]
	var compact_wave: bool = hud_wave_panel.size.x < 222.0
	if wave_cleanup:
		if wave_intermission >= 0.0:
			event_label.text = "V.%d  •  %.0f s" % [wave_number, wave_intermission] if compact_wave else "VAGUE %d  •  REPRISE %.1f s" % [wave_number, wave_intermission]
		else:
			event_label.text = "V.%d  •  FIN" % wave_number if compact_wave else "VAGUE %d  •  NETTOYAGE" % wave_number
	else:
		var wave_seconds: int = maxi(0, ceili(wave_time_left))
		var wave_minutes: int = floori(float(wave_seconds) / 60.0)
		event_label.text = "V.%d  •  %02d:%02d" % [wave_number, wave_minutes, wave_seconds % 60] if compact_wave else "VAGUE %d  •  %02d:%02d" % [wave_number, wave_minutes, wave_seconds % 60]
	if is_instance_valid(boss_enemy) and boss_enemy.active:
		var hazard: NomadBossHazard = null
		if boss_hazards_root.get_child_count() > 0:
			hazard = boss_hazards_root.get_child(0) as NomadBossHazard
			if hazard != null and hazard.is_queued_for_deletion():
				hazard = null
		boss_bar.visible = true
		boss_bar.max_value = boss_enemy.max_health
		boss_bar.value = boss_enemy.health
		boss_label.text = (boss_enemy.kind.to_upper() if compact_wave else _boss_name(boss_enemy.kind)) + ("  •  II" if boss_enemy.phase_two else "  •  I")
		boss_label.add_theme_color_override("font_color", _boss_color(boss_enemy.kind))
		boss_move_label.visible = boss_enemy.windup_left > 0.0 or boss_enemy.exposed_timer > 0.0 or hazard != null
		if boss_enemy.windup_left > 0.0:
			boss_move_label.text = "%s  %.1f s" % [_boss_attack_name(boss_enemy.windup_pattern), boss_enemy.windup_left]
			boss_move_label.add_theme_color_override("font_color", _boss_color(boss_enemy.kind))
		elif hazard != null and hazard.warning_left > 0.0:
			var name: String = hazard.warning_name()
			if compact_wave:
				name = "TIRS" if hazard.boss_kind == "sentinel" else ("FAILLES" if hazard.boss_kind == "archon" else ("GRILLE" if hazard.boss_kind == "warden" else ("CENDRES" if hazard.boss_kind == "reaper" else "PERCÉE")))
			boss_move_label.text = "%s  %.1f s" % [name, hazard.warning_left]
			boss_move_label.add_theme_color_override("font_color", _boss_color(hazard.boss_kind))
		elif boss_enemy.exposed_timer > 0.0:
			boss_move_label.text = "BRÈCHE +20 %%  %.1f s" % boss_enemy.exposed_timer
			boss_move_label.add_theme_color_override("font_color", Color("d6ffae"))
		elif hazard != null:
			boss_move_label.text = "%s  ACTIVE" % ("ZONE" if compact_wave else hazard.warning_name())
			boss_move_label.add_theme_color_override("font_color", _boss_color(hazard.boss_kind))
	else:
		boss_bar.visible = false
		boss_label.text = _wave_pattern_label() if not wave_cleanup else ""
		boss_label.add_theme_color_override("font_color", Color("d8dfe2"))
		boss_move_label.visible = false

func _meta_upgrade_cost(rank: int) -> int:
	return 8 + rank * 7 + maxi(0, rank - 4) * 4

func _meta_specialization_cost(rank: int) -> int:
	return 18 + rank * 14

func _meta_relic_cost() -> int:
	return 55

func _buy_meta_upgrade(kind: String) -> void:
	var rank: int = meta_instinct_rank
	if kind == "damage":
		rank = meta_damage_rank
	elif kind == "health":
		rank = meta_health_rank
	if rank >= 10:
		return
	var cost: int = _meta_upgrade_cost(rank)
	if rift_fragments < cost:
		_show_toast("FRAGMENTS INSUFFISANTS")
		return
	rift_fragments -= cost
	if kind == "damage":
		meta_damage_rank += 1
	elif kind == "health":
		meta_health_rank += 1
	else:
		meta_instinct_rank += 1
	_save_profile()
	_update_menu_stats()
	_play_sfx(SFX_LEVEL, -10.0, 1.04, 1.10)

func _buy_meta_specialization(kind: String) -> void:
	var rank: int = meta_fury_rank
	var core_rank: int = meta_damage_rank
	if kind == "resilience":
		rank = meta_resilience_rank
		core_rank = meta_health_rank
	elif kind == "scavenger":
		rank = meta_scavenger_rank
		core_rank = meta_instinct_rank
	if core_rank < 3:
		_show_toast("PRÉREQUIS  •  VOIE PRINCIPALE RANG 3")
		return
	if rank >= 5:
		return
	var cost: int = _meta_specialization_cost(rank)
	if rift_fragments < cost:
		_show_toast("FRAGMENTS INSUFFISANTS")
		return
	rift_fragments -= cost
	if kind == "fury":
		meta_fury_rank += 1
	elif kind == "resilience":
		meta_resilience_rank += 1
	else:
		meta_scavenger_rank += 1
	_save_profile()
	_update_menu_stats()
	_play_sfx(SFX_LEVEL, -9.0, 1.06, 1.12)

func _buy_meta_relic(kind: String) -> void:
	var already_owned: bool = meta_marauder_node
	var specialization_rank: int = meta_fury_rank
	var signature_id: String = "marauder_ember"
	if kind == "sentinel":
		already_owned = meta_sentinel_node
		specialization_rank = meta_resilience_rank
		signature_id = "sentinel_bastion"
	elif kind == "archon":
		already_owned = meta_archon_node
		specialization_rank = meta_scavenger_rank
		signature_id = "archon_conduit"
	if already_owned:
		return
	if specialization_rank < 3:
		_show_toast("PRÉREQUIS  •  SPÉCIALISATION RANG 3")
		return
	if not bool(boss_signatures.get(signature_id, false)):
		_show_toast("RELIQUE DE BOSS NON DÉCOUVERTE")
		return
	var cost: int = _meta_relic_cost()
	if rift_fragments < cost:
		_show_toast("FRAGMENTS INSUFFISANTS")
		return
	rift_fragments -= cost
	if kind == "marauder":
		meta_marauder_node = true
	elif kind == "sentinel":
		meta_sentinel_node = true
	else:
		meta_archon_node = true
	_save_profile()
	_update_menu_stats()
	_show_toast("NŒUD DE RELIQUE ACTIVÉ")
	_play_sfx(SFX_LEVEL, -6.0, 0.96, 1.04)

func _set_meta_tree_button(key: String, text_value: String, enabled: bool, accent: Color) -> void:
	if not meta_tree_buttons.has(key):
		return
	var button: Button = meta_tree_buttons[key] as Button
	button.text = text_value
	button.disabled = not enabled
	button.add_theme_font_size_override("font_size", 15)
	button.add_theme_color_override("font_color", accent.lightened(0.16))
	button.add_theme_color_override("font_disabled_color", Color(0.47, 0.54, 0.56, 1.0))

func _update_meta_buttons() -> void:
	if meta_damage_button == null or meta_health_button == null or meta_instinct_button == null:
		return
	# Accueil V44.45c : une seule action, les trois rangs restent lisibles sans bouton concurrent.
	meta_damage_button.visible = true
	meta_damage_button.disabled = false
	meta_damage_button.text = "OUVRIR LA MATRICE"
	meta_damage_button.add_theme_font_size_override("font_size", 20 if not menu_compact else 18)
	meta_health_button.visible = false
	meta_instinct_button.visible = false
	if menu_meta_summary_label != null:
		menu_meta_summary_label.text = "PUISSANCE %d/10   •   COQUE %d/10   •   INSTINCT %d/10" % [meta_damage_rank, meta_health_rank, meta_instinct_rank]
		menu_meta_summary_label.add_theme_font_size_override("font_size", 13 if not menu_compact else 12)
	if meta_tree_overlay == null:
		return
	if meta_tree_fragment_label != null:
		meta_tree_fragment_label.text = "◆  %d FRAGMENTS" % rift_fragments
	var damage_cost: int = _meta_upgrade_cost(meta_damage_rank)
	var health_cost: int = _meta_upgrade_cost(meta_health_rank)
	var instinct_cost: int = _meta_upgrade_cost(meta_instinct_rank)
	_set_meta_tree_button("damage_core", "PUISSANCE  %d / 10\n+4,5 %% dégâts / rang\n%s" % [meta_damage_rank, "MAXIMUM" if meta_damage_rank >= 10 else "%d FRAG." % damage_cost], meta_damage_rank < 10 and rift_fragments >= damage_cost, Color("ff9a5c"))
	_set_meta_tree_button("health_core", "COQUE  %d / 10\n+10 PV + onde / rang\n%s" % [meta_health_rank, "MAXIMUM" if meta_health_rank >= 10 else "%d FRAG." % health_cost], meta_health_rank < 10 and rift_fragments >= health_cost, Color("72d7ff"))
	_set_meta_tree_button("instinct_core", "INSTINCT  %d / 10\ncritique + aimant / rang\n%s" % [meta_instinct_rank, "MAXIMUM" if meta_instinct_rank >= 10 else "%d FRAG." % instinct_cost], meta_instinct_rank < 10 and rift_fragments >= instinct_cost, Color("c88cff"))

	var fury_cost: int = _meta_specialization_cost(meta_fury_rank)
	var resilience_cost: int = _meta_specialization_cost(meta_resilience_rank)
	var scavenger_cost: int = _meta_specialization_cost(meta_scavenger_rank)
	var fury_text: String = "FUREUR  %d / 5\ncritique + cadence\n%s" % [meta_fury_rank, "MAXIMUM" if meta_fury_rank >= 5 else ("NÉCESSITE PUISSANCE 3" if meta_damage_rank < 3 else "%d FRAG." % fury_cost)]
	var resilience_text: String = "RÉSILIENCE  %d / 5\narmure + régénération\n%s" % [meta_resilience_rank, "MAXIMUM" if meta_resilience_rank >= 5 else ("NÉCESSITE COQUE 3" if meta_health_rank < 3 else "%d FRAG." % resilience_cost)]
	var scavenger_text: String = "PROSPECTION  %d / 5\nEXP + fragments + vitesse\n%s" % [meta_scavenger_rank, "MAXIMUM" if meta_scavenger_rank >= 5 else ("NÉCESSITE INSTINCT 3" if meta_instinct_rank < 3 else "%d FRAG." % scavenger_cost)]
	_set_meta_tree_button("fury", fury_text, meta_damage_rank >= 3 and meta_fury_rank < 5 and rift_fragments >= fury_cost, Color("ff9a5c"))
	_set_meta_tree_button("resilience", resilience_text, meta_health_rank >= 3 and meta_resilience_rank < 5 and rift_fragments >= resilience_cost, Color("72d7ff"))
	_set_meta_tree_button("scavenger", scavenger_text, meta_instinct_rank >= 3 and meta_scavenger_rank < 5 and rift_fragments >= scavenger_cost, Color("c88cff"))

	var relic_cost: int = _meta_relic_cost()
	var marauder_found: bool = bool(boss_signatures.get("marauder_ember", false))
	var sentinel_found: bool = bool(boss_signatures.get("sentinel_bastion", false))
	var archon_found: bool = bool(boss_signatures.get("archon_conduit", false))
	var marauder_status: String = "ACTIVÉ" if meta_marauder_node else ("RELIQUE MANQUANTE" if not marauder_found else ("FUREUR 3 REQUISE" if meta_fury_rank < 3 else "%d FRAG." % relic_cost))
	var sentinel_status: String = "ACTIVÉ" if meta_sentinel_node else ("RELIQUE MANQUANTE" if not sentinel_found else ("RÉSILIENCE 3 REQUISE" if meta_resilience_rank < 3 else "%d FRAG." % relic_cost))
	var archon_status: String = "ACTIVÉ" if meta_archon_node else ("RELIQUE MANQUANTE" if not archon_found else ("PROSPECTION 3 REQUISE" if meta_scavenger_rank < 3 else "%d FRAG." % relic_cost))
	_set_meta_tree_button("marauder", "BRAISE DU MARAUDEUR\n+8 %% dégâts  •  +14 portée\n%s" % marauder_status, not meta_marauder_node and marauder_found and meta_fury_rank >= 3 and rift_fragments >= relic_cost, Color("ff6a45"))
	_set_meta_tree_button("sentinel", "BASTION SENTINELLE\n+40 PV  •  armure  •  onde\n%s" % sentinel_status, not meta_sentinel_node and sentinel_found and meta_resilience_rank >= 3 and rift_fragments >= relic_cost, Color("67ccff"))
	_set_meta_tree_button("archon", "CONDUIT DE L’ARCHONTE\nonde + dash + aimant\n%s" % archon_status, not meta_archon_node and archon_found and meta_scavenger_rank >= 3 and rift_fragments >= relic_cost, Color("b7ff82"))
	if meta_tree_hint_label != null:
		meta_tree_hint_label.text = "Nœuds de relique : récupère d’abord l’objet signature du boss, puis atteins le rang 3 de sa spécialisation."

func _activate_overdrive() -> void:
	overdrive_meter = 0.0
	overdrive_time = 0.0
	return

func _spawn_rift_fragment(position_value: Vector2, value: int, age_value: float = 0.0) -> void:
	if not is_instance_valid(player):
		return
	var fragment: NomadRiftFragment = RiftFragmentScript.new() as NomadRiftFragment
	fragment.global_position = _safe_pickup_position(position_value, 16.0)
	fragment.player = player
	fragment.value = value
	fragment.age = age_value
	fragment.collected.connect(_on_rift_fragment_collected)
	pickups_root.add_child(fragment)

func _on_rift_fragment_collected(value: int) -> void:
	rift_fragments += value
	run_fragments += value
	_play_sfx(SFX_XP, -11.0, 1.16, 1.24)
	_save_profile()

func _update_zone_banner(delta: float) -> void:
	if zone_mood_overlay != null:
		var target_color: Color = _zone_mood_color(_player_zone())
		if dynamic_event_active:
			target_color = target_color.lerp(Color(0.44, 0.20, 0.58, 0.10), 0.55)
		zone_mood_overlay.color = zone_mood_overlay.color.lerp(target_color, minf(1.0, delta * 2.4))
	if zone_banner_panel == null:
		return
	if zone_banner_timer <= 0.0:
		zone_banner_panel.modulate.a = move_toward(zone_banner_panel.modulate.a, 0.0, delta * 2.8)
		if zone_banner_panel.modulate.a <= 0.01:
			zone_banner_panel.visible = false
		return
	zone_banner_panel.visible = true
	var alpha: float = 1.0
	if zone_banner_timer > 2.4:
		alpha = clampf((3.2 - zone_banner_timer) / 0.8, 0.0, 1.0)
	elif zone_banner_timer < 0.55:
		alpha = clampf(zone_banner_timer / 0.55, 0.0, 1.0)
	zone_banner_panel.modulate.a = move_toward(zone_banner_panel.modulate.a, alpha, delta * 4.5)

func _flash_rift_overlay(custom_color: Color = Color(0.52, 0.20, 0.82, 0.22)) -> void:
	if rift_overlay == null:
		return
	rift_overlay.color = custom_color
	var tween: Tween = create_tween()
	tween.tween_property(rift_overlay, "color:a", 0.0, 0.75)

func _roman(value: int) -> String:
	match value:
		1: return "I"
		2: return "II"
		3: return "III"
		4: return "IV"
		5: return "V"
		_: return "VI"

func _show_toast(text_value: String) -> void:
	toast_label.text = text_value
	toast_label.modulate.a = 1.0
	toast_timer = 2.1

func _show_presentation(title_text: String, subtitle_text: String, color: Color, duration: float = 1.05, major: bool = true) -> void:
	if presentation_overlay == null or presentation_card == null:
		return
	if presentation_tween != null and presentation_tween.is_valid():
		presentation_tween.kill()
	var space: Vector2 = hud.size
	var card_target_y: float = (space.y - presentation_card.size.y) * 0.5
	presentation_title.text = title_text
	presentation_subtitle.text = subtitle_text
	presentation_title.add_theme_color_override("font_color", Color(1.0, 0.96, 0.88))
	presentation_subtitle.add_theme_color_override("font_color", Color(color.r, color.g, color.b, 0.95))
	presentation_accent.color = color
	presentation_card.add_theme_stylebox_override("panel", _style_panel(Color(0.018, 0.026, 0.034, 0.97), Color(color.r, color.g, color.b, 0.78), 18, 10))
	presentation_veil.color = Color(color.r, color.g, color.b, 0.095 if major else 0.035)
	presentation_top_bar.color = Color(0.006, 0.010, 0.014, 0.94 if major else 0.0)
	presentation_bottom_bar.color = Color(0.006, 0.010, 0.014, 0.94 if major else 0.0)
	presentation_top_bar.position = Vector2(0.0, -46.0)
	presentation_bottom_bar.position = Vector2(0.0, space.y)
	presentation_card.position = Vector2((space.x - presentation_card.size.x) * 0.5, card_target_y + 22.0)
	presentation_overlay.modulate.a = 0.0
	presentation_tween = create_tween()
	presentation_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	presentation_tween.tween_property(presentation_overlay, "modulate:a", 1.0, 0.12)
	presentation_tween.parallel().tween_property(presentation_card, "position:y", card_target_y, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if major:
		presentation_tween.parallel().tween_property(presentation_top_bar, "position:y", 0.0, 0.18)
		presentation_tween.parallel().tween_property(presentation_bottom_bar, "position:y", space.y - 46.0, 0.18)
	presentation_tween.tween_interval(duration)
	presentation_tween.tween_property(presentation_overlay, "modulate:a", 0.0, 0.28)
	if major:
		presentation_tween.parallel().tween_property(presentation_top_bar, "position:y", -46.0, 0.28)
		presentation_tween.parallel().tween_property(presentation_bottom_bar, "position:y", space.y, 0.28)

func _show_loot_banner(module_id: String, rarity: String) -> void:
	if loot_banner_panel == null:
		return
	if loot_banner_tween != null and loot_banner_tween.is_valid():
		loot_banner_tween.kill()
	var color: Color = _loot_rarity_color(rarity)
	loot_banner_rarity.text = _loot_rarity_label(rarity)
	loot_banner_rarity.add_theme_color_override("font_color", color)
	loot_banner_name.text = _module_name(module_id)
	loot_banner_name.add_theme_color_override("font_color", Color(1.0, 0.96, 0.88))
	loot_banner_hint.text = "RELIQUE AJOUTÉE À LA MATRICE" if rarity == "signature" else "MODULE INTÉGRÉ AU BUILD"
	loot_banner_panel.add_theme_stylebox_override("panel", _style_panel(Color(0.018, 0.027, 0.034, 0.97), Color(color.r, color.g, color.b, 0.82), 15, 9))
	var target_pos: Vector2 = Vector2((hud.size.x - loot_banner_panel.size.x) * 0.5, maxf(230.0, hud.size.y - 118.0))
	loot_banner_panel.position = target_pos + Vector2(0.0, 28.0)
	loot_banner_panel.modulate.a = 0.0
	loot_banner_tween = create_tween()
	loot_banner_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	loot_banner_tween.tween_property(loot_banner_panel, "modulate:a", 1.0, 0.13)
	loot_banner_tween.parallel().tween_property(loot_banner_panel, "position", target_pos, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	loot_banner_tween.tween_interval(1.25 if rarity in ["common", "rare"] else 1.70)
	loot_banner_tween.tween_property(loot_banner_panel, "modulate:a", 0.0, 0.24)

func _spawn_world_pulse_fx(position_value: Vector2, color: Color, end_scale: float, duration: float, start_scale: float = 0.16) -> void:
	_trim_fx_budget()
	var fx: Sprite2D = Sprite2D.new()
	fx.texture = PULSE_TEXTURE
	fx.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	fx.global_position = position_value
	fx.scale = Vector2.ONE * start_scale
	fx.modulate = color
	fx.z_index = 3505
	fx_root.add_child(fx)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(fx, "scale", Vector2.ONE * end_scale, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(fx, "modulate:a", 0.0, duration)
	tween.finished.connect(fx.queue_free)

func _spawn_boss_death_sequence(position_value: Vector2, boss_kind: String) -> void:
	var color: Color = _boss_color(boss_kind)
	for i: int in range(3):
		_spawn_world_pulse_fx(position_value, Color(color.r, color.g, color.b, 0.86 - float(i) * 0.18), 1.15 + float(i) * 0.55, 0.34 + float(i) * 0.10, 0.12 + float(i) * 0.05)
	for ray_index: int in range(8):
		_trim_fx_budget()
		var ray: Line2D = Line2D.new()
		var angle: float = TAU * float(ray_index) / 8.0 + rng.randf_range(-0.10, 0.10)
		var direction: Vector2 = Vector2.RIGHT.rotated(angle)
		ray.width = rng.randf_range(3.0, 5.2)
		ray.default_color = Color(color.r, color.g, color.b, 0.92)
		ray.add_point(direction * 22.0)
		ray.add_point(direction * rng.randf_range(105.0, 180.0))
		ray.global_position = position_value
		ray.z_index = 3690
		fx_root.add_child(ray)
		var ray_tween: Tween = create_tween()
		ray_tween.set_parallel(true)
		ray_tween.tween_property(ray, "scale", Vector2.ONE * 1.35, 0.28)
		ray_tween.tween_property(ray, "modulate:a", 0.0, 0.34)
		ray_tween.finished.connect(ray.queue_free)
	_flash_rift_overlay(Color(1.0, 0.98, 0.90, 0.22))

func _toggle_pause() -> void:
	if state == State.PLAYING:
		_save_profile()
		state = State.PAUSED
		joystick.reset()
		joystick.enabled = false
		world_entities.process_mode = Node.PROCESS_MODE_DISABLED
		pause_panel.visible = true
		get_tree().paused = true
	elif state == State.PAUSED:
		if rotation_blocked:
			return
		get_tree().paused = false
		world_entities.process_mode = Node.PROCESS_MODE_PAUSABLE
		state = State.PLAYING
		pause_panel.visible = false
		joystick.enabled = true

func _restart_from_pause() -> void:
	get_tree().paused = false
	_start_run()

func _menu_from_pause() -> void:
	get_tree().paused = false
	_show_menu()

func _on_player_died() -> void:
	get_tree().paused = false
	_clear_boss_hazards()
	if is_instance_valid(player):
		player.set_selection_lock(false)
	upgrade_pending = false
	if upgrade_panel != null:
		upgrade_panel.visible = false
	state = State.GAME_OVER
	joystick.enabled = false
	joystick.reset()
	hud.visible = false
	pause_panel.visible = false
	game_over.visible = true
	world_entities.process_mode = Node.PROCESS_MODE_DISABLED
	best_kills = maxi(best_kills, kills)
	best_level = maxi(best_level, level)
	best_time = maxf(best_time, run_time)
	saved_run.clear()
	_save_profile()
	var minutes: int = floori(run_time / 60.0)
	var seconds: int = int(run_time) % 60
	game_over_stats.text = "NIVEAU %d   •   %d KO   •   %d ÉLITES\nSURVIE %02d:%02d   •   +%d FRAGMENTS\n\nRECORD  %d KO   •   NIV. %d" % [level, kills, elites_killed, minutes, seconds, run_fragments, best_kills, best_level]
	_shake(8.0, 0.24)

func _cancel_pending_backup() -> void:
	pending_backup_text = ""
	web_backup_waiting = false
	if backup_status_label != null:
		backup_status_label.text = "Sauvegarde locale : export et restauration"
		backup_status_label.add_theme_color_override("font_color", Color("a5b6ba"))
	if backup_import_button != null:
		backup_import_button.text = "IMPORTER"
		backup_import_button.add_theme_font_size_override("font_size", 20 if menu_compact else 15)

func _backup_message(message: String, is_error: bool = false) -> void:
	if backup_status_label != null:
		backup_status_label.text = message
		backup_status_label.add_theme_color_override("font_color", Color("ffb0a7") if is_error else Color("a5eac1"))

func _backup_data() -> PackedByteArray:
	_save_profile()
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return PackedByteArray()
	if file.get_length() > BACKUP_MAX_BYTES:
		return PackedByteArray()
	return file.get_buffer(file.get_length())

func _ensure_backup_file_dialog() -> void:
	if backup_file_dialog != null:
		return
	backup_file_dialog = FileDialog.new()
	backup_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	backup_file_dialog.filters = PackedStringArray(["*.cfg ; Sauvegarde NØMAD ZERO"])
	backup_file_dialog.file_selected.connect(_on_backup_file_selected)
	add_child(backup_file_dialog)

func _export_backup_pressed() -> void:
	_cancel_pending_backup()
	var data: PackedByteArray = _backup_data()
	if data.is_empty():
		_backup_message("Impossible de préparer la sauvegarde", true)
		return
	if OS.has_feature("web"):
		JavaScriptBridge.download_buffer(data, "NOMAD_ZERO_sauvegarde.cfg", "text/plain")
		_backup_message("Sauvegarde proposée au téléchargement")
		return
	_ensure_backup_file_dialog()
	backup_dialog_mode = "export"
	backup_file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	backup_file_dialog.current_file = "NOMAD_ZERO_sauvegarde.cfg"
	backup_file_dialog.popup_centered(Vector2i(720, 480))

func _import_backup_pressed() -> void:
	if not pending_backup_text.is_empty():
		_confirm_backup_import()
		return
	if OS.has_feature("web"):
		web_backup_waiting = true
		web_backup_poll_timer = 0.25
		JavaScriptBridge.eval(WEB_BACKUP_PICKER_JS)
		_backup_message("Choisis un fichier de sauvegarde")
		return
	_ensure_backup_file_dialog()
	backup_dialog_mode = "import"
	backup_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	backup_file_dialog.popup_centered(Vector2i(720, 480))

func _poll_web_backup() -> void:
	var status: String = String(JavaScriptBridge.eval("window.__nomadBackupStatus || ''"))
	if status.is_empty():
		return
	web_backup_waiting = false
	if status == "ready":
		var payload: String = String(JavaScriptBridge.eval("window.__nomadBackupPayload || ''"))
		JavaScriptBridge.eval("window.__nomadBackupPayload = ''; window.__nomadBackupStatus = '';")
		_prepare_backup_import(payload)
	elif status == "large":
		_backup_message("Fichier trop volumineux (max. 4 Mo)", true)
	else:
		_backup_message("Impossible de lire ce fichier", true)

func _on_backup_file_selected(path: String) -> void:
	if backup_dialog_mode == "export":
		var data: PackedByteArray = _backup_data()
		var output: FileAccess = FileAccess.open(path, FileAccess.WRITE)
		if output == null or data.is_empty():
			_backup_message("Export impossible", true)
			return
		output.store_buffer(data)
		_backup_message("Sauvegarde exportée")
	elif backup_dialog_mode == "import":
		var file: FileAccess = FileAccess.open(path, FileAccess.READ)
		if file == null or file.get_length() > BACKUP_MAX_BYTES:
			_backup_message("Fichier absent ou trop volumineux", true)
			return
		_prepare_backup_import(file.get_as_text())

func _backup_config_is_valid(config: ConfigFile) -> bool:
	var version: Variant = config.get_value("meta", "save_version", -1)
	if typeof(version) != TYPE_INT or int(version) < 4 or int(version) > SAVE_VERSION:
		return false
	for field: String in ["kills", "level"]:
		if not config.has_section_key("records", field) or typeof(config.get_value("records", field)) != TYPE_INT:
			return false
	if not config.has_section_key("records", "time") or typeof(config.get_value("records", "time")) != TYPE_FLOAT:
		return false
	if not config.has_section_key("profile", "rift_fragments") or typeof(config.get_value("profile", "rift_fragments")) != TYPE_INT:
		return false
	for field: String in ["meta_damage_rank", "meta_health_rank", "meta_instinct_rank"]:
		if not config.has_section_key("profile", field) or typeof(config.get_value("profile", field)) != TYPE_INT:
			return false
	for field: String in ["meta_fury_rank", "meta_resilience_rank", "meta_scavenger_rank"]:
		if config.has_section_key("profile", field) and typeof(config.get_value("profile", field)) != TYPE_INT:
			return false
	for field: String in ["meta_marauder_node", "meta_sentinel_node", "meta_archon_node"]:
		if config.has_section_key("profile", field) and typeof(config.get_value("profile", field)) != TYPE_BOOL:
			return false
	for archive_key: String in ["boss_encounters", "boss_defeats"]:
		if config.has_section_key("profile", archive_key):
			var counts: Variant = config.get_value("profile", archive_key)
			if not counts is Dictionary:
				return false
			for boss_kind: Variant in counts.keys():
				if boss_kind not in BOSS_KINDS or typeof(counts[boss_kind]) != TYPE_INT or int(counts[boss_kind]) < 0 or int(counts[boss_kind]) > 1000000:
					return false
	for loot_key: String in ["loot_discovered", "boss_signatures", "canyon_secrets"]:
		if config.has_section_key("profile", loot_key):
			var loot_archive: Variant = config.get_value("profile", loot_key)
			if not loot_archive is Dictionary:
				return false
	if config.has_section_key("profile", "canyon_mastery") and typeof(config.get_value("profile", "canyon_mastery")) != TYPE_BOOL:
		return false
	if config.has_section_key("run", "checkpoint"):
		var checkpoint: Variant = config.get_value("run", "checkpoint")
		if not _is_valid_saved_run(checkpoint):
			return false
		for field: String in RUN_SAVE_PROPERTIES:
			# V44.36 ajoute run_modules/run_module_count ; les backups V44.35 restent importables.
			# V44.38 ajoute l'état optionnel des événements de monde ; les backups V44.37 (save v8) restent importables.
			if not checkpoint.has(field):
				if int(version) < 7 and field in ["run_modules", "run_module_count"]:
					continue
				if int(version) < 9 and field in ["dynamic_event_active", "dynamic_event_kind", "dynamic_event_position", "dynamic_event_started", "dynamic_event_progress", "dynamic_event_target", "dynamic_event_spawn_timer", "dynamic_event_age", "dynamic_event_serial", "dynamic_event_kills", "dynamic_event_target_kills"]:
					continue
				# V44.42 garde save v9 : ces deux champs restent optionnels pour importer un backup V44.41.
				if field in ["skill_traction_cooldown_timer", "skill_surge_timer", "skill_surge_cooldown_timer"]:
					continue
				return false
			if typeof(checkpoint.get(field)) != typeof(get(field)):
				return false
		var player_data: Dictionary = checkpoint["player"]
		for field: String in PLAYER_SAVE_PROPERTIES:
			var expected: int = TYPE_INT if field == "multishot_count" else TYPE_FLOAT
			if typeof(player_data.get(field)) != expected:
				return false
		if not StylizedWorld.BOUNDS.has_point(player_data["position"]):
			return false
		if float(player_data["max_health"]) < float(player_data["health"]):
			return false
		var enemies: Variant = checkpoint.get("enemies", [])
		var pickups: Variant = checkpoint.get("pickups", [])
		if not enemies is Array or enemies.size() > MAX_ACTIVE_ENEMIES + 3 or not pickups is Array or pickups.size() > 4096:
			return false
		for enemy: Variant in enemies:
			if not enemy is Dictionary or typeof(enemy.get("position")) != TYPE_VECTOR2 or typeof(enemy.get("kind")) != TYPE_STRING:
				return false
			if String(enemy["kind"]) not in ["blaster", "raider", "stalker", "sniper", "suppressor", "breaker", "heavy", "phantom", "colossus", "sentinel", "marauder", "archon", "warden", "reaper"]:
				return false
			if typeof(enemy.get("elite")) != TYPE_BOOL or typeof(enemy.get("affix")) != TYPE_STRING:
				return false
			for field: String in ENEMY_SAVE_PROPERTIES:
				var expected: int = TYPE_INT if field == "xp_value" else TYPE_FLOAT
				if typeof(enemy.get(field)) != expected:
					return false
		for pickup: Variant in pickups:
			if not pickup is Dictionary or typeof(pickup.get("position")) != TYPE_VECTOR2 or typeof(pickup.get("kind")) != TYPE_STRING:
				return false
			var pickup_kind: String = String(pickup["kind"])
			if pickup_kind not in ["xp", "fragment", "supply", "loot", "loot_cache"]:
				return false
			if typeof(pickup.get("age")) != TYPE_FLOAT:
				return false
			match pickup_kind:
				"supply":
					if typeof(pickup.get("supply_kind")) != TYPE_STRING:
						return false
				"loot":
					if typeof(pickup.get("module_id")) != TYPE_STRING or typeof(pickup.get("rarity")) != TYPE_STRING:
						return false
				"loot_cache":
					if typeof(pickup.get("cache_rank")) != TYPE_INT or typeof(pickup.get("zone_hint")) != TYPE_STRING or typeof(pickup.get("hold_time")) != TYPE_FLOAT:
						return false
				_:
					if typeof(pickup.get("value")) != TYPE_INT:
						return false
		var choices: Variant = checkpoint.get("upgrade_options", [])
		if not choices is Array or choices.size() > 3:
			return false
		for option: Variant in choices:
			if not option is Dictionary or typeof(option.get("id")) != TYPE_STRING or typeof(option.get("rarity")) != TYPE_STRING:
				return false
			if typeof(option.get("multiplier")) != TYPE_FLOAT or typeof(option.get("title")) != TYPE_STRING or typeof(option.get("description")) != TYPE_STRING:
				return false
			if String(option["id"]) not in ["damage", "cadence", "range", "chain", "critical", "crit_power", "speed", "hull", "shield", "regen", "armor", "magnet", "siphon", "fortune", "repair", "salvage", "charge"]:
				return false
	return true

func _prepare_backup_import(text_data: String) -> void:
	_cancel_pending_backup()
	if text_data.to_utf8_buffer().size() > BACKUP_MAX_BYTES:
		_backup_message("Fichier trop volumineux (max. 4 Mo)", true)
		return
	var backup: ConfigFile = ConfigFile.new()
	if backup.parse(text_data) != OK or not _backup_config_is_valid(backup):
		_backup_message("Sauvegarde invalide ou incompatible", true)
		return
	pending_backup_text = backup.encode_to_text()
	backup_import_button.text = "CONFIRMER IMPORT"
	backup_import_button.add_theme_font_size_override("font_size", 16 if menu_compact else 12)
	_backup_message("Confirmer : remplace le profil actuel")

func _confirm_backup_import() -> void:
	if state != State.MENU:
		return
	var backup: ConfigFile = ConfigFile.new()
	if backup.parse(pending_backup_text) != OK or not _backup_config_is_valid(backup):
		_cancel_pending_backup()
		_backup_message("Sauvegarde invalide", true)
		return
	var result: Error = _write_profile_config_safely(backup)
	_cancel_pending_backup()
	if result != OK:
		_backup_message("Impossible d'écrire la sauvegarde", true)
		return
	best_kills = 0
	best_level = 1
	best_time = 0.0
	rift_fragments = 0
	meta_damage_rank = 0
	meta_health_rank = 0
	meta_instinct_rank = 0
	meta_fury_rank = 0
	meta_resilience_rank = 0
	meta_scavenger_rank = 0
	meta_marauder_node = false
	meta_sentinel_node = false
	meta_archon_node = false
	boss_encounters.clear()
	boss_defeats.clear()
	loot_discovered.clear()
	boss_signatures.clear()
	canyon_secrets.clear()
	canyon_mastery = false
	saved_run.clear()
	_load_profile()
	_update_menu_stats()
	_backup_message("Sauvegarde restaurée")

func _load_profile() -> void:
	var config: ConfigFile = ConfigFile.new()
	var load_error: Error = config.load(SAVE_PATH)
	if load_error != OK or not _backup_config_is_valid(config):
		config = ConfigFile.new()
		var backup_error: Error = config.load(SAVE_BACKUP_PATH)
		if backup_error != OK or not _backup_config_is_valid(config):
			config = ConfigFile.new()
			if config.load(LEGACY_SAVE_PATH) != OK:
				return
	best_kills = maxi(0, int(config.get_value("records", "kills", 0)))
	best_level = maxi(1, int(config.get_value("records", "level", 1)))
	best_time = maxf(0.0, float(config.get_value("records", "time", 0.0)))
	rift_fragments = maxi(0, int(config.get_value("profile", "rift_fragments", 0)))
	meta_damage_rank = clampi(int(config.get_value("profile", "meta_damage_rank", 0)), 0, 10)
	meta_health_rank = clampi(int(config.get_value("profile", "meta_health_rank", 0)), 0, 10)
	# Migration V38 -> V39: l'ancien nom interne "drone" correspondait déjà à INSTINCT.
	var legacy_instinct: int = int(config.get_value("profile", "meta_drone_rank", 0))
	meta_instinct_rank = clampi(int(config.get_value("profile", "meta_instinct_rank", legacy_instinct)), 0, 10)
	meta_fury_rank = clampi(int(config.get_value("profile", "meta_fury_rank", 0)), 0, 5)
	meta_resilience_rank = clampi(int(config.get_value("profile", "meta_resilience_rank", 0)), 0, 5)
	meta_scavenger_rank = clampi(int(config.get_value("profile", "meta_scavenger_rank", 0)), 0, 5)
	meta_marauder_node = bool(config.get_value("profile", "meta_marauder_node", false))
	meta_sentinel_node = bool(config.get_value("profile", "meta_sentinel_node", false))
	meta_archon_node = bool(config.get_value("profile", "meta_archon_node", false))
	boss_encounters.clear()
	boss_defeats.clear()
	for boss_kind: String in BOSS_KINDS:
		var seen_data: Variant = config.get_value("profile", "boss_encounters", {})
		var defeat_data: Variant = config.get_value("profile", "boss_defeats", {})
		if seen_data is Dictionary and typeof(seen_data.get(boss_kind, 0)) == TYPE_INT:
			boss_encounters[boss_kind] = clampi(int(seen_data[boss_kind]) if seen_data.has(boss_kind) else 0, 0, 1000000)
		if defeat_data is Dictionary and typeof(defeat_data.get(boss_kind, 0)) == TYPE_INT:
			boss_defeats[boss_kind] = clampi(int(defeat_data[boss_kind]) if defeat_data.has(boss_kind) else 0, 0, 1000000)
	var discovered_data: Variant = config.get_value("profile", "loot_discovered", {})
	loot_discovered = discovered_data.duplicate(true) if discovered_data is Dictionary else {}
	var signature_data: Variant = config.get_value("profile", "boss_signatures", {})
	boss_signatures = signature_data.duplicate(true) if signature_data is Dictionary else {}
	var canyon_secret_data: Variant = config.get_value("profile", "canyon_secrets", {})
	canyon_secrets = canyon_secret_data.duplicate(true) if canyon_secret_data is Dictionary else {}
	canyon_mastery = bool(config.get_value("profile", "canyon_mastery", false))
	var checkpoint: Variant = config.get_value("run", "checkpoint", {})
	if _is_valid_saved_run(checkpoint):
		saved_run = checkpoint

func _save_profile() -> void:
	# Les records sont instantanément consolidés pendant une partie afin qu'une
	# fermeture d'application ne fasse pas perdre un nouveau meilleur score.
	if state == State.PLAYING or state == State.PAUSED:
		best_kills = maxi(best_kills, kills)
		best_level = maxi(best_level, level)
		best_time = maxf(best_time, run_time)
		if is_instance_valid(player) and player.active and player.health > 0.0:
			saved_run = _capture_run()
	var config: ConfigFile = ConfigFile.new()
	config.set_value("meta", "save_version", SAVE_VERSION)
	config.set_value("meta", "app_version", APP_VERSION)
	config.set_value("meta", "release_channel", "stable")
	config.set_value("meta", "last_build", BUILD_NAME)
	config.set_value("records", "kills", maxi(0, best_kills))
	config.set_value("records", "level", maxi(1, best_level))
	config.set_value("records", "time", maxf(0.0, best_time))
	config.set_value("profile", "rift_fragments", maxi(0, rift_fragments))
	config.set_value("profile", "meta_damage_rank", clampi(meta_damage_rank, 0, 10))
	config.set_value("profile", "meta_health_rank", clampi(meta_health_rank, 0, 10))
	config.set_value("profile", "meta_instinct_rank", clampi(meta_instinct_rank, 0, 10))
	config.set_value("profile", "meta_fury_rank", clampi(meta_fury_rank, 0, 5))
	config.set_value("profile", "meta_resilience_rank", clampi(meta_resilience_rank, 0, 5))
	config.set_value("profile", "meta_scavenger_rank", clampi(meta_scavenger_rank, 0, 5))
	config.set_value("profile", "meta_marauder_node", meta_marauder_node)
	config.set_value("profile", "meta_sentinel_node", meta_sentinel_node)
	config.set_value("profile", "meta_archon_node", meta_archon_node)
	config.set_value("profile", "boss_encounters", boss_encounters.duplicate(true))
	config.set_value("profile", "boss_defeats", boss_defeats.duplicate(true))
	config.set_value("profile", "loot_discovered", loot_discovered.duplicate(true))
	config.set_value("profile", "boss_signatures", boss_signatures.duplicate(true))
	config.set_value("profile", "canyon_secrets", canyon_secrets.duplicate(true))
	config.set_value("profile", "canyon_mastery", canyon_mastery)
	# Alias conservé pour pouvoir rouvrir la sauvegarde avec une ancienne build sans perdre INSTINCT.
	config.set_value("profile", "meta_drone_rank", clampi(meta_instinct_rank, 0, 10))
	if _is_valid_saved_run(saved_run):
		config.set_value("run", "checkpoint", saved_run)
	var save_error: Error = _write_profile_config_safely(config)
	if save_error != OK:
		push_warning("Impossible d'enregistrer le profil NØMAD ZERO : %s" % error_string(save_error))

func _update_menu_stats() -> void:
	if menu_best_label == null:
		return
	var minutes: int = floori(best_time / 60.0)
	var seconds: int = int(best_time) % 60
	menu_best_label.text = "%d KO   •   NIV. %d   •   %02d:%02d" % [best_kills, best_level, minutes, seconds]
	if menu_fragment_label != null:
		menu_fragment_label.text = str(rift_fragments)
	var can_resume: bool = _is_valid_saved_run(saved_run)
	if resume_button != null and new_run_button != null:
		resume_button.visible = can_resume
		resume_button.position = Vector2(26.0, 340.0)
		resume_button.size = Vector2(668.0, 72.0)
		new_run_button.position = Vector2(26.0, 430.0) if can_resume else Vector2(26.0, 356.0)
		new_run_button.size = Vector2(668.0, 82.0) if can_resume else Vector2(668.0, 126.0)
		new_run_button.text = "NOUVELLE EXPÉDITION" if can_resume else "JOUER"
		new_run_button.add_theme_font_size_override("font_size", 18 if can_resume else 36)
		if can_resume:
			resume_button.text = "CONTINUER  •  VAGUE %d  •  NIV. %d" % [int(saved_run["wave_number"]), int(saved_run["level"])]
	if menu_run_hint != null:
		menu_run_hint.position.y = 532.0 if can_resume else 508.0
		menu_run_hint.text = "Nouvelle expédition : remplace la partie sauvegardée" if can_resume else "Nouvelle expédition"
	_update_meta_buttons()
