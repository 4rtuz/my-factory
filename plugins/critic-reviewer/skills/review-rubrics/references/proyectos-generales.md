# Rúbrica: proyecto general

Para propuestas, planes, roadmaps, business cases, specs de producto o presupuestos.

**Herramientas:** lectura local (Read/Glob/Grep) + **Bash en modo solo lectura** para inspeccionar los ficheros del proyecto. WebSearch/WebFetch **solo** para documentación de una dependencia o tecnología externa citada en el propio material. Nada de escritura.

**Evidencia exigible:** sección o apartado del documento y cita corta del supuesto, la cifra o la métrica comentada. Cuando señales algo **ausente**, indica dónde debería estar y por qué se esperaría ahí.

## Dimensiones obligatorias

### 1. Objetivos
¿Están enunciados o hay que deducirlos? Distingue objetivo (el resultado buscado) de actividad (lo que se va a hacer). Comprueba que son específicos y observables, que hay un criterio para saber si se han alcanzado y que no se contradicen entre sí. Alineación con el problema que dice resolver: ¿está el problema descrito con evidencia o se da por supuesto? Identificación de los destinatarios y de quién decide.

### 2. Viabilidad
Recursos —personas, perfiles, presupuesto, tiempo— frente al alcance declarado. Plazos: ¿se derivan de una estimación o de una fecha deseada? Dependencias de terceros, de equipos que no controla el proyecto o de decisiones aún no tomadas. Camino crítico. Capacidad real del equipo frente a la que exige el plan. Contraste entre alcance, calidad y plazo: si los tres están fijados, dilo.

### 3. Riesgos
Lo que puede salir mal, con su probabilidad y su impacto, y si el documento lo reconoce. Cubre al menos: técnicos, de dependencias, de adopción o mercado, regulatorios y de personas (concentración de conocimiento, rotación). Evalúa la calidad de las mitigaciones: una mitigación sin responsable, sin disparador y sin coste no es una mitigación. Busca los riesgos ausentes y los planteados de forma tan genérica que no obligan a nada. Comprueba si existe un plan B y un criterio de cancelación.

### 4. Supuestos no verificados
El núcleo de esta rúbrica. Localiza lo que el documento da por cierto sin respaldo: demanda de usuarios, disponibilidad de datos, rendimiento de una tecnología, comportamiento de un tercero, cifras de coste o de conversión, capacidad de contratación. Para cada supuesto relevante: enúncialo de forma explícita, indica dónde aparece (a veces solo implícito en un cálculo), di qué pasaría si es falso y propón la comprobación más barata que lo pondría a prueba. Marca por separado las cifras que aparecen sin fuente.

### 5. Métricas de éxito
¿Hay métricas, o solo aspiraciones? Comprueba que son medibles con datos a los que el equipo tenga acceso, que tienen línea base y objetivo, y que tienen plazo. Distingue métricas de resultado de métricas de actividad. Busca contramétricas o guardarraíles que eviten optimizar una cosa rompiendo otra. Evalúa si son manipulables sin lograr el objetivo real. Comprueba quién las mide, con qué frecuencia y qué decisión se toma según el valor que arrojen.

## Errores a evitar en esta rúbrica

- Exigir el detalle de un plan de ejecución a un documento que es explícitamente una propuesta preliminar; ajusta las expectativas a la fase declarada.
- Inventar cifras de mercado o de coste para rebatir las del documento. Si no tienes fuente, formúlalo como pregunta abierta.
- Listar riesgos genéricos aplicables a cualquier proyecto; aporta solo los que se derivan de este material.
