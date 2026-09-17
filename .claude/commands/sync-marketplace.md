---
description: Anade al marketplace los submodulos que aun no tienen entrada y hace commit
---

Para cada submodulo listado en `.gitmodules` cuyo path NO aparezca como `"./<path>"` en
`.claude-plugin/marketplace.json`:

1. Mira que hay dentro de `<path>/`:
   - **Tiene `.claude-plugin/plugin.json`** -> entrada minima, el manifiesto manda:
     ```json
     { "name": "<name de plugin.json>", "source": "./<path>", "category": "<categoria>" }
     ```
   - **No lo tiene** (repo de solo `skills/`, `commands/`, `agents/`, `.mcp.json`...) ->
     entrada autosuficiente con `"strict": false`, que define el plugin entero:
     ```json
     {
       "name": "<nombre-kebab-case>",
       "source": "./<path>",
       "description": "<que aporta, leido de su README>",
       "category": "<categoria>",
       "strict": false
     }
     ```
     `skills/` se autodescubre desde la raiz del plugin; `commands/` y `agents/` solo si
     declaras sus rutas en la entrada. No hace falta carpeta wrapper.
2. Valida: `node -e "JSON.parse(require('fs').readFileSync('.claude-plugin/marketplace.json','utf8'))"`.
3. Commit en MyFactory con los tres cambios juntos (`.gitmodules`, el submodulo y el manifiesto):
   `git add .gitmodules <path> .claude-plugin/marketplace.json && git commit -m "feat(marketplace): anade <name>"`

Si el submodulo trae `plugin.json` pero declara componentes que no quieres exponer, usa
`"strict": false` **solo** si ese `plugin.json` no declara componentes; si los declara, el
plugin falla al cargar y entonces si toca carpeta wrapper en `plugins/<name>/`.
