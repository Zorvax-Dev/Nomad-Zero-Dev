# V50.1 — Monde modulaire HD

## Correction de méthode
- Le fond de carte ne contient plus les grandes structures.
- Le terrain est généré en **4096 × 3072**, soit exactement la taille du monde Godot.
- `MAP_SCALE` repasse à **1.0** : aucune texture 1024×768 n'est étirée ×4.
- Les structures sont de nouveau rendues depuis leurs assets haute définition séparés.

## Blocage garanti
- Tous les landmarks utilisent `_add_landmark(...)`.
- Cette fonction crée le sprite **et son collider principal dans le même appel**.
- Les silhouettes complexes peuvent recevoir des colliders secondaires juste après leur création.
- Les petits cailloux du sol restent décoratifs ; les gros rochers et toutes les structures importantes bloquent réellement le passage.

## Nettoyage visuel
- Suppression de `v47_echo_ruins.png` et `v47_echo_spire.png`, dont le style simpliste dénotait avec le reste.
- Suppression de `v46_1_outpost.png`, qui dupliquait visuellement le camp nomade.
- Suppression de l'ancienne map V50 floue et précomposée.
- Le Canyon est maintenant construit avec les rochers détaillés déjà cohérents avec sa palette.

## Sol
- Base V48 conservée comme terrain uniquement puis reconstruite en résolution native.
- Netteté restaurée par upscale Lanczos, contraste modéré et microtexture de sable.
- Saturation légèrement réduite pour mieux raccorder les assets détaillés entre eux.

## Gameplay conservé
- IA, vagues, synergies, événements, sauvegarde locale, joystick flottant et équilibrages V49/V50 restent actifs.

## Version
- Sources Godot : **50.1.0**.
