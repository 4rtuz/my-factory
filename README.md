# my-factory

Marketplace de Claude Code con plugins propios (`plugins/`) y plugins de terceros traídos como submódulos (`tools/`). El catálogo está en [.claude-plugin/marketplace.json](.claude-plugin/marketplace.json).

## Instalación

```
/plugin marketplace add 4rtuz/my-factory
/plugin install <plugin>@my-factory
```

Para probar un plugin sin instalarlo: `claude --plugin-dir plugins/<plugin>`.

## Plugins propios

| Plugin | Qué aporta |
|---|---|
| [sdd-spec-writer](plugins/sdd-spec-writer) | Comando `/spec` y agente `spec-writer`: convierten una petición en `docs/specs/NNNN/spec.md` + `decisions.md`, coherentes con CLAUDE.md, AGENTS.md y las specs existentes. El comando `/sdd` encadena spec → plan → validadores. Depende de `spec-tools` y `spec-validators`. |
| [spec-tools](plugins/spec-tools) | Agente `spec-planner`: convierte una spec en un plan de implementación trazable en `docs/implementation-plans/`, analizando el código real. Planifica, no implementa. |
| [spec-validators](plugins/spec-validators) | Agente `spec-validator`: lee spec y plan y escribe en `docs/validators.md` los validadores y verificadores de los puntos donde la solución puede fallar, con discrepancias spec ↔ plan y matriz de cobertura. |
| [auditor-entregable](plugins/auditor-entregable) | Comando `/auditar` (solo invocable a mano): audita el repo storyMaker contra el checklist del examen final de Harness Engineering y lanza en segundo plano una sesión `/sdd` por cada hueco, ronda a ronda, hasta que todo lo exigido tiene spec. |
| [ci-fixer](plugins/ci-fixer) | Agente que repara fallos de CI de GitHub Actions tocando solo código de producción, nunca tests ni CI. Hooks que le dan el estado del CI al arrancar, tras cada push y al intentar terminar; settings con deny de tests, force push y ramas protegidas. Cada fallo pasa por `/sdd` antes de implementarse. |
| [critic-reviewer](plugins/critic-reviewer) | Agente crítico-revisor sin permisos de escritura para libros, papers, repositorios y proyectos. La skill `review-rubrics` elige la rúbrica según el tipo de contenido. |
| [verification-plan](plugins/verification-plan) | Skill que genera un `verification.md` recorriendo 18 técnicas de verificación de código y de agentes según el marco TAIDU del Trust Spec, y declara lo que no se verifica como riesgo aceptado. |

## Plugins de terceros (`tools/`)

| Plugin | Qué aporta |
|---|---|
| [mattpocock-skills](tools/mattpocock-skills) | Skills de ingeniería: `grilling`, `tdd`, `diagnosing-bugs`, `code-review`, `domain-modeling`, `codebase-design`, `prototype`, `research`, `to-spec`/`to-tickets`, `resolving-merge-conflicts`, `wizard`, `writing-for-agents`, entre otras. |
| [superpowers](tools/superpowers) | Biblioteca de skills de proceso: brainstorming, `writing-plans`/`executing-plans`, `test-driven-development`, `systematic-debugging`, `subagent-driven-development`, `using-git-worktrees`, revisión de código y `verification-before-completion`. |
| [ponytail](tools/ponytail) | Modo «senior perezoso»: fuerza la solución más simple que funciona (YAGNI, stdlib primero, sin abstracciones no pedidas). Incluye `ponytail-review`, `ponytail-audit` (sobreingeniería en diff o repo), `ponytail-debt`, `ponytail-gain` y `ponytail-help`. |
| [taste-skill](tools/taste-skill) | Skills de diseño frontend contra el aspecto genérico: estilos `minimalist`, `brutalist`, `soft`, `redesign`, `stitch`, `image-to-code`, generación de imágenes de referencia web/móvil y `brandkit`. |
| [threejs-skills](tools/threejs-skills) | Skills de Three.js: fundamentos, geometría, materiales, shaders, luces, texturas, animación, interacción, loaders y postprocesado. |
| [fastapi-skill](tools/fastapi-skill) | Skill oficial de FastAPI: path operations, Pydantic, dependencias, respuestas, streaming/SSE y servir frontends. |
| [feature-sliced-design](tools/feature-sliced-design) | Skill oficial de Feature-Sliced Design v2.1: capas, slices, APIs públicas, límites de import y migración en frontend. |
| [find-skills](tools/find-skills) | Descubre e instala skills del registro abierto (`npx skills`) cuando pides una capacidad que no tienes. |

`fastapi-skill` y `feature-sliced-design` son carpetas envoltorio con su propio `plugin.json`; el submódulo está en `upstream/`.

## Mantenimiento

- `/sync-marketplace` ([.claude/commands/sync-marketplace.md](.claude/commands/sync-marketplace.md)): añade al catálogo los submódulos que aún no tienen entrada y hace commit.
- [.claude/hooks/check-marketplace-drift.mjs](.claude/hooks/check-marketplace-drift.mjs) avisa de submódulos sin entrada en el catálogo.
- [roadmap/](roadmap) recoge investigación sobre optimización de tokens con agentes.
