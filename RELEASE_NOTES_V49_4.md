# V49.4 — Cohérence & stabilité

## Nettoyage gameplay
- Suppression complète du runtime de dash du joueur.
- Suppression des anciens systèmes internes de **Surcharge** et **Traction**, déjà retirés de l’interface.
- Suppression des sprites de dash désormais orphelins.
- Les anciens champs de sauvegarde du dash sont conservés uniquement comme compatibilité d’import.

## Onde de Force
- Le vocabulaire et les récompenses de bouclier ont été retirés du gameplay actif.
- Les anciennes cellules de bouclier sauvegardées sont automatiquement converties en cellules d’énergie de Force.
- Les récompenses du Gardien Null et plusieurs reliques ont été reconverties vers armure, PV et recharge de l’onde.
- Les bonus permanents précédemment liés au dash renforcent maintenant la mobilité normale.

## Robustesse des sauvegardes
- Registre unique `ALL_ENEMY_KINDS` utilisé par la restauration et la validation des checkpoints.
- Tous les ennemis actuels, mini-boss et boss sont couverts par le même registre.
- Les timers comportementaux ajoutés en V49 restent optionnels pour les anciennes sauvegardes.

## Contrôles qualité
- Le contrôle de release vérifie maintenant :
  - les identités de combat V49.3 ;
  - le joystick flottant élastique ;
  - l’absence de dash actif ;
  - l’absence de Surcharge / Traction actives ;
  - l’absence de vocabulaire de bouclier actif ;
  - l’absence des anciens sprites de dash.
- GitHub Actions continue de valider, importer, exporter et tester automatiquement le build Web/PWA.

## Version
- Sources Godot : **49.4.0**.
