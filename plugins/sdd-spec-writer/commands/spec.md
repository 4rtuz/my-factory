---
description: Genera una spec SDD (docs/specs/NNNN/spec.md + decisions.md) a partir de una petición
argument-hint: <qué quieres construir>
---

Delega esta tarea en el subagente `sdd-spec-writer:spec-writer` mediante la herramienta Agent. No redactes la spec tú mismo ni leas las plantillas: el subagente se encarga de todo.

Pásale como prompt exactamente esto:

```
Petición del usuario:
$ARGUMENTS

Plantilla de spec: ${CLAUDE_PLUGIN_ROOT}/templates/spec-template.md
Plantilla de decisiones: ${CLAUDE_PLUGIN_ROOT}/templates/decisions-template.md
```

Cuando el subagente termine, muestra su respuesta al usuario sin resumirla. Si pide una descripción de lo que se quiere construir, transmite la pregunta y no generes nada.
