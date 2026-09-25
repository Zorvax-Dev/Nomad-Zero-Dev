# NØMAD ZERO — Development

Dépôt privé de développement du projet Godot **NØMAD ZERO**.

- **Stable / production** : `Zorvax-Dev/Nomad-Zero` — reste intact tant qu'une version n'est pas explicitement validée.
- **Développement** : `Zorvax-Dev/Nomad-Zero-Dev` — sources Godot et futures versions.
- **Base courante** : **V49.5 — Combat & exploration**.
- **Godot** : 4.7.x.

## Organisation

Le dépôt de développement contient le vrai projet Godot : `project.godot`, `Main.tscn`, `scripts/`, `assets/`, `web/` et `tools/`.

Les changements sont testés ici. Aucun déploiement vers le dépôt stable n'est automatique.

## V49.0

Cette passe améliore le flow général du jeu : mouvement du héros, attraction des pickups, ouverture des caches, pression des vagues, soutien contextuel des zones et ravitaillement d'urgence lorsque la situation devient critique.

## V49.1

Cette passe renforce l’identité des zones avec une ambiance visuelle légère, un bandeau d’entrée contextuel et des conseils temporaires. Les apparitions ennemies sont aussi mieux espacées pour limiter les regroupements brouillons sans réduire la pression des vagues.

## Automatisation Web

Chaque modification source poussée sur `main` est maintenant validée par Godot 4.7.2, exportée en Web/PWA et testée automatiquement. Si le build est valide, les fichiers `index*` générés sont remis à jour directement à la racine du dépôt. Les builds obsolètes sont annulés pour éviter qu’une ancienne version écrase une version plus récente.

## V49.2

Cette passe réduit les paquets d’ennemis en ajoutant une séparation locale pendant leurs déplacements et une légère correction même lorsqu’ils sont au contact. Les gros profils conservent davantage d’espace autour d’eux, ce qui améliore la lecture des silhouettes et des télégraphes sans réduire la pression du combat.

## V49.3

Cette passe donne une vraie signature de combat aux ennemis de base : Raider plus mobile, Blaster à double tir télégraphié et Lourd à frappe de zone. Les groupes sont mieux composés et désynchronisés, l’onde automatique se déclenche de façon plus intelligente, le joystick flottant suit les longs glissements, les anciens contrôles de dash ont été neutralisés et la compatibilité des sauvegardes a été renforcée pour tous les types d’ennemis actuels.

## V49.4

Passe de cohérence technique et gameplay : suppression réelle des anciens systèmes de dash, surcharge, traction et bouclier qui restaient en code mort, tout en gardant la compatibilité des anciennes sauvegardes. Les récompenses et objets concernés ont été reconvertis vers la mobilité normale, l’armure et l’onde de Force. Le registre des ennemis est centralisé et les contrôles CI vérifient désormais que ces systèmes retirés ne réapparaissent pas.

## V49.5

Cette passe rend les combats et l’exploration moins mécaniques : les ennemis à distance cherchent désormais une vraie ligne de tir au lieu de tirer dans les décors, l’alerte hors écran privilégie la menace la plus dangereuse, les choix de niveau sont légèrement pondérés pour aider les synergies sans imposer un build, et les événements Embuscade / Corruption jusque-là dormants sont maintenant réellement intégrés aux vagues. Les vérifications de release couvrent ces comportements.
