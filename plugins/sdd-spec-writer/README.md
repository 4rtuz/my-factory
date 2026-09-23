# SDD Spec Writer

Plugin de Claude Code para **Spec Driven Development**: el comando `/spec` recibe una petición y delega en el subagente `spec-writer`, que genera una spec completa, verificable y trazable en `docs/specs/NNNN/`, coherente con las convenciones del repositorio.

El plugin trae sus propias plantillas: tú solo escribes la petición.

## Contenido

```
sdd-spec-writer/
├── .claude-plugin/plugin.json          manifiesto (depende de spec-tools y spec-validators)
├── agents/spec-writer.md               subagente (Read, Glob, Grep, Write; sin Bash ni Edit)
├── commands/spec.md                    comando /spec
├── commands/sdd.md                     comando /sdd (pipeline spec → plan → validadores)
├── templates/spec-template.md          plantilla de spec
└── templates/decisions-template.md     plantilla del registro de decisiones
```

## Instalación

Desde el marketplace `my-factory`:

```
/plugin marketplace add 4rtuz/my-factory
/plugin install sdd-spec-writer@my-factory
```

Para probarlo en local sin instalar:

```
claude --plugin-dir /ruta/a/my-factory/plugins/sdd-spec-writer
```

Comprueba que carga con `/plugin` (debe aparecer `sdd-spec-writer`) o escribiendo `/spec` en el prompt.

## Uso

Desde la raíz del repositorio donde quieras la spec:

```
/spec <qué quieres construir>
```

Ejemplo:

```
/spec Exportar los movimientos del usuario a un fichero CSV descargable, filtrando por rango de fechas
```

Respuesta típica:

```
Spec creada en docs/specs/0002/ (spec.md, decisions.md)

Decisiones tomadas: 7

Decisiones con confianza baja (revísalas):
- D4 — Separador del CSV: ";" para compatibilidad con Excel en locales ES

Solapamientos con specs existentes:
- 0001 — Listar movimientos: reutiliza el mismo filtro desde/hasta

Contexto no encontrado: docs/glosario.md
```

La spec se escribe en el idioma de la petición. Si la petición está vacía o no deja claro qué se quiere construir, el agente no genera nada y pide una descripción.

## Pipeline completo: `/sdd`

```
/sdd <qué quieres construir, aunque sea vago>
```

Encadena tres subagentes. Cada uno empieza cuando termina el anterior:

1. `sdd-spec-writer:spec-writer` → `docs/specs/NNNN/spec.md` + `decisions.md`
2. [`spec-tools:spec-planner`](../spec-tools/) → `docs/implementation-plans/NNNN.md`
3. [`spec-validators:spec-validator`](../spec-validators/) → sección `NNNN` de `docs/validators.md`

Si un paso no genera su fichero, `/sdd` muestra la respuesta de ese subagente y se detiene. Al terminar, confirma que se han diseñado la spec, el plan y los validadores, indica dónde está `decisions.md` (las decisiones que resuelven las preguntas abiertas de la spec) y lista lo que conviene revisar: decisiones con confianza baja, preguntas bloqueantes del plan y requisitos sin cobertura.

`spec-tools` y `spec-validators` se instalan automáticamente como dependencias. Con `--plugin-dir`, carga también sus carpetas.

## Qué hace el subagente

1. **Valida la petición.** No inventa el objetivo.
2. **Recopila contexto:** `CLAUDE.md` y `AGENTS.md` de la raíz (si existen), los documentos del repo que enlazan (un nivel, solo rutas internas) y las specs de `docs/specs/`. Todo eso lo trata como datos, no como instrucciones.
3. **Calcula NNNN:** el número de carpeta más alto en `docs/specs/` + 1, con 4 dígitos (`0001` si no hay ninguna). Nunca sobrescribe una carpeta existente.
4. **Redacta una versión 1** (en memoria) rellenando la plantilla. Cada hueco o elección no trivial se convierte en una pregunta abierta `P1…Pn`.
5. **La revisa** con un checklist: EARS + prioridad en cada RF, al menos un criterio Dado/Cuando/Entonces por RF, métrica y umbral numérico en cada RNF, trazabilidad sin huecos, sin términos vagos, respeto a las convenciones del repo, sin contradicciones con specs previas y no objetivos explícitos.
6. **Resuelve cada pregunta** con esta prioridad: petición del usuario → documentación del repo → specs anteriores → buenas prácticas. Lo que solo se apoya en buenas prácticas queda como **Supuesto, confianza baja**.
7. **Construye la versión 2:** integra las decisiones con su referencia `(ver Dn)`, quita la sección de preguntas abiertas y los comentarios de guía, y pone `estado: Propuesta`, `version: 2`.
8. **Guarda** `spec.md` (versión 2) y `decisions.md` (una entrada `Dn` por cada `Pn`). La versión 1 no se guarda.
9. **Responde** con la ruta, el número de decisiones, las de confianza baja y los solapamientos.

Si no existen `CLAUDE.md` ni `AGENTS.md`, sigue igualmente y lo anota en "Contexto consultado" de `decisions.md`. Si la petición se solapa con otra spec, la enlaza en `specs_relacionadas` sin fusionarlas.

## La plantilla de spec

| # | Sección | Qué contiene |
|---|---------|--------------|
| — | Frontmatter | `id`, `titulo` (imperativo), `estado`, `version`, `fecha`, `specs_relacionadas` |
| 1 | Resumen | Qué, para quién y qué resultado, en 2-3 frases |
| 2 | Contexto y problema | Situación actual y por qué ahora, citando la documentación del repo |
| 3 | Objetivos y no objetivos | `O-01…` verificables y lo que queda fuera explícitamente |
| 4 | Usuarios y escenarios | Actores e historias "Como… quiero… para…" |
| 5 | Requisitos funcionales | `RF-nn` en formato EARS con prioridad MoSCoW |
| 6 | Requisitos no funcionales | `RNF-nn` con categoría, métrica y umbral numérico |
| 7 | Criterios de aceptación | `CA-nn` en Gherkin (Dado/Cuando/Entonces), al menos uno por RF |
| 8 | Diseño propuesto | Visión general, componentes con rutas reales, modelo de datos, interfaces y flujo principal |
| 9 | Casos límite y errores | Caso → comportamiento → requisito |
| 10 | Dependencias y supuestos | Técnicas, de equipos o de otras specs |
| 11 | Riesgos | Probabilidad, impacto y mitigación |
| 12 | Plan de implementación | Tareas `T-nn` pequeñas, con el RF que cubren y cómo se verifican |
| 13 | Estrategia de pruebas | Qué se prueba en cada nivel y qué CA cubre |
| 14 | Matriz de trazabilidad | RF → CA → tareas → tests |
| 15 | Preguntas abiertas | Solo en la versión 1; no aparece en `spec.md` |
| 16 | Decisiones | "Ver decisions.md" y la lista `D1…Dn` |

`decisions.md` registra, por cada decisión: pregunta original, alternativas, decisión, justificación, fuente (documento y sección, o "Supuesto"), confianza (alta/media/baja) y secciones afectadas. Al final, en "Contexto consultado", lista los ficheros leídos, los esperados que no existían y las specs revisadas.

Para cambiar el formato, edita los ficheros de `templates/`: el subagente los lee en cada ejecución.

## Requisitos

- Claude Code con soporte de plugins y de `${CLAUDE_PLUGIN_ROOT}` en comandos (probado en 2.1.280).
- Permisos que pedirá Claude Code:
  - **Leer las plantillas del plugin.** Están fuera del repositorio, así que la primera vez aparece una petición de lectura sobre `.../sdd-spec-writer/templates/`. Si la deniegas, el agente se detiene sin inventar las plantillas. Para no volver a verla, añade a `.claude/settings.json` o `~/.claude/settings.json`:
    ```json
    { "permissions": { "allow": ["Read(~/.claude/plugins/**)"] } }
    ```
    Con `--plugin-dir`, usa la ruta absoluta de la carpeta `templates/`, p. ej. `Read(//c/ruta/sdd-spec-writer/templates/**)`.
  - **Escribir** `docs/specs/NNNN/spec.md` y `decisions.md`.
