#!/usr/bin/env python3
from __future__ import annotations
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TEXT_EXTS = {'.gd', '.tscn', '.tres', '.cfg', '.godot', '.html'}
RESOURCE_RE = re.compile(r'res://([^"\'`\)\]\s]+)')
missing: set[str] = set()
refs = 0

for path in ROOT.rglob('*'):
    if not path.is_file() or '.git' in path.parts or 'build' in path.parts:
        continue
    if path.suffix.lower() not in TEXT_EXTS and path.name not in {'project.godot', 'export_presets.cfg'}:
        continue
    try:
        text = path.read_text(encoding='utf-8')
    except UnicodeDecodeError:
        continue
    for rel in RESOURCE_RE.findall(text):
        # Strip simple punctuation that can trail references in prose/config.
        rel = rel.rstrip('.,;:')
        refs += 1
        if not (ROOT / rel).exists():
            missing.add(rel)

required = [
    ROOT / 'project.godot',
    ROOT / 'Main.tscn',
    ROOT / 'export_presets.cfg',
    ROOT / 'web' / 'offline.html',
    ROOT / 'assets' / 'ui' / 'pwa_icon_144.png',
    ROOT / 'assets' / 'ui' / 'pwa_icon_180.png',
    ROOT / 'assets' / 'ui' / 'pwa_icon_512.png',
]
for p in required:
    if not p.exists():
        missing.add(str(p.relative_to(ROOT)))

if missing:
    print('ERROR: missing project resources:')
    for item in sorted(missing):
        print(f'  - {item}')
    sys.exit(1)

print(f'OK: {refs} res:// references checked; no missing resources detected.')
