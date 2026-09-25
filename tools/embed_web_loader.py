#!/usr/bin/env python3
"""Keep the readable Web loading theme embedded in Godot's export preset."""
from __future__ import annotations

import json
import sys
from pathlib import Path

project = Path(__file__).resolve().parents[1]
preset = project / "export_presets.cfg"
theme = (project / "web" / "loading_theme.html").read_text(encoding="utf-8").strip()
start = "<!-- NOMAD_LOADER_BEGIN -->"
end = "<!-- NOMAD_LOADER_END -->"
lines = preset.read_text(encoding="utf-8").splitlines(keepends=True)
key = "html/head_include="
found = False
changed = False

for index, line in enumerate(lines):
    if not line.startswith(key):
        continue
    if found:
        raise SystemExit("ERROR: duplicate html/head_include in export_presets.cfg")
    found = True
    head = json.loads(line[len(key):])
    if start in head:
        if end not in head:
            raise SystemExit("ERROR: incomplete loading theme markers")
        head = head[:head.index(start)].rstrip()
    updated = f"{head}\n{start}\n{theme}\n{end}"
    output = key + json.dumps(updated, ensure_ascii=False) + "\n"
    changed = line != output
    lines[index] = output

if not found:
    raise SystemExit("ERROR: html/head_include missing from export_presets.cfg")
if "--check" in sys.argv:
    if changed:
        raise SystemExit("ERROR: Web loading theme is not embedded; run tools/embed_web_loader.py")
    print("OK: Web loading theme matches the export preset.")
elif changed:
    preset.write_text("".join(lines), encoding="utf-8")
    print("Web loading theme embedded in export_presets.cfg.")
