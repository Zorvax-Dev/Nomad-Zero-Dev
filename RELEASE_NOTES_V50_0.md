# V50.0 — Reconstruction visuelle

## Carte du monde
- Nouvelle carte de fond **V50** peinte comme un seul environnement cohérent.
- Palette unifiée : sable doré, roches terracotta, routes gris-brun et falaises rouges.
- Sol entièrement retravaillé : dunes, traces de vent, craquelures, petits cailloux, transitions plus naturelles et routes plus lisibles.
- Les grands landmarks sont désormais intégrés à la même direction artistique : camp, raffinerie, épaves, avant-poste, ruine du Canyon et Cimetière.

## Cohérence
- Suppression de la superposition des anciens sprites V46–V49 au-dessus de la nouvelle carte.
- Le monde n'affiche donc plus un décor ancien par-dessus un sol d'une autre couleur ou d'un autre style.
- La nouvelle texture V50 remplit directement les **4096 × 3072** unités du monde.

## Collisions
- Recalage des collisions sur les structures visibles de la carte V50.
- Réduction volontaire des volumes invisibles autour des petits rochers.
- Les gros landmarks restent bloquants.
- La bordure rocheuse orientale du Canyon est collisionnée au plus près de l'extrême droite pour préserver les routes.
- Les points d'intérêt du Canyon et du Cimetière ont été réalignés sur leur représentation visuelle.

## Gameplay conservé
- Les systèmes de combat, IA, événements, synergies, sauvegarde locale, joystick flottant et équilibrages V49 restent actifs.
- Aucun retour du dash, du bouclier, de la surcharge ou de la traction.

## Build
- Sources Godot : **50.0.0**.
- La Web/PWA est reconstruite automatiquement après validation.
