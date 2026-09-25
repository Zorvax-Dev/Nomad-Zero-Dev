# V49.3 — Identités de combat

## Ennemis
- Le **Raider** ne fonce plus simplement en ligne droite : il approche en biais puis peut déclencher une percée latérale télégraphiée.
- Le **Blaster** maintient désormais sa distance et utilise un double tir télégraphié.
- Le **Lourd** possède une frappe de zone lisible au contact.
- Les nouveaux télégraphes ont leurs propres formes et libellés.
- Les groupes d’ennemis démarrent avec des délais d’action légèrement décalés afin d’éviter les attaques parfaitement synchronisées.
- Des plafonds souples limitent les accumulations de Snipers, Suppresseurs, Briseurs, Lourds et autres profils très lisibles individuellement mais confus en surnombre.

## Contrôles et sensations
- Le joystick reste activable partout mais sa base suit désormais les longs glissements pour réduire la tension du pouce.
- L’ancien déclenchement clavier du dash a été retiré afin de rester cohérent avec le design actuel sans dash.
- Les bonus permanents qui amélioraient encore le dash ont été réaffectés à la mobilité normale.
- Les descriptions des améliorations correspondent maintenant exactement aux valeurs réellement appliquées.

## Onde de Force
- L’onde automatique ne se gaspille plus systématiquement sur une cible légère isolée.
- Elle se déclenche quand plusieurs ennemis entrent dans la zone ou lorsqu’une menace lourde, élite, mini-boss ou boss devient urgente.

## Sauvegardes
- Les timers de comportement des ennemis sont maintenant conservés dans les nouveaux checkpoints.
- Ces nouveaux champs restent optionnels lors de l’import afin de préserver les anciennes sauvegardes.
- Le validateur reconnaît maintenant tous les ennemis actuels du Canyon et du Cimetière, ainsi que les boss récents.

## Build
- Sources Godot : **49.3.0**.
- Validation, import headless, export Web/PWA, smoke test et rafraîchissement du build sont automatisés par GitHub Actions.
