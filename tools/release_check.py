from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]

main = (ROOT / "scripts" / "main.gd").read_text(encoding="utf-8")
project = (ROOT / "project.godot").read_text(encoding="utf-8")
loader = (ROOT / "web" / "loading_theme.html").read_text(encoding="utf-8")
export = (ROOT / "export_presets.cfg").read_text(encoding="utf-8")
enemy = (ROOT / "scripts" / "enemy.gd").read_text(encoding="utf-8")
player = (ROOT / "scripts" / "player.gd").read_text(encoding="utf-8")
world = (ROOT / "scripts" / "world.gd").read_text(encoding="utf-8")
joystick = (ROOT / "scripts" / "virtual_joystick.gd").read_text(encoding="utf-8")
version_file = (ROOT / "VERSION.txt").read_text(encoding="utf-8").strip()

app_match = re.search(r'const APP_VERSION: String = "([^"]+)"', main)
build_match = re.search(r'const BUILD_NAME: String = "([^"]+)"', main)
project_match = re.search(r'config/version="([^"]+)"', project)
loader_match = re.search(r"marker\.textContent = 'V([^ ]+) // ([^']+)';", loader)

app_version = app_match.group(1) if app_match else ""
build_name = build_match.group(1) if build_match else ""
project_version = project_match.group(1) if project_match else ""
loader_version = loader_match.group(1) if loader_match else ""

release_key = "_".join(app_version.split(".")[:2]) if app_version else ""
release_notes = ROOT / f"RELEASE_NOTES_V{release_key}.md"

checks = {
    "APP_VERSION present": bool(app_version),
    "BUILD_NAME present": bool(build_name),
    "project version matches APP_VERSION": project_version == app_version,
    "VERSION.txt matches APP_VERSION": version_file == app_version,
    "build label carries current release": build_name.startswith("V" + ".".join(app_version.split(".")[:2])) if app_version else False,
    "loader marker carries current release": loader_version == ".".join(app_version.split(".")[:2]) if app_version else False,
    "embedded export loader carries current release": f"V{'.'.join(app_version.split('.')[:2])} // " in export if app_version else False,
    "release notes present": release_notes.exists(),
    "pickup QoL helper": "_count_nearby_supplies" in main and "_request_emergency_support" in main,
    "enemy registry centralized": "const ALL_ENEMY_KINDS" in main and main.count("ALL_ENEMY_KINDS") >= 3,
    "combat identities present": all(token in enemy for token in ["raider_hook", "blaster_double", "heavy_slam", "_neighbor_separation"]),
    "ranged line-of-sight AI present": all(token in enemy for token in ["_has_clear_shot", "_line_reposition_direction", "_los_check_timer"]),
    "priority threat indicator present": all(token in main for token in ["_telegraph_priority", "_telegraph_color", "selected_score"]),
    "guided upgrade choices present": all(token in main for token in ["_upgrade_weight", "_weighted_upgrade_pick", "nomad_flow", "rift_conductor", "iron_will"]),
    "combat role director present": all(token in main for token in ["_active_ranged_enemy_count", "_zone_melee_fallback", "_zone_ranged_fallback"]),
    "full world-event variety active": all(token in main for token in ['pool.append("ambush")', 'pool.append("corruption")', '"corruption":', '"ambush":']),
    "end-of-run build summary present": "run_synergies.size()" in main and "run_module_count" in main and "best_minutes" in main,
    "V50 production map active": 'desert_world_v50.webp' in world and 'const MAP_SCALE: float = 4.0' in world and 'V50WorldMap' in world and (ROOT / "assets" / "map" / "desert_world_v50.webp").exists(),
    "legacy decor overlay removed": "_create_decor_sprites()" not in world and "CAMP_TEXTURE" not in world and "REFINERY_TEXTURE" not in world,
    "V50 collision layout active": all(token in world for token in ["Vector2(585.0, 425.0)", "Vector2(2425.0, 455.0)", "Vector2(2150.0, 2640.0)", "Vector2(3140.0, 2510.0)"]),
    "floating joystick follow present": "follow_threshold" in joystick and "follow_distance" in joystick,
    "removed active skills stay removed": all(token not in main for token in ["func _use_dash()", "func _use_surge()", "func _use_traction()", "SURCHARGE  •", "onde + dash"]),
    "no live dash trigger": "trigger_dash(" not in main and "trigger_dash(" not in player and 'is_action_just_pressed("dash")' not in main,
    "dash visual runtime removed": "hero_dash" not in player and "dash_used" not in player,
    "active shield vocabulary removed": "BOUCLIER" not in main and "restore_shield" not in main and "restore_shield" not in player,
    "orphan dash art removed": not any((ROOT / "assets" / "hero" / name).exists() for name in ["hero_dash.png", "hero_dash_b.png", "hero_dash_c.png"]),
    "graveyard map orphan removed": not (ROOT / "assets" / "map" / "desert_world_v48_0.png").exists(),
}

failed = [name for name, ok in checks.items() if not ok]
if failed:
    print("ERROR: release checks failed:")
    for item in failed:
        print("  -", item)
    print(f"Detected APP_VERSION={app_version!r}, BUILD_NAME={build_name!r}, project={project_version!r}, VERSION.txt={version_file!r}")
    sys.exit(1)

print(f"OK: V{'.'.join(app_version.split('.')[:2])} static release checks passed.")
