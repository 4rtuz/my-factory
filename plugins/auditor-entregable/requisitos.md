# Requisitos del examen final · Harness Engineering

Checklist derivado del enunciado. Cada fila es un requisito verificable; la columna **Evidencia** dice qué debe existir en el repo para darlo por cumplido. Un requisito sin evidencia en el repo no se cumple, aunque «el código lo haga».

Tipos:
- **S** — especificable: si falta, se pide una spec a `/sdd-spec-writer:sdd`.
- **M** — manual: lo hace una persona (grabar, presentar, enviar, revisar). Se informa, no se especifica.

El contexto del producto: novelas personalizadas para regalo (hijo, pareja, boda, aniversario, jubilación). Dos objetivos igual de importantes: **personalización** natural de los datos del destinatario y **calidad narrativa mínima** (sin inconsistencias de personajes, saltos temporales sin sentido, contradicciones entre capítulos, prosa mecánica o repetitiva, finales abruptos). Validadores, editor y LLM-as-judge deben reflejar ese equilibrio. Novelas de 10 capítulos de 1.000–1.500 palabras.

## CFG · Configuración

| ID | T | Requisito | Evidencia |
|---|---|---|---|
| CFG-01 | S | Agente entrevistador que recoge nombre, edad, rasgos, recuerdos, género, tono, extensión y palabras/temas prohibidos | Definición del agente/rol + código que lo invoca |
| CFG-02 | S | Detecta datos que faltan | Código + test |
| CFG-03 | S | Detecta al menos un tipo de contradicción (p. ej. edad vs. género o tono) | Código + test con un caso contradictorio |
| CFG-04 | S | Texto libre pegado (anécdota, carta) del que se extraen hechos, tratado como contenido no confiable | Código de extracción + delimitación/aislamiento del texto + test de injection |
| CFG-05 | S | Resultado: brief estructurado validado con schema | Modelo/schema del brief + test de validación |

## LEC · Lectura interactiva (web o PDF)

| ID | T | Requisito | Evidencia |
|---|---|---|---|
| LEC-01 | S | Entrega como web o PDF interactivo (decisión documentada) | Código del lector/exportador + trade-off en /docs |
| LEC-02 | S | Índice de capítulos navegable | Código + test o captura |
| LEC-03 | S | Ficha de personajes y lugares generada desde la story bible, con enlaces al capítulo donde aparece cada uno | Código que la genera desde SQLite + test |
| LEC-04 | S | Portada con dedicatoria personalizada | Código + test |
| LEC-05 | S | Web: el lector selecciona un fragmento o hecho y pide un cambio desde la página. PDF: el cambio se pide por formulario o CLI | Endpoint/subcomando + UI o CLI |
| LEC-06 | S | El sistema identifica los capítulos que usan ese hecho y regenera solo esos sin romper la continuidad | Consulta hecho→capítulos en SQLite + regeneración selectiva + test |
| LEC-07 | S | Web: marca qué capítulos cambiaron respecto a la versión anterior. PDF: nueva versión con página inicial de «novedades» y enlaces internos a cada capítulo modificado | Código + test |
| LEC-08 | S | Se conserva siempre la versión anterior de la novela | Versionado en disco/SQLite + test |

## HAR · Harness

| ID | T | Requisito | Evidencia |
|---|---|---|---|
| HAR-01 | S | Al menos tres roles: planner, writer y editor/critic | Definiciones de agentes |
| HAR-02 | S | CLAUDE.md como archivo de instrucciones del harness | `CLAUDE.md` en la raíz |
| HAR-03 | S | Una skill reutilizable | `.claude/skills/*/SKILL.md` o plugin |
| HAR-04 | S | Hook de validación del capítulo | Hook en `.claude/settings.json` + script |
| HAR-05 | S | Hook de policy | Hook en `.claude/settings.json` + script |
| HAR-06 | S | Tools con schema validado | Schemas + validación en código + test |
| HAR-07 | S | Retries con límite | Código/comando con contador y tope + test |
| HAR-08 | S | Registro de tokens y coste por novela en Langfuse | Ver OBS |

## MEM · Memoria

| ID | T | Requisito | Evidencia |
|---|---|---|---|
| MEM-01 | S | Story bible en SQLite donde cada hecho registra en qué capítulos se usa | Esquema SQLite con relación hecho↔capítulo |
| MEM-02 | S | Tabla de cronología (eventos, momento, personajes, lugar) que alimenta el validador formal | Tabla + generador Lean que la lee |
| MEM-03 | S | Resúmenes por capítulo para construir el contexto de los siguientes | Código de resumen + uso en el briefing |
| MEM-04 | S | Checkpoint por capítulo: si falla, se reanuda desde el último capítulo completado | Código + test de reanudación |

## VP · Validadores programáticos (mínimo tres)

Todo validador tiene nombre, punto de ejecución concreto (hook, rol editor o gate antes de publicar) y envía su resultado a Langfuse como score.

| ID | T | Requisito | Evidencia |
|---|---|---|---|
| VP-01 | S | Brief y salida de cada rol cumplen su schema | Validador + test |
| VP-02 | S | Nombre del destinatario y personajes escritos exactamente como en la story bible | Validador + test |
| VP-03 | S | Longitud de cada capítulo dentro del rango | Validador + test |
| VP-04 | S | Cada elemento personalizado obligatorio del brief aparece en al menos un capítulo, comprobado contra la tabla de hechos de SQLite | Validador + test |
| VP-05 | S | Guardrail de palabras prohibidas (ver GRD) | Validador + test |
| VP-06 | S | Validación visual con browser MCP: abre la novela, navega capítulos, verifica índice, ficha y portada; un error visual se registra como fallo y vuelve al writer o al rol correspondiente | Procedimiento/agente + registro del resultado |
| VP-07 | S | Cada validador: nombre, punto de ejecución y score en Langfuse | Tabla de validadores en /docs + código de emisión del score |

## VS · Validadores semánticos (mínimo dos)

| ID | T | Requisito | Evidencia |
|---|---|---|---|
| VS-01 | S | LLM-as-judge con rúbrica: continuidad, tono, calidad narrativa (arco, coherencia de personajes, ritmo) y personalización natural y no forzada; puntuación y justificación por criterio | Rúbrica versionada + agente/juez + salida con schema |
| VS-02 | S | Procedimiento y plantilla de revisión humana con la misma rúbrica | Plantilla en /docs |
| VS-03 | M | Revisión humana de al menos una novela completa, comparada con el juicio del LLM | Resultado de la revisión en /docs |

## LEAN · Validador formal de la historia (Lean 4)

| ID | T | Requisito | Evidencia |
|---|---|---|---|
| LEAN-01 | S | Generador SQLite → fichero Lean con hechos temporales: eventos, momento, personajes presentes, lugar, fechas de nacimiento | Código + test |
| LEAN-02 | S | Al menos dos invariantes en Lean (orden temporal, edad coherente con nacimiento, no estar en dos lugares a la vez, no aparecer tras un evento que lo excluye…) | Ficheros `.lean` |
| LEAN-03 | S | Verificación automática (`lake build` o `lean`); si falla, la versión no se publica y el fallo vuelve al editor como feedback | Gate en el código + test |
| LEAN-04 | S | Un caso real en que Lean detecta una incoherencia que los otros validadores no detectaron, o justificación de por qué no se encontró | Documento en /docs |

## TLA · Validador formal del sistema (TLA+)

| ID | T | Requisito | Evidencia |
|---|---|---|---|
| TLA-01 | S | Spec TLA+ o PlusCal del flujo: configuración → planificación → escritura → validación → publicación, con retries, reanudación desde checkpoint y regeneración por cambio del lector | Fichero `.tla` |
| TLA-02 | S | Al menos tres invariantes de seguridad (nunca publicar un capítulo sin pasar todos los validadores; la reanudación no duplica ni pierde capítulos; la versión anterior se conserva; reintentos ≤ límite…) | Fichero `.tla` |
| TLA-03 | S | Al menos una propiedad de liveness: toda generación termina publicando o deteniéndose con error | Fichero `.tla` |
| TLA-04 | S | TLC sobre un modelo pequeño (p. ej. 5 capítulos, 2 reintentos) con la configuración en el repo | Fichero `.cfg` + cómo ejecutarlo |
| TLA-05 | S | README que mapea cada acción de la spec al estado o transición del código que la implementa | Sección del README |
| TLA-06 | S | Contraejemplos de TLC durante el desarrollo documentados con el cambio que provocaron en el código | Registro en /docs |

## EVAL · Evaluación del sistema

| ID | T | Requisito | Evidencia |
|---|---|---|---|
| EVAL-01 | S | Cinco briefs de prueba, al menos uno adversarial (injection en texto libre) y uno que provoque una incoherencia temporal | Ficheros de briefs |
| EVAL-02 | S | Tabla por brief de qué validadores pasaron y cuáles fallaron, con números | Tabla en /docs |
| EVAL-03 | S | Una iteración de tuning documentada con resultados antes y después (y versión de prompt de cada uno) | Documento en /docs |

## OBS · Observabilidad (Langfuse)

| ID | T | Requisito | Evidencia |
|---|---|---|---|
| OBS-01 | S | Cada generación es una traza, agrupada por sesión: una sesión por novela, incluyendo entrevista y regeneraciones | Código/config de trazado |
| OBS-02 | S | Cada rol (entrevistador, planner, writer, editor) y cada llamada a tool es un span con nombre identificable | Código/config |
| OBS-03 | S | Tokens, coste y latencia visibles por llamada, por capítulo y por novela | Código/config + captura |
| OBS-04 | S | Resultados de todos los validadores (programáticos, semánticos y Lean) como scores de la traza. TLC solo en desarrollo | Código de emisión |
| OBS-05 | S | Prompts versionados en Langfuse, de forma que el tuning muestre qué versión produjo cada resultado | Código/config + referencia en EVAL-03 |

## GRD · Guardrails

| ID | T | Requisito | Evidencia |
|---|---|---|---|
| GRD-01 | S | Guardrail de palabras prohibidas aplicado en código sobre cada capítulo antes de aceptarlo | Código en el camino de aceptación |
| GRD-02 | S | Listas en SQLite en niveles: globales (insultos, ofensivos) y por novela, definidas por el cliente en la configuración | Esquema SQLite |
| GRD-03 | S | Normaliza antes de comparar: mayúsculas, acentos, plurales y variantes simples | Código |
| GRD-04 | S | Coincidencia → el capítulo vuelve al writer, con límite de intentos; agotado, la generación se detiene y se informa | Código + test |
| GRD-05 | S | Cada coincidencia queda en el audit log y en Langfuse | Código |
| GRD-06 | S | Tests con al menos un caso por nivel y uno de variante (acento o plural) | Tests |
| GRD-07 | S | Audit log de las decisiones del policy engine | Tabla/fichero de audit log |
| GRD-08 | S | Máximo de 100.000 tokens concurrentes | Límite aplicado en código o config + documentado |

## ENT · Entregables del repositorio

| ID | T | Requisito | Evidencia |
|---|---|---|---|
| ENT-01 | S | README con brief de ejemplo reproducible | `README.md` en la raíz |
| ENT-02 | S | `.env.example` sin secretos | `.env.example` |
| ENT-03 | S | Sin API keys en ningún fichero versionado ni en el historial | Escaneo del historial |
| ENT-04 | M | Novela de ejemplo completa de 10 capítulos generada con el brief del README | `ejemplos/novela-ejemplo.pdf` |
| ENT-05 | M | Repositorio MyFactory con las herramientas del curso | Repo accesible |
| ENT-06 | M | Entrega por email con links a los commits finales de ambos repos y la frase de diseño | Fuera del repo |

## DOC · Documentación de proceso en /docs

| ID | T | Requisito | Evidencia |
|---|---|---|---|
| DOC-01 | S | Spec inicial: qué se decidió construir y por qué, antes del código | Documento en /docs |
| DOC-02 | S | Trade-offs como decisiones (opciones, criterios, elección): single vs multi-agent, formato de la story bible, modelo de lectura, integración TLA+, invariantes Lean priorizados… | Documentos/ADR en /docs |
| DOC-03 | S | Un explainer breve por cada concepto del curso aplicado | Documentos en /docs |
| DOC-04 | S | Diagramas: arquitectura del harness, máquina de estados TLA+, esquema SQLite, tabla de validadores con punto de ejecución | Diagramas en /docs |
| DOC-05 | S | Registro de iteraciones: qué cambió tras cada eval o contraejemplo de TLC/Lean y por qué (causa → efecto) | Documento en /docs |
| DOC-06 | S | Red-team log: casos adversariales, qué validador los detectó o no, cómo se resolvió | Documento en /docs |

## CC · Uso de Claude Code

| ID | T | Requisito | Evidencia |
|---|---|---|---|
| CC-01 | S | `CLAUDE.md` en la raíz cuidado y legible | `CLAUDE.md` |
| CC-02 | S | Carpeta `.claude/` con memoria y comandos propios commiteada | `git ls-files .claude` |
| CC-03 | S | Configuración MCP (`.mcp.json` o equivalente) con un servidor de inspección de browser (Chrome MCP, Playwright MCP…) | Fichero versionado |
| CC-04 | S | Uso real del browser MCP documentado: qué inspeccionó, qué detectó y qué cambio provocó | Documento en /docs |
| CC-05 | S | Skills usadas o creadas en el repo y referenciadas desde /docs | Ficheros + referencias |
| CC-06 | S | Subagentes y comandos propios documentados con propósito y resultado | Documento en /docs |

## PRE · Presentación (/presentacion)

| ID | T | Requisito | Evidencia |
|---|---|---|---|
| PRE-01 | M | Deck principal en PDF y en formato editable | Ficheros en `presentacion/` |
| PRE-02 | M | Anexos como ficheros individuales con nombre descriptivo | Ficheros en `presentacion/` |
| PRE-03 | S | `presentacion/README.md` que lista el contenido y el idioma | Fichero |
| PRE-04 | M | Imagen corporativa propia (nombre, logo, paleta, tipografía) consistente | Deck |
| PRE-05 | M | Portada: empresa presentadora, cliente ficticio, fecha, estudiante. Contraportada con contacto | Deck |
| PRE-06 | M | Bloques de 10 min: contexto, problema, configuración y lectura, arquitectura, validación/evals/observabilidad, guardrails, presupuesto, demo y cierre | Deck |
| PRE-07 | S | Datos de la slide de presupuesto: coste de tokens por novela medido en Langfuse, infraestructura, margen, precio, horas × tarifa del desarrollo, tres escenarios de volumen, sensibilidad (+50 % tokens, >3 revisiones) | Script o documento que extrae los costes de Langfuse y calcula la tabla |
| PRE-08 | M | Evidencias en el deck: tabla de evals con números, coste real y margen, demo de un cambio del lector propagado | Deck |
| PRE-09 | M | Vídeo de demo en `presentacion/` o enlazado desde su README | Fichero o enlace |
| PRE-10 | M | Presentación commiteada antes del plazo del repo | Historial git |

## OPT · Opcional (solo con `--opcionales`)

| ID | T | Requisito | Evidencia |
|---|---|---|---|
| OPT-01 | S | Servidor MCP de solo lectura (FastMCP sobre FastAPI) con `list_novels`, `get_chapter`, `list_versions`, `query_story_bible`, `download_novel`; schemas validados, llamadas en Langfuse, README de conexión | Código + tests |
| OPT-02 | S | Tools de escritura MCP (cambio del lector) con permisos y confirmación | Código + tests |
| OPT-03 | S | Linters de prosa: repeticiones, legibilidad, clichés o expresiones de IA, consistencia de estilo | Código + tests |
| OPT-04 | S | Linter para edición manual (web, VS Code o LSP) contra story bible y palabras prohibidas; la edición que cambia un hecho actualiza la bible y repasa validadores y Lean | Código + tests |
| OPT-05 | S | Invariantes Lean adicionales o demostraciones generales | Ficheros `.lean` |
| OPT-06 | S | TLA+ del servidor MCP o de regeneraciones concurrentes | Fichero `.tla` + `.cfg` |
| OPT-07 | S | Login con SQLite (bcrypt, JWT), propiedad por usuario de novelas, config y audit log; tests de aislamiento entre usuarios | Código + tests |
| OPT-08 | S | Agente o skill de seguridad: injection, exfiltración, dependencias (`pip audit`/`npm audit`), secretos en el historial; informe en `docs/security-report.md` con severidad y resolución | Agente/skill + informe |
