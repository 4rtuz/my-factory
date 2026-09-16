# Rúbrica: paper científico

**Herramientas:** lectura local + **WebSearch/WebFetch permitidos** para verificar que las referencias citadas existen, que dicen lo que el paper afirma, y para comparar con trabajos relacionados. Sin Bash. Sin escritura.

**Evidencia exigible:** sección del paper y, cuando exista, número de tabla, figura o ecuación. Al comparar con la literatura, cita la referencia concreta (autores, año, título o DOI) y distingue con claridad lo que leíste en la fuente de lo que infieres.

**Cautela:** si una búsqueda no encuentra una referencia, eso indica que **no la has localizado**, no necesariamente que no exista. Regístralo como duda a verificar, no como acusación.

## Dimensiones obligatorias

### 1. Metodología
Diseño experimental frente a la pregunta de investigación. Tamaño y procedencia de la muestra o del dataset. Grupos de control y líneas base: ¿son las adecuadas o son deliberadamente débiles? Tratamiento de variables de confusión. Preprocesado y criterios de exclusión de datos. Reproducibilidad: ¿hay detalles suficientes —hiperparámetros, semillas, versiones, protocolo— para replicar el trabajo? ¿Hay código y datos disponibles?

### 2. Validez de los resultados
¿Sostienen los datos las conclusiones enunciadas? Significación estadística y, por separado, tamaño del efecto y su relevancia práctica. Intervalos de confianza o medidas de dispersión. Número de comparaciones y corrección por comparaciones múltiples. Señales de p-hacking o de selección post hoc de métricas. Salto de correlación a causalidad. Generalización desde el dominio evaluado a las afirmaciones del abstract. Estudios de ablación cuando se combinan varias contribuciones. Discusión honesta de limitaciones y casos de fallo.

### 3. Novedad frente a la literatura existente
Qué afirma el paper que es nuevo y si lo es. Busca trabajos previos cercanos y comprueba si están citados y bien caracterizados. Distingue: contribución genuina / incremento pequeño presentado como grande / replicación con valor propio (dilo, no es un defecto) / reformulación de un resultado conocido. Comprueba si la comparación con el estado del arte es justa y actualizada.

### 4. Claridad
Correspondencia entre el abstract y lo que el cuerpo demuestra. Definición de términos y notación antes de usarlos. Estructura de las secciones. Calidad de figuras y tablas: ¿aportan o repiten el texto?, ¿tienen ejes, unidades y barras de error?, ¿son legibles en escala de grises? Coherencia entre texto, tablas y figuras en las cifras concretas. Lenguaje que sobreafirma ("demostramos que", "resuelve el problema de").

### 5. Calidad de las citas
Verifica una muestra representativa de referencias, priorizando las que sostienen las afirmaciones centrales. Comprueba: que la referencia existe; que dice lo que el paper le atribuye; que respalda esa afirmación concreta y no una vecina. Detecta citas de relleno, autocitas desproporcionadas, exceso de preprints sin revisar para afirmaciones clave, ausencias notables en el área y bibliografía desactualizada en un campo que se mueve rápido. Indica siempre cuántas referencias verificaste y cuáles.

## Errores a evitar en esta rúbrica

- Confundir "no es el método que yo usaría" con "el método es inválido".
- Exigir a un short paper el aparato experimental de un artículo de revista; ajusta las expectativas al formato y al venue.
- Afirmar que algo "ya se hizo antes" sin la referencia exacta en la mano.
