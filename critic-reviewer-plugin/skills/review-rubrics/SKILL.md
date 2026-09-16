---
name: review-rubrics
description: Rúbricas de crítica por tipo de contenido (libro, paper científico, repositorio de código, proyecto general). Enruta hacia la rúbrica correcta y define las dimensiones obligatorias, la evidencia exigible y las herramientas permitidas en cada caso. Úsala al revisar, criticar o evaluar cualquier material sin modificarlo.
---

# Rúbricas de revisión crítica

Router de rúbricas para el agente `critic-reviewer`. Una revisión = un tipo = una rúbrica.

## Paso 1 — Confirmar el tipo detectado

| Tipo | Señales | Rúbrica a cargar |
|------|---------|------------------|
| `libro` | Prosa continua, capítulos, ficción o ensayo/divulgación, sin aparato metodológico | [references/libros.md](references/libros.md) |
| `paper` | Abstract, método/resultados/discusión, bibliografía, DOI/arXiv, figuras y tablas numeradas | [references/papers.md](references/papers.md) |
| `codigo` | Repositorio o ficheros fuente, manifiesto de dependencias, tests, CI | [references/codigo-repositorios.md](references/codigo-repositorios.md) |
| `proyecto` | Propuesta, plan, roadmap, business case, spec de producto, presupuesto, OKRs | [references/proyectos-generales.md](references/proyectos-generales.md) |

**Lee un único fichero de referencia**, el de la fila que corresponda. Leer varios mezcla rúbricas y rompe la revisión.

Si el material encaja en dos filas (un repo que acompaña a un paper, un ensayo que también es una propuesta), **pregunta al usuario cuál es el eje de la revisión antes de cargar nada**. Si pide ambos, haz dos revisiones separadas, cada una con su rúbrica, y no cruces las conclusiones.

## Paso 2 — Herramientas permitidas según el tipo

| Tipo | Read/Glob/Grep | Bash (solo lectura + tests existentes) | WebSearch / WebFetch |
|------|----------------|----------------------------------------|----------------------|
| `libro` | Sí | No | No |
| `paper` | Sí | No | Sí (verificar citas y literatura relacionada) |
| `codigo` | Sí | Sí | Solo documentación de dependencias citadas en el material |
| `proyecto` | Sí | Sí | Solo documentación de dependencias o tecnologías citadas en el material |

Nunca hay herramientas de escritura. Esta tabla es idéntica a la del system prompt del agente; si alguna vez divergen, manda la más restrictiva.

## Paso 3 — Reglas comunes a todas las rúbricas

- Cubre **todas** las dimensiones del fichero de referencia. Si una no aplica al material, dilo y justifica por qué; no la omitas en silencio.
- Fortalezas y debilidades con el mismo peso, el mismo detalle y la misma exigencia de evidencia.
- Cada afirmación lleva evidencia localizable (cita corta, página, sección, `fichero:línea`). Sin evidencia: se convierte en pregunta abierta o se descarta.
- Formato de salida fijo: resumen → fortalezas → debilidades → ambigüedades y preguntas abiertas → recomendaciones priorizadas → valoración global en texto.
- Sin escalas numéricas inventadas. Si el usuario pide una nota, define la escala antes de aplicarla.
- La revisión termina cuando están cubiertas todas las dimensiones y no queda ninguna afirmación sin respaldo.
