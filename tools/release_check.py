from pathlib import Path
import sys
ROOT = Path(__file__).resolve().parents[1]
main = (ROOT / 'scripts' / 'main.gd').read_text(encoding='utf-8')
project = (ROOT / 'project.godot').read_text(encoding='utf-8')
export = (ROOT / 'web' / 'loading_theme.html').read_text(encoding='utf-8')
checks = {
    'build marker': 'const BUILD_NAME: String = "V49.0 • OVERHAUL GLOBAL"' in main,
    'semantic version': 'const APP_VERSION: String = "49.0.0"' in main,
    'project version': 'config/version="49.0.0"' in project,
    'loader marker': "marker.textContent = 'V49.0 // OVERHAUL GLOBAL';" in export,
    'pickup QoL helper': '_count_nearby_supplies' in main and '_request_emergency_support' in main,
    'graveyard map orphan removed': not (ROOT / 'assets' / 'map' / 'desert_world_v48_0.png').exists(),
    'release notes present': (ROOT / 'RELEASE_NOTES_V49_0.md').exists(),
    'version file present': (ROOT / 'VERSION.txt').exists(),
}
failed = [name for name, ok in checks.items() if not ok]
if failed:
    print('ERROR: V49.0 release checks failed:')
    for item in failed:
        print('  -', item)
    sys.exit(1)
print('OK: V49.0 static release checks passed.')
