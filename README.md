# NØMAD ZERO — Development

Dépôt privé de développement du projet Godot **NØMAD ZERO**.

- **Stable / production** : `Zorvax-Dev/Nomad-Zero` — ne pas modifier depuis le développement.
- **Développement** : `Zorvax-Dev/Nomad-Zero-Dev` — sources Godot et futures versions.
- **Base de développement** : V49.0.
- **Godot** : 4.7.x.

## Règle de sécurité

Le dépôt stable n'est jamais mis à jour automatiquement depuis ce dépôt. Une version de développement doit être testée et validée avant tout export vers `Nomad-Zero`.

## Structure attendue

Le fichier `project.godot` reste à la racine, avec `Main.tscn`, `scripts/`, `assets/`, `web/` et `tools/`.

## CI

Le workflow Godot est volontairement **manuel pendant l'import initial**. Une fois V49.0 entièrement synchronisée, il sera activé automatiquement sur chaque push et chaque pull request.
