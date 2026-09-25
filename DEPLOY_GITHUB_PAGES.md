# NØMAD ZERO — build Web/PWA automatisé

Le dépôt de développement construit désormais automatiquement la version Web/PWA à chaque changement de source poussé sur `main`.

## Ce que fait GitHub Actions

Le workflow `.github/workflows/godot-ci.yml` :

1. installe Godot 4.7.2 et les modèles d’export correspondants ;
2. vérifie la cohérence de version et toutes les références `res://` ;
3. importe le projet en mode headless pour détecter les erreurs Godot ;
4. exporte le preset **Web PWA** ;
5. exécute le smoke test du build ;
6. conserve le build complet comme artefact pendant 14 jours ;
7. remet automatiquement les fichiers `index*` générés à la racine du dépôt sur `main`.

Les exécutions obsolètes sont annulées automatiquement : seul le build correspondant au dernier état de `main` peut être republié.

## GitHub Pages

Si GitHub Pages sert la branche `main` depuis la racine du dépôt, la mise à jour des fichiers `index*` suffit à mettre la nouvelle PWA en ligne sans export manuel local.

Le dépôt stable `Zorvax-Dev/Nomad-Zero` reste indépendant : aucune publication vers ce dépôt n’est faite automatiquement.

## Test iPhone / PWA

Après une nouvelle publication :

- ouvrir la page dans Safari en paysage ;
- vérifier le menu et le chargement NØMAD ZERO ;
- ajouter la page à l’écran d’accueil ;
- vérifier la reprise de sauvegarde après fermeture complète ;
- vérifier le comportement hors-ligne après un premier chargement réussi.

Le preset Web reste volontairement sans threads pour conserver une bonne compatibilité Safari/iOS.
