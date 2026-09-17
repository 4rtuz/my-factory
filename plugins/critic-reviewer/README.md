# Critic Reviewer

Plugin de Claude Code con un agente crítico-revisor genérico. Revisa **libros, papers científicos, repositorios de código y proyectos**, detectando primero el tipo de contenido y aplicando después la rúbrica que corresponde, sin mezclarlas.

El agente **critica, no corrige**: no tiene herramientas de escritura.

## Contenido

```
critic-reviewer-plugin/
├── .claude-plugin/plugin.json          manifiesto
├── agents/critic-reviewer.md           subagente
└── skills/review-rubrics/
    ├── SKILL.md                        router: tipo -> rúbrica
    └── references/
        ├── libros.md
        ├── papers.md
        ├── codigo-repositorios.md
        └── proyectos-generales.md
```

## Instalación

Desde un marketplace o repositorio git:

```
/plugin marketplace add <owner>/<repo>
/plugin install critic-reviewer@<marketplace>
```

Para desarrollo local, añade el directorio que contiene el plugin como marketplace local, o clónalo dentro de la carpeta de plugins de Claude Code y reinicia la sesión. Comprueba la instalación con `/plugin`: el agente debe aparecer como `critic-reviewer:critic-reviewer` y la skill como `critic-reviewer:review-rubrics`.

## Uso

Invocación explícita:

```
@critic-reviewer:critic-reviewer revisa el repositorio en ./src
@critic-reviewer:critic-reviewer critica este paper: paper.pdf
```

O deja que Claude lo delegue: «revisa críticamente este manuscrito», «audita este proyecto».

El agente empieza declarando el tipo detectado. Si el material es ambiguo (un repo que acompaña a un paper, un ensayo que también es una propuesta), preguntará cuál es el eje de la revisión antes de continuar.

## Salida

Cada revisión sigue siempre este orden:

1. Resumen del objeto revisado y alcance
2. Fortalezas, con evidencia
3. Debilidades, con evidencia
4. Ambigüedades y preguntas abiertas
5. Recomendaciones priorizadas
6. Valoración global en texto

Tono equilibrado: fortalezas y debilidades reciben el mismo peso y la misma exigencia de evidencia (cita corta, página, sección o `fichero:línea`). Sin puntuaciones numéricas salvo que las pidas.

## Herramientas según el tipo de contenido

| Tipo | Lectura local | Bash (solo lectura + tests existentes) | Web |
|------|---------------|----------------------------------------|-----|
| Libro | Sí | No | No |
| Paper | Sí | No | Sí, para verificar citas y literatura relacionada |
| Código | Sí | Sí | Solo documentación de dependencias citadas |
| Proyecto | Sí | Sí | Solo documentación de dependencias citadas |

Ninguno de los cuatro tipos permite escritura: `Write`, `Edit` y `NotebookEdit` están bloqueados en el manifiesto del agente. Si quieres que se apliquen las recomendaciones, es una tarea aparte que debes pedir explícitamente al agente principal.

## Personalización

Las rúbricas viven en `skills/review-rubrics/references/`. Edita un fichero para ajustar las dimensiones de un tipo. Para añadir un tipo nuevo: crea su fichero de referencia, añade una fila en la tabla de enrutado de `SKILL.md` y otra en la tabla de detección de tipos del agente.
