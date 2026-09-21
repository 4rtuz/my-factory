---
name: verification-plan
description: Genera o actualiza un verification.md que recorre las 18 tecnicas de verificacion (type checking, SAST, ejecucion simbolica, verificacion formal, tests unitarios e integracion, property-based, mutation, contract testing, observabilidad, evals, sandboxing, guardrails, human-in-the-loop, verificacion multi-agente, CI/CD, rollout progresivo, red-teaming, model checking) y clasifica cada una con el marco TAIDU del Trust Spec (Test, Analysis, Inspection, Demonstration, Unverifiable). Usala cuando el usuario pida un plan o documento de verificacion, pregunte como verificar que el codigo o la salida de un agente es correcta, hable de assurance, cobertura de verificacion, TAIDU o Trust Spec, o pida auditar que garantias tiene un repositorio.
---

# Plan de verificación (verification.md)

Objetivo: un documento donde **cada una de las 18 técnicas aparece**, aplicada o descartada, y ninguna garantía queda como supuesto silencioso.

Regla central: *no aplicar una técnica es una decisión, no una omisión*. Toda técnica que no se use se clasifica como **U** con motivo y coste evitado.

## Paso 1 — Reconocer el proyecto

Antes de escribir nada, determina con Glob/Grep/Read:

- Lenguajes y gestor de dependencias (`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `pom.xml`).
- Herramientas ya presentes: linters, type checkers, framework de tests, CI (`.github/workflows`, `.gitlab-ci.yml`), feature flags.
- **Si hay código de agente/LLM** (llamadas a un modelo, definiciones de tools, prompts, MCP): el bloque B es obligatorio. Si no lo hay, el bloque B se rellena entero como `U — no aplica (no hay agente)` en una sola línea por técnica, sin inventar evals.

No propongas herramientas que el proyecto no usa sin decir que son una incorporación nueva.

## Paso 2 — Recorrer el catálogo

### Bloque A — ¿Es correcto el código?

| # | Técnica | Qué garantiza | TAIDU | Herramienta típica |
|---|---------|---------------|-------|--------------------|
| A1 | Type checking | Los valores se usan como las operaciones esperan (nunca un string donde se exige un número) | A | tsc, mypy/pyright, compilador |
| A2 | Análisis estático / SAST | Patrones conocidos como malos: vulnerabilidades, code smells, antipatrones, sin ejecutar | A | semgrep, CodeQL, bandit, eslint |
| A3 | Ejecución simbólica | Con entradas simbólicas y un solver SMT, las condiciones exactas y el contraejemplo concreto que rompe el código | A | KLEE, crosshair, Z3 |
| A4 | Verificación formal / demostración | Prueba matemática de que el código cumple una especificación para **toda** entrada | A | TLA+, Dafny, Coq, Lean |
| A5 | Tests unitarios / integración | Comportamiento frente a entradas de ejemplo elegidas y su salida esperada | T | vitest/jest, pytest, go test |
| A6 | Property-based testing | Una propiedad general se mantiene sobre muchas entradas generadas automáticamente | T | hypothesis, fast-check, proptest |
| A7 | Mutation testing | Que la suite existente **detecta** bugs pequeños introducidos a propósito | T | stryker, mutmut, cargo-mutants |
| A8 | Contract testing | Que la interfaz (forma de request/response) entre dos servicios sigue siendo compatible | T | Pact, OpenAPI/schemathesis |

### Bloque B — ¿Se comporta el agente de forma fiable?

| # | Técnica | Qué garantiza | TAIDU | Herramienta típica |
|---|---------|---------------|-------|--------------------|
| B1 | Observabilidad / tracing en runtime | La trayectoria real (tool calls, tokens, latencia, errores) queda visible y consultable a posteriori | D | OpenTelemetry, Langfuse, Braintrust |
| B2 | Evals | Comportamiento medido contra un dataset y un método de scoring: golden dataset, LLM-as-judge, task completion, adversarial, online | T | suite de evals propia, promptfoo |
| B3 | Ejecución en sandbox | Una acción mala falla de forma segura en un entorno aislado en vez de llegar a producción | D | contenedor, microVM, worktree |
| B4 | Guardrails | Políticas o filtros que limitan qué acciones y salidas puede producir el agente **antes** de actuar | A | allowlists de permisos, hooks, filtros de salida |
| B5 | Revisión humana (human-in-the-loop) | Una persona aprueba, rechaza o edita las acciones de alta consecuencia, y la decisión retroalimenta | I | aprobación de permisos, review de PR |
| B6 | Verificación multi-agente | Un segundo modelo revisa al primero: crítico/verificador, self-consistency, debate, reflexión, ensembles | I | subagente revisor, majority vote |
| B7 | Integración CI/CD | Los cambios generados por el agente pasan por el mismo pipeline, tests y review que los humanos, con marca de procedencia | T | GitHub Actions, trailers de commit |
| B8 | Rollout progresivo | El cambio sale tras un feature flag a un porcentaje pequeño de tráfico, vigilado antes del 100% | D | flags, canary deploy |
| B9 | Red-teaming / adversarial | Fallos bajo modelo de amenaza: prompt injection, cadenas de mal uso de tools, deriva de objetivo, exfiltración | T | suite adversarial, ejercicios manuales |
| B10 | Model checking | Exploración exhaustiva de estados y transiciones alcanzables para verificar invariantes ("nunca borrar antes de hacer backup") | A | TLA+/TLC, SPIN |

### Clasificación TAIDU

| Letra | Significado | Se verifica |
|-------|-------------|-------------|
| T | Test | Ejecutando el sistema con entradas concretas |
| A | Analysis | Razonamiento estático: tipos, SAST, ejecución simbólica, prueba formal |
| I | Inspection | Una persona o un modelo crítico lo lee y lo juzga |
| D | Demonstration | Observando operación correcta en un escenario realista (staging, sandbox) |
| U | Unverifiable / riesgo aceptado | Ningún método aplica o no compensa su coste; se nombra en vez de asumirlo en silencio |

La letra de las tablas es el valor por defecto. Cámbiala si en este proyecto la técnica se usa de otra forma, y explica por qué.

## Paso 3 — Escribir verification.md

En la raíz del proyecto, salvo que el usuario indique otra ruta. Si ya existe, actualízalo respetando lo que el usuario escribió a mano; no lo reescribas entero.

```markdown
# Verificación

<Qué es este proyecto y qué se compromete a garantizar. 3-5 líneas.>

## Cobertura

| # | Técnica | TAIDU | Estado | Cómo | Dónde |
|---|---------|-------|--------|------|-------|
| A1 | Type checking | A | Activo | `npm run typecheck` | tsconfig.json |
| A3 | Ejecución simbólica | U | Riesgo aceptado | — | Coste desproporcionado: sin aritmética crítica |

`Estado` ∈ Activo / Parcial / Pendiente / Riesgo aceptado.

## Qué se verifica y cómo

<Una subsección por técnica activa o parcial: comando exacto que la ejecuta, qué fallo detecta, qué no detecta.>

## Riesgos aceptados

<Una entrada por cada U: qué queda sin verificar, por qué se acepta, qué lo cambiaría.>

## Huecos pendientes

<Técnicas en Pendiente, ordenadas por riesgo cubierto / coste de implantación.>
```

## Reglas

- **18 filas siempre.** Una técnica ausente de la tabla de cobertura es un fallo del documento.
- Cada estado `Activo` lleva un comando o ruta reales, verificados en el repo. Si no puedes ejecutarlo o localizarlo, es `Pendiente`, no `Activo`.
- Cada `Riesgo aceptado` lleva motivo. «No aplica» a secas no vale: di por qué no aplica.
- No añadas herramientas al proyecto en esta tarea. El documento propone; instalar es una petición aparte.
- No inventes métricas de cobertura ni porcentajes que no hayas medido.
