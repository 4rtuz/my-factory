# auditor-entregable

Audita el repo storyMaker contra los requisitos del examen final de Harness Engineering (`requisitos.md`) y, por cada hueco especificable, lanza en segundo plano una sesión de Claude Code que ejecuta `/sdd-spec-writer:sdd` con una petición autocontenida. Repite ronda a ronda hasta que todo lo exigido tiene spec, se agotan las rondas o una ronda no progresa.

Solo se ejecuta cuando lo llamas: el comando lleva `disable-model-invocation: true` y el plugin no trae agentes ni skills que Claude pueda elegir solo.

## Uso

Desde la raíz de storyMaker, en una sesión de desarrollo (no una del harness con `NOVELA_SESSION_ID`):

```
/auditor-entregable:auditar                    # hasta 3 rondas
/auditor-entregable:auditar --rondas 5 --opcionales
/auditor-entregable:auditar --solo-auditar     # solo el informe
```

## Qué produce

| Ruta | Qué es |
|---|---|
| `docs/auditoria-entregable.md` | Estado de cada requisito: cumple / parcial / falta, con evidencia |
| `.auditoria-entregable/ronda-R/huecos.json` | Peticiones enviadas a `/sdd` en esa ronda |
| `.auditoria-entregable/ronda-R/sesiones/*.log` | Salida de cada sesión en segundo plano |
| `docs/specs/…`, `docs/implementation-plans/…`, `docs/validators.md` | Lo que escribe `/sdd` |

`.auditoria-entregable/` es de trabajo: añádelo al `.gitignore` del repo auditado.

## Cómo funciona

1. Un subagente `general-purpose` audita el repo (lee, busca y ejecuta tests y verificadores; nunca llama a un modelo ni toca `novelas/`) y agrupa los huecos por sección del checklist.
2. `scripts/lanzar_sdd.py` lanza `claude -p "/sdd-spec-writer:sdd <petición>"` por cada grupo sin spec, **en secuencia**: `spec-writer` numera leyendo `docs/specs/`, y dos sesiones a la vez tomarían el mismo número.
3. Al terminar, la sesión principal recibe la notificación y audita de nuevo.

Requisitos tipo **M** (grabar el vídeo, presentar, enviar el email, la revisión humana) se listan como pendientes manuales y nunca se especifican.

## Dependencias

`sdd-spec-writer`, `spec-tools` y `spec-validators`. Si este plugin se carga desde el repo my-factory (`--plugin-dir`), las sesiones hijas cargan esos tres desde sus carpetas hermanas; si se instaló desde el marketplace, usan los instalados.

Comprobación del script: `python scripts/lanzar_sdd.py --test`.
