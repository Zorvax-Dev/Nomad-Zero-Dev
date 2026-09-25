# V49.6 — Monde & collisions

## Profondeur visuelle
- Les décors ne sont plus triés uniquement sur leur centre d’image.
- Chaque famille de décor possède maintenant un décalage de profondeur basé sur son **pied visuel**.
- Le héros et les ennemis passent donc derrière un landmark tant qu’ils sont réellement derrière, puis devant lorsqu’ils atteignent sa façade.
- Ce changement vise directement les cas où un personnage semblait passer au-dessus d’un décor trop tôt.

## Cimetière d’Épaves
- Échelle du Léviathan augmentée de manière modérée.
- Station de récupération, fosse industrielle et amas de ferraille rendus plus présents.
- Ajout de deux amas secondaires, à partir du même asset cohérent de la zone, avec tailles et orientations différentes.
- Aucun nouveau style graphique n’est introduit : la passe réutilise uniquement les images déjà validées du Cimetière.

## Collisions
- Les anciennes ellipses du Cimetière provenaient de gabarits plus grands que les sprites actuels.
- Elles ont été remplacées par plusieurs empreintes plus petites qui suivent les masses réellement visibles.
- Le Léviathan utilise plusieurs volumes séparés au lieu d’un énorme ovale.
- La station de récupération sépare le bâtiment principal et la zone de grue.
- La fosse et les amas suivent désormais leur taille d’image réelle.
- Résultat recherché : moins de murs invisibles, glissement plus naturel et passages plus cohérents.

## Autres zones
- Avant-poste légèrement agrandi pour mieux tenir son rôle de landmark.
- Ruines et spire du Canyon rehaussées en taille.
- Ajout d’un rocher de Canyon supplémentaire pour mieux cadrer la partie basse de la zone.

## Qualité
- Le contrôle de release vérifie désormais le tri de profondeur, la densité du Cimetière et la nouvelle calibration de collision.

## Version
- Sources Godot : **49.6.0**.
