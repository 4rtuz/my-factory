# Cómo ahorrar tokens en Claude Code sin perder calidad (septiembre 2026)

**Lo que más ahorra no es ningún truco de compresión, sino gestionar el contexto (limpiarlo, aislarlo en subagentes y no romper la caché) y elegir el modelo y el esfuerzo según la tarea.** Las herramientas externas que prometen ahorros del 60‑90 % casi nunca mantienen esas cifras cuando se miden sobre la factura real.

## TL;DR

- **El contexto es el recurso que hay que gestionar.** Claude Code reenvía la conversación entera en cada turno, así que lo que más reduce el gasto es: `/clear` entre tareas, un CLAUDE.md corto (menos de 200 líneas), con los procedimientos movidos a skills, subagentes para lecturas, tests y logs voluminosos, y no romper la prompt cache (no cambiar de modelo ni de esfuerzo a mitad de tarea).
- **Elegir modelo y esfuerzo es la segunda palanca.** Sonnet como modelo por defecto, Opus/Fable solo para problemas difíciles, Haiku para subagentes mecánicos, `opusplan` cuando la sesión incluye mucha planificación, y bajar el esfuerzo en trabajo rutinario. Anthropic recomienda el esfuerzo por defecto para la mayoría de tareas y revisar el contexto antes de subir de modelo.
- **A las herramientas externas les suele faltar evidencia.** Los monitores (ccusage, Claude‑Code‑Usage‑Monitor) valen la pena y no tienen riesgo. Los compresores de salida tipo RTK no ahorraron nada en benchmarks independientes (JetBrains, 425 ejecuciones facturadas con Claude Code 2.1.201 y claude-sonnet-5: +7,6 % de coste con esfuerzo bajo, p=0,004; PointFive: −38,4 % de tokens de herramientas pero +6,8 % de factura). La navegación semántica (LSP, Serena, claude-context) ayuda en repos grandes y en refactors, pero en consultas simples puede costar más.

## Key Findings

1. **La prompt cache manda en la factura.** En el estudio de PointFive (arXiv 2607.12161, 2.848 ejecuciones pareadas analizadas de 2.908 facturadas en Claude Code), la creación y lectura de caché suponen ≈87 % del coste reconstruido y ≈80 % de la factura real, con un residuo no atribuido del 8,7 %. Dos consecuencias:
   - Comprimir la salida de herramientas actúa sobre una parte pequeña del gasto.
   - Romper la caché (cambiar de modelo, de esfuerzo, activar fast mode, conectar MCP no diferidos) sale muy caro.
2. **Una conversación larga cuesta en cada mensaje.** Según la documentación oficial, una pregunta de una línea en una sesión abierta todo el día consume uso por toda la conversación. Añade que el gasto inesperadamente alto suele venir de sesiones que nunca se limpiaron o de dejar Opus como modelo por defecto.
3. **Tool Search ya viene activado.** Las definiciones de herramientas MCP se cargan de forma diferida por defecto (solo nombres e instrucciones del servidor). En una instalación real, desactivarlo subió la primera petición de 20.819 a 60.989 tokens de entrada. Anthropic (blog de ingeniería, «Introducing advanced tool use», noviembre de 2025) midió una bajada de ~77K a ~8,7K tokens con más de 50 herramientas MCP, una reducción del 85 %.
4. **Las cifras que publican los propios autores de las herramientas no se sostienen.** Resultados de los benchmarks A/B pareados de JetBrains con Claude Code y Sonnet 5 en SkillsBench:

   | Herramienta | Promete | Medido | Calidad |
   |---|---|---|---|
   | Caveman | −65 % de tokens de salida | −8,5 % (86 tareas con la skill forzada: es el techo, no el caso típico) | sin cambios |
   | RTK | −60‑90 % | +7,6 % de coste con esfuerzo bajo (p=0,004); ±0 % con esfuerzo alto | sin cambios |
   | Ponytail | −54 % de código, −22 % de tokens, −20 % de coste | −10,3 % de coste, −15 % de código, −11 % de tiempo (80 tareas pareadas, p=0,004); el único ahorro estadísticamente sólido de la serie | — |

5. **Calidad y ahorro suelen ir juntos.** Un contexto limpio reduce el coste y además mejora el rendimiento, porque los LLM se degradan a medida que se llena la ventana (*context rot*). Lo que sí degrada la calidad es recortar contexto necesario: compactar sin instrucciones, usar filtros que ocultan la línea de error que importa o poner modelos pequeños en tareas ambiguas.

## Details

### 1. Funciones nativas de Claude Code

**Medir primero**
- **`/usage`** (sustituye a `/cost`):
  - Para usuarios de API muestra tokens y coste estimado de la sesión, con una línea *Prompt cache (main)*: porcentaje de entrada servido desde caché, fallos y causa probable.
  - En planes Pro/Max/Team/Enterprise muestra qué skills, subagentes, plugins y servidores MCP consumen tu cuota, y marca comportamientos que suponen ≥10 % del uso reciente (contexto largo, fallos de caché).
  - Úsalo como diagnóstico antes de optimizar nada.
- **`/context`**: muestra qué ocupa la ventana (system prompt, herramientas, CLAUDE.md, skills, conversación). Una **status line** puede mostrar el llenado del contexto de forma continua.
- **`/insights`**: genera un informe HTML sobre fricciones en tus sesiones recientes (peticiones malinterpretadas, código con errores). Sirve para corregir hábitos que provocan retrabajo. Ojo: el propio análisis consume tokens.

**Gestión de contexto**
- **`/clear`** entre tareas no relacionadas. No cuesta nada y es la acción de mayor impacto. Usa `/rename` antes para poder volver con `/resume`.
- **`/compact <instrucciones>`** (p. ej. `/compact Focus on the API changes`):
  - Puedes fijar qué conservar con una sección "Compact instructions" en CLAUDE.md.
  - Resume, así que pierde detalle.
  - Además es una petición grande en sí: lee toda la conversación. Con la caché caliente sale barato; tras una pausa larga, reprocesa todo sin caché.
  - Hazlo en pausas naturales, no a mitad de tarea.
- **`/rewind`** (o doble Esc) para abandonar un camino fallido. Trunca hasta un prefijo que ya está en caché, así que suele ser más barato que compactar. Incluye "Summarize from here / up to here" para compactar solo una parte.
- **`/btw`** para preguntas laterales: la respuesta no entra en el historial.
- **Autocompactación**:
  - `/autocompact 500k` fija cuándo salta.
  - `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` solo puede adelantarla.
  - Los modelos con ventana nativa de 1M compactan hacia los ~967K tokens por defecto.
  - Que haya ventana de 1M no significa que convenga llenarla: la calidad y el coste por turno empeoran con el volumen.

**CLAUDE.md y memoria jerárquica**
- Se carga en cada sesión. La recomendación oficial es mantenerlo por debajo de 200 líneas y preguntarse en cada línea: "¿si la quito, Claude se equivocará?".
- Un CLAUDE.md demasiado largo hace que Claude ignore instrucciones.
- Pon las reglas específicas junto al código: los CLAUDE.md en subdirectorios y las reglas con `paths:` se cargan solo cuando Claude lee archivos de esa zona.
- Usa `@ruta` para importar en lugar de pegar contenido.
- `/doctor` propone recortes de lo que Claude puede deducir del código.
- Editar CLAUDE.md a mitad de sesión no invalida la caché, pero tampoco se aplica hasta `/clear`, `/compact` o reinicio.

**Skills (carga progresiva)**
- Solo el nombre y la descripción se cargan al inicio (del orden de 50‑100 tokens por skill). El cuerpo se carga al invocarla y los archivos de referencia solo si hacen falta.
- Mueve los flujos especializados (revisión de PR, migraciones, visión general de la arquitectura) de CLAUDE.md a skills.
- Una skill "codebase-overview" evita que Claude gaste tokens explorando para entender la estructura.
- Invocar una skill no rompe la caché, salvo que su frontmatter fije otro `model`.

**Selección de modelo**
- Alias actuales en la API de Anthropic: `opus` → Opus 5.5, `sonnet` → Sonnet 5, además de `haiku` y `fable` (Fable 5.1, el más capaz y el más caro por token).
- La documentación oficial recomienda Sonnet para la mayoría de tareas y reservar Opus para decisiones arquitectónicas o razonamiento de varios pasos.
- **`opusplan`**: usa Opus en modo plan y Sonnet al ejecutar. Cada alternancia del modo plan es un cambio de modelo y reconstruye la caché, así que conviene en sesiones con una fase de planificación larga, no en cambios constantes.
- Cambiar a Opus con `/model` también afecta a los subagentes que heredan el modelo. Fija `model: haiku` en los subagentes sencillos.
- Guía del blog de Claude (julio 2026):
  - Sube de modelo cuando Claude "tenía todo el contexto, lo intentó y aun así falló".
  - Sube de esfuerzo cuando saltó archivos, no ejecutó tests o abandonó un refactor a medias.
  - Baja de modelo en trabajo rutinario.
  - En tareas difíciles, un modelo mayor puede costar menos por tarea, porque evita iteraciones fallidas.
- Precios orientativos por millón de tokens de entrada/salida: Haiku 4.5 ~1/5 $, Sonnet 5 ~2/10 $, Opus ~5/25 $. Son cifras de terceros; compruébalas en la página oficial de precios.

**Razonamiento y esfuerzo**
- El thinking se factura como tokens de salida y el presupuesto por defecto puede llegar a decenas de miles de tokens por petición.
- Cómo ajustarlo:
  - `/effort` (o las flechas en `/model`) con niveles low/medium/high/xhigh/max.
  - `ultrathink` en el prompt para un razonamiento profundo puntual.
  - `MAX_THINKING_TOKENS` solo en modelos con presupuesto fijo.
- Opus 5.5 usa medium por defecto; la mayoría del resto, high. En Opus 5.5 y Fable 5.1 el thinking no se puede desactivar.
- En la mayoría de modelos, cambiar el esfuerzo a mitad de sesión invalida la caché. Excepción: Opus 5.5 y Fable 5.1 vía API o suscripción. Elige el esfuerzo al principio.

**Modo plan**
- Evita retrabajo caro cuando el enfoque es incierto o el cambio toca varios archivos.
- Añade sobrecarga: si puedes describir el diff en una frase, sáltatelo.
- Cambiar de modo de permisos no rompe la caché, salvo con `opusplan`.

**Subagentes**
- Trabajan en su propia ventana de contexto y devuelven solo un resumen. Son la herramienta ideal para exploración, ejecución de tests, lectura de documentación y logs.
- Redefine el subagente integrado **Explore** con `model: haiku` para abaratar la exploración.
- Las descripciones de los subagentes ocupan contexto: si superan los 15.000 tokens en total, Claude Code muestra un aviso al arrancar.
- Según la página oficial de costes, **agent teams** (experimental) usa aproximadamente 7 veces más tokens que una sesión estándar cuando los compañeros trabajan en modo plan. Úsalo con equipos pequeños y en Sonnet.

**Hooks**
- Preprocesan datos de forma determinista antes de que lleguen a Claude.
- La documentación oficial incluye un hook `PreToolUse` que reescribe `npm test`/`pytest`/`go test` para devolver solo los fallos (`grep -A 5 -E '(FAIL|ERROR|error:)' | head -100`). Pasa un log de 10.000 líneas de decenas de miles de tokens a cientos.
- Es la versión "a medida" de RTK: tú controlas qué se filtra.

**MCP**
- Las herramientas ya se cargan de forma diferida. Aun así:
  - Desactiva con `/mcp` los servidores que no uses.
  - Evita `alwaysLoad` y el modo umbral (`auto:N`), que puede volver a meter todas las definiciones en el prompt.
  - Prefiere CLIs (`gh`, `aws`, `gcloud`, `sentry-cli`), que según Anthropic son más eficientes en contexto porque no añaden listado de herramientas.
- Vigila también las salidas voluminosas de herramientas MCP (se ha informado de un aviso a partir de 10.000 tokens).

**Plugins de code intelligence (LSP)**
- En lenguajes tipados, "go to definition" sustituye a un grep seguido de leer varios archivos candidatos, y los errores de tipos se detectan sin compilar.
- Evidencia independiente, limitada:
  - CircleCI (vuejs/core, 3 tareas): −14 % de coste con Sonnet 4.6 y −3 % con Opus 4.8, con más precisión. Solo cuando CLAUDE.md indicaba confiar en el LSP; sin esa instrucción, Claude revisaba los resultados y gastaba más.
  - ManoMano: el LSP integrado confundió métodos homónimos y falló un refactor grande.

**Permisos y exclusión de archivos**
- **`.claudeignore` no existe como función oficial.** The Register (28 de enero de 2026) lo reprodujo con Claude Code v2.1.12: Claude leyó un `.env` listado en él.
- Para bloquear archivos usa `permissions.deny` en `.claude/settings.json` (p. ej. `Read(./.env)`).
- Es sobre todo una medida de seguridad, no de ahorro. Denegar una herramienta completa (`Bash` a secas) puede invalidar la caché si Tool Search no está activo.

**Output styles y modo headless**
- Cambiar de estilo de salida ya no rompe la caché. Un estilo conciso ahorra poco en agentes, porque la salida es sobre todo código.
- `claude -p` con `--allowedTools`, `--output-format json` y `--max-budget-usd` sirve para lotes acotados. `--no-session-persistence` evita crear sesiones reanudables.

**Tareas de fondo**
- Consumen poco (normalmente menos de 0,04 $ por sesión).
- Los `/loop` programados, los mensajes entre sesiones y los check-ins de `/goal` reenvían todo el contexto aunque estés inactivo.

### 2. Buenas prácticas de flujo de trabajo

- **Prompts específicos y acotados.** "Añade validación a la función de login en auth.ts" evita el escaneo amplio que provoca "mejora este código". Nombra archivos, restricciones y un patrón de ejemplo.
- **Referenciar con `@archivo`** en lugar de describir dónde está el código.
- **Dar a Claude una forma de verificar su trabajo** (tests, build, capturas). Es la práctica de calidad número uno de Anthropic y reduce iteraciones: lo que más encarece una tarea es rehacerla.
- **Explorar → planificar → implementar → commit.** Para funcionalidades grandes, deja que Claude te entreviste, escribe un SPEC.md e implementa en una sesión nueva con el contexto limpio.
- **Corregir pronto.** Esc para parar; tras dos correcciones fallidas, `/clear` y un prompt mejor. Una sesión limpia casi siempre supera a una larga llena de correcciones.
- **Sesiones cortas y temáticas.** Nómbralas como ramas (`/rename`) y reanúdalas solo si el historial aporta valor.
- **Mantener la caché caliente.** Elige modelo y esfuerzo al principio, no cambies de modelo a mitad de tarea y usa subagentes con modelo explícito en lugar de alternar con `/model`.
  - En suscripción la caché dura 1 h; con créditos de uso o clave de API, 5 minutos por defecto.
  - Tras una pausa larga, retomar una sesión grande reprocesa todo. Claude Code ofrece reanudar desde un resumen.
- **Evitar lecturas enormes y salidas ruidosas.**
  - Ejecuta tests individuales, no la suite completa (lo sugiere el propio ejemplo oficial de CLAUDE.md).
  - Usa `--quiet` o equivalentes (p. ej. `mvn -q`).
  - Lee archivos grandes por fragmentos o delega en un subagente.
  - Si ves "Autocompact is thrashing", un archivo o salida enorme está llenando la ventana una y otra vez.
- **TDD y Writer/Reviewer.** Una sesión escribe tests y otra implementa; un subagente revisa el diff con contexto fresco. Pide que señale solo problemas de corrección para no sobreingeniar.
- **Git worktrees y `/batch`** para paralelizar tareas independientes sin mezclar contextos. Recuerda que cada sesión tiene su propio coste.
- **Conversar en Chat y ejecutar en Code.** Puedes pensar la arquitectura en claude.ai o con Sonnet y llevar a Claude Code solo la ejecución.

### 3. Herramientas externas y de la comunidad

| Herramienta | Qué hace | Efectividad real | Contrapartidas | Veredicto |
|---|---|---|---|---|
| **ccusage** (`npx ccusage@latest`, `blocks --live`) | Informes diarios/mensuales y por bloque de 5 h a partir de los JSONL locales | Visibilidad; no ahorra por sí mismo | Cifras estimadas a precio de lista | **Recomendado** |
| **Claude‑Code‑Usage‑Monitor** (`claude-monitor`) | Panel en tiempo real, ritmo de consumo y predicción de agotamiento del bloque | Útil para no quedarte sin cuota a mitad de tarea | Predicciones aproximadas | **Recomendado** |
| **LiteLLM / gateways** | Seguimiento del gasto por clave, presupuestos y límites | Gobierno de equipos | Si el gateway quita los marcadores `cache_control`, todo el historial se factura sin caché | Para organizaciones |
| **RTK** | Proxy que comprime la salida de git, tests, etc. mediante hook | JetBrains (425 ejecuciones facturadas, claude-sonnet-5): +7,6 % de coste con esfuerzo bajo (p=0,004), ±0 % con esfuerzo alto. Quesma: sin ahorro fiable y +17 % con DeepSeek. Su contador `rtk gain` sobrestima el ahorro | Solo ve ~20 % de la salida de herramientas (Read/Grep lo esquivan); bugs de reescritura (339 errores seguidos en un caso) | **No recomendado como palanca general**; como mucho en comandos concretos muy verbosos |
| **Caveman / claude-token-efficient** | Respuestas telegráficas | −8,5 % de tokens de salida en agentes (JetBrains, 86 tareas de SkillsBench con la skill forzada; es el techo) frente al −65 % anunciado; calidad igual | Añade tokens de entrada por las reglas | Opcional, impacto bajo |
| **Ponytail** | Skill que reduce el código generado | −10,3 % de coste, −15 % de código, −11 % de tiempo (JetBrains, 80 tareas pareadas; anunciaba −54 % de código, −22 % de tokens y −20 % de coste) | Instalada como skill, no se autoactivó en 10 sesiones | Probar, con activación explícita |
| **Serena (MCP, LSP)** | Navegación y edición semántica por símbolos | ManoMano (36K líneas de Java): único enfoque que completó un refactor con todos los tests en verde, pero +16 % de coste frente a Claude sin Serena; en consultas simples costó ~4 veces más. Un benchmark de un competidor: +16 % de tokens y peor fundamentación | Arranque e indexación; Claude "olvida" usarlo tras compactar | Solo en repos grandes y refactors; desactivar para consultas triviales |
| **claude-context (Zilliz)** | Búsqueda híbrida BM25 + vectorial vía MCP | −39,4 % de tokens (73.373 → 44.449) y −36 % de llamadas en la evaluación del propio fabricante, con GPT‑4o‑mini, no Claude Code | Envía fragmentos de código a proveedores de embeddings; sin réplica independiente | Prometedor en monorepos; validar antes |
| **Context7** | Documentación actualizada y por versión vía MCP o CLI | Evita alucinaciones de API y retrabajo; no está pensado para ahorrar tokens | Cada consulta mete documentación en el contexto | Útil para calidad; delegar en subagente |
| **Repomix** | Empaqueta el repo en un solo archivo | Útil para pasar contexto a un chat externo | En Claude Code, meter el repo entero va contra el principio de contexto mínimo | Poco indicado dentro de Claude Code |

**Lección metodológica:** según el paper de PointFive, reducir tokens no equivale a reducir coste. Los compresores pueden alterar la trayectoria del agente (más búsquedas, relecturas y turnos que reenvían todo el prefijo) y, en su subconjunto de Go, la compresión agresiva redujo la tasa de éxito. Evalúa siempre el coste por tarea completada con éxito, medido en tu factura.

### 4. Trade-offs: qué degrada la calidad y cómo equilibrarlo

| Técnica | Riesgo para la calidad | Cómo mitigarlo |
|---|---|---|
| Compactar a menudo o sin guía | Pierde nombres exactos, errores y decisiones tempranas | Instrucciones de compactación en CLAUDE.md; compactar en pausas naturales; preferir `/clear` + notas/SPEC.md cuando no necesitas continuidad |
| Modelos pequeños en tareas ambiguas | Más errores e iteraciones; puede salir más caro | Haiku solo para tareas mecánicas y bien especificadas; Opus/Fable cuando falla con todo el contexto |
| Esfuerzo bajo | Salta archivos, no ejecuta tests | Por defecto para la mayoría; low solo en rutina |
| CLAUDE.md recortado en exceso | Claude vuelve a explorar o viola convenciones | Mantener comandos, convenciones no obvias y trampas conocidas; mover el resto a skills, no borrarlo |
| Filtros de salida (hooks/RTK) | Ocultan la línea de error relevante; provocan relecturas | Filtrar solo comandos conocidos; conservar código de salida y contexto (`-A 5`); modo "tee" para guardar la salida completa |
| Excluir archivos / recortar contexto | El agente decide a ciegas | Recortar ruido (generados, logs), no fuentes |
| Cambiar de modelo o esfuerzo para "ahorrar" a mitad de tarea | Invalida la caché y encarece el turno | Decidir al principio o delegar en subagentes |

### Ranking de técnicas por impacto

| # | Técnica | Impacto en coste | Riesgo para la calidad | Esfuerzo |
|---|---|---|---|---|
| 1 | `/clear` entre tareas y sesiones cortas | Muy alto | Ninguno (mejora) | Mínimo |
| 2 | Modelo adecuado (Sonnet por defecto, Haiku en subagentes, Opus/`opusplan` puntual) | Muy alto (hasta ~5 veces por tarea entre niveles) | Bajo si se sigue la guía | Bajo |
| 3 | No romper la caché (modelo y esfuerzo fijos, MCP diferidos, pausas de menos de 1 h / 5 min) | Alto | Ninguno | Bajo |
| 4 | Subagentes para exploración, tests y logs | Alto en el contexto principal | Bajo (se pierde detalle bruto) | Bajo |
| 5 | Prompts específicos con `@archivos` y criterios de verificación | Alto (menos retrabajo) | Mejora | Medio |
| 6 | CLAUDE.md de menos de 200 líneas + skills | Medio (coste fijo por turno) | Mejora | Medio |
| 7 | Ajustar esfuerzo y thinking | Medio | Medio si se baja demasiado | Bajo |
| 8 | Hooks que filtran salidas de tests y logs | Medio (en sesiones con muchos tests) | Medio si filtran mal | Medio |
| 9 | Modo plan en tareas multiarchivo | Medio (evita retrabajo) | Mejora | Bajo |
| 10 | LSP / Serena / claude-context en repos grandes | Variable (de −40 % a +16 %) | Variable | Alto |
| 11 | Compresores externos (RTK, Caveman) | Nulo o ligeramente negativo en benchmarks | Bajo-medio | Bajo |

## Recommendations

1. **Mide durante una semana** con `/usage` (y `/insights`) más ccusage o claude-monitor. Identifica si tu gasto viene de sesiones largas, de Opus por defecto, de fallos de caché o de MCP.
2. **Fija por defecto** `sonnet` con esfuerzo por defecto. Define subagentes de exploración y de ejecución de tests con `model: haiku` y herramientas de solo lectura. Usa `opusplan` u Opus solo en sesiones de diseño.
3. **Poda CLAUDE.md** a menos de 200 líneas, añade "Compact instructions" y convierte los procedimientos en skills.
4. **Añade un hook de filtrado de tests** (el ejemplo oficial) en lugar de un compresor genérico. Documenta en CLAUDE.md "ejecutar tests individuales".
5. **Audita MCP:** desactiva lo que no uses, no fuerces `alwaysLoad`, prefiere CLIs y, en lenguajes tipados, instala el plugin LSP con la instrucción de confiar en sus resultados.
6. **Adopta Serena o claude-context solo tras un piloto A/B** en tu repo, midiendo coste por tarea completada y tasa de éxito, no tokens.
7. **Para equipos:** límites de gasto por workspace o miembro, `modelPricing` para ver tarifas contratadas, OpenTelemetry o un gateway para atribuir gasto, y cuidado con agent teams (aproximadamente 7 veces más tokens que una sesión estándar con compañeros en modo plan, según la página oficial de costes).

### Checklist práctico

- [ ] `/clear` al cambiar de tarea; `/rename` antes si quieres volver
- [ ] Modelo y esfuerzo elegidos al inicio; no alternar a mitad de tarea
- [ ] Sonnet por defecto; Haiku en subagentes mecánicos; Opus/Fable solo para lo difícil
- [ ] CLAUDE.md de menos de 200 líneas + sección "Compact instructions"; procedimientos en skills
- [ ] Prompts con `@archivo`, alcance y criterio de verificación (test/build)
- [ ] Modo plan solo si el cambio es multiarchivo o incierto
- [ ] Exploración, logs y suites de tests delegados en subagentes
- [ ] Hook que filtra salidas de tests; comandos en modo quiet
- [ ] `/mcp`: desactivar servidores no usados; preferir CLIs
- [ ] `/compact` con instrucciones en pausas naturales; `/rewind` para descartar caminos fallidos
- [ ] Tras dos correcciones fallidas: `/clear` y un prompt mejor
- [ ] Revisar `/usage` (línea de caché y flags) y ccusage semanalmente
- [ ] Secretos con `permissions.deny`, no con `.claudeignore`

## Caveats

- Claude Code cambia casi cada semana (versiones v2.1.2xx en 2026). Nombres de comandos (`/usage` sustituyó a `/cost`), alias de modelo y comportamiento de la caché por esfuerzo pueden cambiar. Comprueba con `claude --version` y la documentación oficial.
- Casi todas las cifras de ahorro de herramientas de la comunidad las publican sus autores. Las independientes más sólidas (JetBrains, PointFive, Quesma) usan benchmarks concretos (SkillsBench, Terminal-Bench, tareas propias) y pueden no reflejar tu código. RTK 0.46.0 corrigió algún bug posterior a esas pruebas.
- La evidencia sobre Serena y LSP es de muestras pequeñas (una ejecución por tarea), y una de las fuentes sobre Serena es un competidor.
- Los precios por token citados proceden de terceros. En suscripciones, el "coste" de `/usage` no es facturable, pero refleja el consumo de tu cuota de 5 horas y semanal.