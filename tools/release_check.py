#!/usr/bin/env python3
from __future__ import annotations
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
problems: list[str] = []

main = (ROOT / 'scripts' / 'main.gd').read_text(encoding='utf-8')
world = (ROOT / 'scripts' / 'world.gd').read_text(encoding='utf-8')
project = (ROOT / 'project.godot').read_text(encoding='utf-8')
export = (ROOT / 'export_presets.cfg').read_text(encoding='utf-8')

checks = {
    'main build marker': 'const BUILD_NAME: String = "V48.1 • MACHINES DU CIMETIÈRE"' in main,
    'app semantic version': 'const APP_VERSION: String = "48.1.0"' in main,
    'save format unchanged': 'const SAVE_VERSION: int = 9' in main,
    'safe save writer': 'func _write_profile_config_safely(config: ConfigFile) -> Error:' in main,
    'temporary save path': 'nomad_zero_profile.tmp.cfg' in main,
    'project version': 'config/version="48.1.0"' in project,
    'PWA enabled': 'progressive_web_app/enabled=true' in export,
    'landscape PWA': 'progressive_web_app/orientation=1' in export,
    'V48.1 loader marker': "marker.textContent = 'V48.1 // MACHINES DU CIMETIÈRE';" in export,
    'V48.0 expanded world map retained': 'res://assets/map/desert_world_v48_0.png' in world and '4096.0, 3072.0' in world,
    'Canyon combat retained': 'echo_scout' in main and 'veil_tech' in main and 'veil_guardian' in main,
    'Resonator retained': 'resonator' in main and 'echo_relic' in main,
    'Canyon secrets retained': 'CanyonSecretScript' in main and 'canyon_secrets' in main and '_spawn_canyon_secrets' in main,
    'Canyon secret script retained': (ROOT / 'scripts' / 'canyon_secret.gd').exists(),
    'V48 graveyard zone retained': 'CIMETIÈRE D’ÉPAVES' in main and 'CIMETIÈRE D’ÉPAVES' in world and 'budget -= 0.40' in main,
    'V48 graveyard decor retained': all((ROOT / 'assets' / 'decor' / x).exists() for x in ['v48_leviathan.png','v48_salvage_rig.png','v48_scrap_heap.png','v48_iron_pit.png']),
    'V48.1 mechanical enemies': all(x in main for x in ['salvage_drone','scrap_automaton','mobile_turret','leviathan_grinder']),
    'V48.1 scrap titan': 'scrap_titan' in main and 'titan_salvage_core' in main,
    'V48.1 mechanical enemy code': all(x in (ROOT / 'scripts' / 'enemy.gd').read_text(encoding='utf-8') for x in ['salvage_drone','scrap_automaton','mobile_turret','leviathan_grinder','scrap_titan']),
    'V48.1 mechanical assets': all((ROOT / x).exists() for x in [
        'assets/enemies/salvage_drone_idle.png','assets/enemies/scrap_automaton_idle.png',
        'assets/enemies/mobile_turret_idle.png','assets/enemies/leviathan_grinder_idle.png',
        'assets/bosses/scrap_titan_idle.png']),
    'landmark contact shadows': 'func _add_landmark_shadow(' in world,
    'iPhone safe area logic': 'SAFE_AREA_JS' in main and '_browser_safe_insets' in main,
}
for name, ok in checks.items():
    if not ok:
        problems.append(f'missing/invalid: {name}')

for path in sorted((ROOT / 'scripts').glob('*.gd')):
    text = path.read_text(encoding='utf-8')
    funcs = re.findall(r'^func\s+([A-Za-z0-9_]+)\s*\(', text, flags=re.M)
    seen: set[str] = set()
    dupes: set[str] = set()
    for fn in funcs:
        if fn in seen:
            dupes.add(fn)
        seen.add(fn)
    if dupes:
        problems.append(f'{path.name}: duplicate functions: {", ".join(sorted(dupes))}')
    if any(marker in text for marker in ('<<<<<<<', '=======', '>>>>>>>')):
        problems.append(f'{path.name}: merge conflict marker present')
    for line_no, line in enumerate(text.splitlines(), 1):
        if re.match(r'^\s+func\s+', line):
            problems.append(f'{path.name}:{line_no}: nested/indented func declaration')

retired_markers = [
    'func _update_wreck_mission(', 'func _update_refinery_mission(', 'func _update_outpost_defense(',
    'func _start_contract(', 'func _update_contract(', 'contract_label', 'wreck_mission_active',
    'refinery_mission_active', 'outpost_beacon_progress'
]
for marker in retired_markers:
    if marker in main:
        problems.append(f'retired code still present: {marker}')

text_exts = {'.gd', '.tscn', '.tres', '.cfg', '.godot', '.html'}
resource_re = re.compile(r'res://([^"\'`\)\]\s]+)')
refs: set[str] = set()
for path in ROOT.rglob('*'):
    if not path.is_file() or 'build' in path.parts or '.git' in path.parts:
        continue
    if path.suffix.lower() not in text_exts and path.name not in {'project.godot', 'export_presets.cfg'}:
        continue
    try:
        content = path.read_text(encoding='utf-8')
    except UnicodeDecodeError:
        continue
    refs.update(x.rstrip('.,;:') for x in resource_re.findall(content))
for path in (ROOT / 'assets').rglob('*'):
    if not path.is_file() or path.suffix == '.import':
        continue
    rel = path.relative_to(ROOT).as_posix()
    if rel not in refs:
        problems.append(f'orphan asset: {rel}')

assets_bytes = sum(p.stat().st_size for p in (ROOT / 'assets').rglob('*') if p.is_file())
if assets_bytes > 18 * 1024 * 1024:
    problems.append(f'assets exceed 14 MiB ({assets_bytes / 1024 / 1024:.1f} MiB)')

for name in ['README.md', 'RELEASE_NOTES_V48_1.md', 'GRAVEYARD_MAP_AUDIT.md', 'VERSION.txt']:
    if not (ROOT / name).exists():
        problems.append(f'missing release file: {name}')

obsolete_files = [
    'RELEASE_NOTES_V46_3.md', 'RELEASE_NOTES_V46_4.md', 'RELEASE_NOTES_V46_5.md', 'PATH_NETWORK_V46_3.md'
]
for name in obsolete_files:
    if (ROOT / name).exists():
        problems.append(f'obsolete intermediate file still present: {name}')
if (ROOT / 'tools' / '__pycache__').exists():
    problems.append('generated tools/__pycache__ should not ship')

if problems:
    print('ERROR: V48.1 release checks failed:')
    for item in problems:
        print('  -', item)
    sys.exit(1)

print('OK: V48.1 static release checks passed.')
print(f'Assets: {assets_bytes / 1024 / 1024:.1f} MiB')
print(f'Referenced source assets: {len([x for x in refs if x.startswith("assets/")])}')
