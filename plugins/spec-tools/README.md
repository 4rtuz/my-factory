# Spec Tools

Plugin de Claude Code con el subagente `spec-planner`: recibe una spec en Markdown de `docs/specs/`, la analiza junto con el código real del repositorio y escribe un plan de implementación trazable en `docs/implementation-plans/`. Planifica; nunca implementa.

El plan incluye alcance, análisis del código existente con rutas, decisiones de diseño, fases y tareas (con archivos, requisitos cubiertos, dependencias, criterio de "hecho" y complejidad), estrategia de testing, matriz de trazabilidad requisito → tarea, riesgos y preguntas abiertas.

El agente solo tiene `Read`, `Grep`, `Glob` y `Write`: no ejecuta comandos ni edita código, y solo escribe dentro de `docs/implementation-plans/`. Nunca sobrescribe un plan existente: guarda `<nombre>-v2.md`, `-v3`…

Encaja con [`sdd-spec-writer`](../sdd-spec-writer/): una spec `docs/specs/0002/spec.md` genera `docs/implementation-plans/0002.md`.

## Instalación

Desde el marketplace `my-factory`:

```
/plugin marketplace add 4rtuz/my-factory
/plugin install spec-tools@my-factory
```

Para probarlo en local sin instalar:

```
claude --plugin-dir /ruta/a/my-factory/plugins/spec-tools
```

Comprueba que carga con `/agents` (debe aparecer `spec-tools:spec-planner`).

## Uso

Claude lo delega automáticamente cuando pides planificar una spec. Desde la raíz del repositorio:

```
Planifica la spec docs/specs/exportar-csv.md
```

O invocándolo explícitamente:

```
@spec-tools:spec-planner docs/specs/0002/spec.md
```

Sin ruta, el agente lista las specs que aún no tienen plan y pregunta cuál procesar.

Respuesta típica:

```
Plan guardado en docs/implementation-plans/exportar-csv.md
3 fases, 8 tareas
Preguntas abiertas bloqueantes:
- P1 — ¿El CSV incluye movimientos anulados?
```
