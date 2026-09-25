#!/bin/bash
# Place ce fichier à côté de project.godot, puis ouvre-le sur Mac.
set -u

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd -P)" || exit 1
cd "$PROJECT_DIR" || exit 1

pause_and_exit() {
  local code="${1:-1}"
  echo
  if [ -t 0 ]; then
    read -n 1 -s -r -p "Appuie sur une touche pour fermer..." _key || true
    echo
  fi
  exit "$code"
}

fail() {
  echo
  echo "ERREUR : $1"
  pause_and_exit "${2:-1}"
}

if [ ! -f project.godot ] || [ ! -f export_presets.cfg ]; then
  fail "Place EXPORT_IPHONE_NOMAD_ZERO.command dans le dossier décompressé de NØMAD ZERO, à côté de project.godot et export_presets.cfg."
fi

if ! grep -q '^name="Web PWA"' export_presets.cfg; then
  fail "Le preset d'export Web PWA est introuvable dans export_presets.cfg."
fi

REQUIRED_VERSION="$(sed -nE 's/^config\/features=PackedStringArray\("([0-9]+\.[0-9]+)".*/\1/p' project.godot | head -n 1)"
if [[ "$REQUIRED_VERSION" =~ ^([0-9]+)\.([0-9]+)$ ]]; then
  REQUIRED_MAJOR="${BASH_REMATCH[1]}"
  REQUIRED_MINOR="${BASH_REMATCH[2]}"
else
  REQUIRED_MAJOR=4
  REQUIRED_MINOR=0
  REQUIRED_VERSION="4.0"
fi

compatible_godot() {
  local version
  [ -x "$1" ] || return 1
  version="$("$1" --version 2>/dev/null)" || return 1
  if [[ "$version" =~ ^([0-9]+)\.([0-9]+) ]]; then
    [ "${BASH_REMATCH[1]}" -gt "$REQUIRED_MAJOR" ] || {
      [ "${BASH_REMATCH[1]}" -eq "$REQUIRED_MAJOR" ] &&
      [ "${BASH_REMATCH[2]}" -ge "$REQUIRED_MINOR" ]
    }
  else
    return 1
  fi
}

find_godot() {
  local candidate app_path
  local candidates=(
    "/Applications/Godot.app/Contents/MacOS/Godot"
    "$HOME/Applications/Godot.app/Contents/MacOS/Godot"
    "$HOME/Downloads/Godot.app/Contents/MacOS/Godot"
    "$HOME/Desktop/Godot.app/Contents/MacOS/Godot"
    "$HOME/Library/Application Support/Steam/steamapps/common/Godot Engine/Godot.app/Contents/MacOS/Godot"
  )

  for candidate in "${candidates[@]}"; do
    if compatible_godot "$candidate"; then echo "$candidate"; return 0; fi
  done

  for candidate in godot godot4; do
    if command -v "$candidate" >/dev/null 2>&1; then
      app_path="$(command -v "$candidate")"
      if compatible_godot "$app_path"; then echo "$app_path"; return 0; fi
    fi
  done

  if command -v mdfind >/dev/null 2>&1; then
    while IFS= read -r app_path; do
      candidate="$app_path/Contents/MacOS/Godot"
      if compatible_godot "$candidate"; then echo "$candidate"; return 0; fi
    done < <(mdfind "kMDItemFSName == 'Godot.app'c" 2>/dev/null)
  fi
  return 1
}

choose_godot_manually() {
  local app_path=""
  if command -v osascript >/dev/null 2>&1; then
    app_path="$(osascript <<'APPLESCRIPT' 2>/dev/null
try
  set chosenApp to choose application with prompt "Sélectionne Godot pour exporter NØMAD ZERO."
  POSIX path of chosenApp
on error
  return ""
end try
APPLESCRIPT
)"
  fi
  app_path="${app_path%/}"
  if [ -n "$app_path" ]; then
    echo "$app_path/Contents/MacOS/Godot"
  fi
}

echo "============================================================"
echo "NØMAD ZERO — EXPORT IPHONE / PWA"
echo "============================================================"
echo

GODOT_BIN_PATH="${NOMAD_GODOT_BINARY:-}"
if [ -z "$GODOT_BIN_PATH" ]; then
  GODOT_BIN_PATH="$(find_godot)" || true
fi
if [ -z "$GODOT_BIN_PATH" ]; then
  echo "Godot $REQUIRED_VERSION ou plus récent n'a pas été trouvé automatiquement."
  GODOT_BIN_PATH="$(choose_godot_manually)"
fi
if [ -z "$GODOT_BIN_PATH" ] || ! compatible_godot "$GODOT_BIN_PATH"; then
  fail "Godot compatible introuvable. Ce projet demande Godot $REQUIRED_VERSION ou plus récent."
fi

echo "Godot : $GODOT_BIN_PATH"
"$GODOT_BIN_PATH" --version
echo

if command -v python3 >/dev/null 2>&1 && [ -f tools/validate_project.py ]; then
  echo "Vérification des fichiers du projet..."
  python3 tools/validate_project.py || fail "Il manque des fichiers au projet."
  python3 tools/embed_web_loader.py --check || fail "L'écran de chargement Web doit être réintégré dans le preset."
fi

command -v zip >/dev/null 2>&1 || fail "L'utilitaire zip est introuvable sur ce Mac."

BUILD_DIR="$PROJECT_DIR/build"
OUTPUT_SITE="$BUILD_DIR/iphone_site"
OUTPUT_ZIP="$BUILD_DIR/NOMAD_ZERO_iPhone_PWA.zip"
mkdir -p "$BUILD_DIR" || fail "Impossible de créer le dossier build."
STAGING_DIR="$(mktemp -d "$BUILD_DIR/.nomad_iphone.XXXXXX")" || fail "Impossible de préparer l'export."
trap 'rm -rf "$STAGING_DIR"' EXIT
STAGING_SITE="$STAGING_DIR/site"
mkdir -p "$STAGING_SITE" || fail "Impossible de préparer le site Web."

echo "Import des ressources Godot..."
"$GODOT_BIN_PATH" --headless --editor --path "$PROJECT_DIR" --import ||
  fail "L'import Godot a échoué. Vérifie les messages affichés juste au-dessus."

echo
echo "Export du preset Web PWA..."
"$GODOT_BIN_PATH" --headless --path "$PROJECT_DIR" --export-release "Web PWA" "$STAGING_SITE/index.html" || {
  echo "Dans Godot : Éditeur > Gérer les modèles d'export > Télécharger et installer."
  echo "Puis vérifie Projet > Exporter > Web PWA et relance cette commande."
  fail "L'export Web a échoué. Vérifie les messages de Godot ci-dessus."
}

# Le preset du projet fournit déjà le manifest, les icônes, l'orientation
# paysage et le service worker. Ne pas les remplacer par ceux d'un autre jeu.
touch "$STAGING_SITE/.nojekyll" || fail "Impossible de préparer le site pour GitHub Pages."

# Ajoute les métadonnées iOS sans modifier les fichiers PWA générés par Godot.
if command -v python3 >/dev/null 2>&1; then
  python3 - "$STAGING_SITE/index.html" <<'PY' || fail "Impossible d'adapter la page pour iPhone."
from pathlib import Path
import re
import sys

page = Path(sys.argv[1])
html = page.read_text(encoding="utf-8")
if not re.search(r"</head\s*>", html, flags=re.I):
    raise SystemExit("Balise </head> absente de l'export Godot.")

viewport = re.search(r"<meta\b(?=[^>]*\bname\s*=\s*['\"]viewport['\"])[^>]*>", html, flags=re.I)
if viewport:
    tag = viewport.group()
    content = re.search(r"\bcontent\s*=\s*(['\"])(.*?)\1", tag, flags=re.I | re.S)
    if content and "viewport-fit=" not in content.group(2):
        updated = tag[:content.start(2)] + content.group(2) + ", viewport-fit=cover" + tag[content.end(2):]
        html = html[:viewport.start()] + updated + html[viewport.end():]

extras = {
    "apple-mobile-web-app-capable": "yes",
    "apple-mobile-web-app-status-bar-style": "black-translucent",
    "apple-mobile-web-app-title": "NØMAD ZERO",
}
tags = []
for name, value in extras.items():
    if not re.search(rf"<meta\b(?=[^>]*\bname\s*=\s*['\"]{name}['\"])[^>]*>", html, flags=re.I):
        tags.append(f'<meta name="{name}" content="{value}">')
if tags:
    html = re.sub(r"</head\s*>", "\n".join(tags) + "\n</head>", html, count=1, flags=re.I)

page.write_text(html, encoding="utf-8")
PY
fi

echo "Contrôle du site exporté..."
if command -v python3 >/dev/null 2>&1 && [ -f tools/smoke_check_web.py ]; then
  python3 tools/smoke_check_web.py "$STAGING_SITE" || fail "L'export PWA est incomplet."
else
  [ -s "$STAGING_SITE/index.html" ] || fail "index.html est absent ou vide."
  for extension in js wasm pck; do
    [ -n "$(find "$STAGING_SITE" -type f -name "*.$extension" -print -quit)" ] ||
      fail "Le fichier .$extension est absent de l'export."
  done
  [ -n "$(find "$STAGING_SITE" -type f -iname '*manifest*' -print -quit)" ] ||
    fail "Le manifest PWA est absent de l'export."
  [ -n "$(find "$STAGING_SITE" -type f -iname '*service*worker*' -print -quit)" ] ||
    fail "Le service worker PWA est absent de l'export."
fi

echo "Création de l'archive à publier..."
STAGING_ZIP="$STAGING_DIR/NOMAD_ZERO_iPhone_PWA.zip"
(cd "$STAGING_SITE" && zip -qr -X "$STAGING_ZIP" . -x '*.DS_Store') ||
  fail "Impossible de créer le fichier ZIP."

rm -rf "$OUTPUT_SITE" || fail "Impossible de remplacer l'ancien export."
mv "$STAGING_SITE" "$OUTPUT_SITE" || fail "Impossible d'enregistrer le nouvel export."
mv -f "$STAGING_ZIP" "$OUTPUT_ZIP" || fail "Impossible d'enregistrer le fichier ZIP."

echo
echo "============================================================"
echo "EXPORT TERMINÉ"
echo "============================================================"
echo "Site à publier : $OUTPUT_SITE"
echo "Archive du site : $OUTPUT_ZIP"
echo "Ouvre le jeu via un hébergement HTTPS, puis installe-le depuis Safari."
echo
if command -v open >/dev/null 2>&1; then open "$OUTPUT_SITE" >/dev/null 2>&1 || true; fi
pause_and_exit 0
