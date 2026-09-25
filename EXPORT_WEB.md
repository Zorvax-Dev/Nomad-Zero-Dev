# Export Web PWA

Le preset `Web PWA` est déjà inclus dans `export_presets.cfg`.

Réglages préparés : rendu Compatibility, export Web sans threads, PWA activée, mode standalone, orientation paysage, icônes haute résolution et page hors-ligne.

Le mode portrait est aussi masqué dès le chargement HTML. En cours de jeu, l'interface de rotation arrête la partie et la restaure en paysage. Un onglet Safari peut rester physiquement vertical malgré la préférence du manifeste PWA ; la rotation de l'appareil reste nécessaire pour jouer.

L'export Web est configuré vers `build/web/index.html`. Utilise Godot 4.7 ou une version 4.7.x plus récente, ainsi que les modèles d'export correspondants.

Le preset inclut `viewport-fit=cover` afin que Safari expose les marges sûres des iPhone. Le jeu lit ces marges au lancement et après redimensionnement. Il garde une marge latérale minimale sur iPhone en paysage si Safari ne fournit pas les valeurs attendues.

L'habillage du chargement Web se trouve dans `web/loading_theme.html`. Après toute modification de ce fichier, lancer `python3 tools/embed_web_loader.py` pour l'inclure dans le preset d'export. La barre et le pourcentage reprennent la progression fournie par Godot. Le chargement avant l'affichage du menu reste nécessaire lors du téléchargement du jeu ; le lancement de **JOUER** n'ajoute pas d'attente artificielle.
