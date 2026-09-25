# NØMAD ZERO Beta 1.0 — déploiement GitHub Pages

Le projet contient un workflow GitHub Actions qui :

1. télécharge Godot 4.7.2 et ses modèles d'export ;
2. vérifie les références du projet et la version intégrée de l'écran de chargement ;
3. ouvre/import le projet en mode headless ;
4. exporte automatiquement le preset **Web PWA** ;
5. vérifie que le build contient bien HTML, JavaScript, WASM, PCK, manifest PWA et service worker ;
6. conserve le build Web comme artefact téléchargeable pendant 14 jours ;
7. le publie sur GitHub Pages.

## Mise en ligne

- Créer ou utiliser un dépôt GitHub pour NØMAD ZERO.
- Copier le contenu de ce dossier à la racine du dépôt.
- Pousser sur `main` ou `master`.
- Dans **Settings → Pages → Build and deployment → Source**, choisir **GitHub Actions**.
- Ouvrir ensuite l'onglet **Actions** : le workflow `Build and deploy NØMAD ZERO Web PWA` construit et publie le jeu.

Le workflow peut aussi être lancé manuellement via **Actions → Build and deploy NØMAD ZERO Web PWA → Run workflow**.

## Test iPhone / PWA

Une fois la page publiée :

- ouvrir l'URL dans Safari ;
- lancer le jeu une première fois en ligne et vérifier que l'écran de chargement NØMAD ZERO disparaît au menu ;
- utiliser **Partager → Sur l'écran d'accueil** ;
- lancer la PWA depuis l'icône ;
- faire une partie, quitter complètement, rouvrir et vérifier la sauvegarde ;
- activer le mode avion après un premier chargement et vérifier que l'écran hors-ligne/PWA se comporte correctement.

Le preset Web est volontairement **sans threads**, ce qui évite les contraintes de `SharedArrayBuffer` et améliore la compatibilité Safari/iOS.
