#!/usr/bin/env python3
from __future__ import annotations
import sys
from pathlib import Path

root = Path(sys.argv[1] if len(sys.argv) > 1 else 'build/web')
if not root.exists():
    raise SystemExit(f'ERROR: export folder does not exist: {root}')

files = [p for p in root.rglob('*') if p.is_file()]
by_suffix = {}
for p in files:
    by_suffix.setdefault(p.suffix.lower(), []).append(p)

problems = []
index = root / 'index.html'
if not index.exists() or index.stat().st_size < 1000:
    problems.append('index.html missing or unexpectedly small')
elif 'NOMAD_LOADER_BEGIN' not in index.read_text(encoding='utf-8', errors='replace'):
    problems.append('custom NØMAD ZERO loading screen is missing from index.html')
for suffix in ('.wasm', '.pck', '.js'):
    if not by_suffix.get(suffix):
        problems.append(f'no {suffix} file found')

names = [p.name.lower() for p in files]
if not any('manifest' in n for n in names):
    problems.append('no PWA manifest detected')
if not any('service' in n and 'worker' in n for n in names):
    problems.append('no PWA service worker detected')

if problems:
    print('ERROR: Web export smoke check failed:')
    for p in problems:
        print(f'  - {p}')
    print('\nExported files:')
    for f in sorted(files):
        print(f'  {f.relative_to(root)} ({f.stat().st_size} bytes)')
    sys.exit(1)

size_mb = sum(p.stat().st_size for p in files) / (1024 * 1024)
print(f'OK: Web export looks complete ({len(files)} files, {size_mb:.1f} MiB).')
