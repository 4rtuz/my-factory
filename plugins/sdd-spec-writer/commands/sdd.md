---
description: Pipeline SDD completo - de una petición vaga a spec, plan de implementación y validadores
argument-hint: <qué quieres construir, aunque sea vago>
---

Encadena tres subagentes mediante la herramienta Agent, uno detrás de otro: no lances un paso hasta que termine el anterior. No redactes ni leas los documentos tú mismo; cada subagente escribe los suyos.

Si un subagente no está disponible, di qué plugin falta (`/plugin install <plugin>@my-factory`) y detente.

## 1. Spec — `sdd-spec-writer:spec-writer`

Pásale como prompt exactamente esto:

```
Petición del usuario:
$ARGUMENTS

Plantilla de spec: ${CLAUDE_PLUGIN_ROOT}/templates/spec-template.md
Plantilla de decisiones: ${CLAUDE_PLUGIN_ROOT}/templates/decisions-template.md
```

Si su respuesta no empieza por `Spec creada en docs/specs/NNNN/` (p. ej. pide una descripción de qué se quiere construir), transmítela al usuario sin resumir y detente. Si empieza así, toma de ella `NNNN`.

## 2. Plan de implementación — `spec-tools:spec-planner`

Prompt: `Planifica la spec docs/specs/NNNN/spec.md`

Toma de su respuesta la ruta del plan guardado. Si no guardó ningún plan, transmite su respuesta y detente.

## 3. Validadores — `spec-validators:spec-validator`

Prompt: `Valida la spec docs/specs/NNNN/spec.md`

Si su respuesta no empieza por `docs/validators.md — sección NNNN actualizada` (p. ej. encontró varios planes candidatos), transmítela y detente.

## 4. Responder

Con los tres pasos terminados, responde con este formato, sin repetir los documentos:

```
Se han diseñado la spec, el plan de implementación y los validadores:
- Spec: docs/specs/NNNN/spec.md
- Plan de implementación: <ruta del paso 2>
- Validadores: docs/validators.md (sección NNNN)

Las decisiones tomadas para resolver las preguntas abiertas de la spec están en docs/specs/NNNN/decisions.md

Revisa:
- Decisiones con confianza baja: <del paso 1, o "Ninguna">
- Preguntas bloqueantes del plan: <del paso 2, o "Ninguna">
- Requisitos sin cobertura: <del paso 3, o "Ninguno">
```
