# fastapi-skill

Wrapper del submodulo `upstream` (https://github.com/fastapi/fastapi).

La skill oficial vive en `upstream/fastapi/.agents/skills/fastapi`, fuera de la ruta
`skills/` que autodescubre Claude Code, asi que el `plugin.json` de esta carpeta la
declara explicitamente.

Actualizar: `git submodule update --remote tools/fastapi-skill/upstream`
