# V49.5 — Combat & exploration

## IA ennemie
- Les ennemis à distance vérifient désormais leur **ligne de tir réelle**.
- Blasters, Snipers, Suppresseurs, Techniciens du Voile, Drones, Tourelles et Chasseurs Phase se repositionnent lorsqu’un décor bloque le joueur.
- Les vérifications de visibilité sont mises en cache et décalées entre ennemis afin de préserver les performances mobiles.
- Le système d’espacement V49.2 et les identités de combat V49.3 restent actifs.

## Lisibilité
- Ajout d’un **directeur de composition** léger : il évite les vagues saturées de tireurs et réintroduit une menace à distance lorsqu’un groupe devient entièrement mêlée.
- Les fallback restent adaptés à la zone : automates au Cimetière, profils du Voile dans le Canyon, etc.
- L’indicateur de menace hors écran ne sélectionne plus simplement l’ennemi le plus proche.
- Il privilégie maintenant les télégraphes les plus dangereux : boss, sniper, lourds, charges, tirs de suppression, etc.
- La couleur de l’alerte reflète la famille de menace.

## Builds
- Ajout d’une pondération légère des choix de niveau.
- Le jeu favorise parfois une amélioration capable de rapprocher un build d’une synergie, sans rendre les choix déterministes.
- Nouvelles synergies :
  - **Flux Nomade** — mobilité + cadence ;
  - **Conducteur du Rift** — attraction + onde de Force ;
  - **Volonté d’Acier** — PV + armure.
- Les trois choix restent distincts et gardent une part importante d’aléatoire.

## Événements du monde
- **Embuscade** est maintenant réellement tirable à partir de la vague 4.
- **Corruption** est maintenant réellement tirable à partir de la vague 7.
- Les événements planifiés ne sont plus annulés silencieusement sur les vagues impaires.
- Les vagues avancées donnent légèrement plus de poids aux événements de combat, tout en conservant Patrouille, Cache et Traqueur du Rift.

## Fin de run
- L’écran de défaite affiche maintenant les modules, les synergies et le meilleur temps en plus du niveau, des KO, des élites et des fragments.

## Qualité
- Le pipeline ignore maintenant les commits purement documentaires et tolère les conflits de course lorsqu’un build Web obsolète tente de pousser après une modification source plus récente.
- Les contrôles automatiques vérifient maintenant l’IA de ligne de tir, l’indicateur de menace, la pondération des améliorations et l’activation complète des événements.
- Validation Godot, export Web/PWA et smoke test restent automatisés.

## Version
- Sources Godot : **49.5.0**.
