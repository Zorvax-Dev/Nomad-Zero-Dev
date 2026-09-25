from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]

main = (ROOT / "scripts" / "main.gd").read_text(encoding="utf-8")
project = (ROOT / "project.godot").read_text(encoding="utf-8")
loader = (ROOT / "web" / "loading_theme.html").read_text(encoding="utf-8")
export = (ROOT / "export_presets.cfg").read_text(encoding="utf-8")
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
