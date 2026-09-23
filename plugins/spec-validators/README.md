# Spec Validators

Plugin de Claude Code con el subagente `spec-validator`. Lee una spec de `docs/specs/` y su plan de `docs/implementation-plans/` y escribe en `docs/validators.md` los puntos donde la solución puede fallar:

- **Validadores (VAL):** ¿se construye lo correcto? Salen de la spec.
- **Verificadores (VER):** ¿se construye bien? Salen de las decisiones técnicas del plan.

Cada sección trae también las discrepancias entre la spec y el plan, una matriz de cobertura requisito → VAL/VER (los requisitos sin cobertura aparecen como `SIN CUBRIR`) y las preguntas abiertas.

El agente solo tiene `Read`, `Glob`, `Grep`, `Write` y `Edit`. No ejecuta nada y solo escribe en `docs/validators.md`: si la sección de esa spec ya existe, la sustituye, y deja las demás como están.

Funciona con [`spec-tools`](../spec-tools/): una spec `docs/specs/0002/spec.md` o `docs/specs/0002.md` se empareja con el plan `docs/implementation-plans/0002.md`.

## Instalación

```
/plugin marketplace add 4rtuz/my-factory
/plugin install spec-validators@my-factory
```

Para probarlo en local:

```
claude --plugin-dir /ruta/a/my-factory/plugins/spec-validators
```

Después abre `/agents`: debería aparecer `spec-validators:spec-validator`.

## Uso

```
Valida la spec docs/specs/exportar-csv.md y busca sus puntos de fallo
```

o de forma explícita:

```
@agent-spec-validators:spec-validator exportar-csv
```

Si no indicas ninguna spec, el agente lista las de `docs/specs/` y te pide que elijas una. Si el plan no existe o hay más de un candidato, lo dice y termina sin escribir nada.

Respuesta típica:

```
docs/validators.md — sección exportar-csv actualizada
Validadores: 9 (2 críticos) · Verificadores: 6 (1 crítico)
Requisitos sin cobertura: R5
Discrepancias spec ↔ plan: 3 (1 sin cubrir, 1 sin requisito, 1 contradicción)
Preguntas abiertas: 2
```
