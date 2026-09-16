# Rúbrica: repositorio / código

**Herramientas:** lectura local (Read/Glob/Grep) + **Bash en modo solo lectura**, incluida la ejecución de la suite de tests **ya existente**. WebSearch/WebFetch **solo** para consultar documentación de una dependencia externa citada en el propio material.

Permitido en Bash: `ls`, `cat`, `find`, `rg`/`grep`, `wc`, `git log`, `git diff`, `git status`, `pytest`, `npm test`, `go test`, `cargo test` y equivalentes de la suite existente.
Prohibido: instalar dependencias, crear/mover/borrar ficheros, `git commit`/`push`/`checkout`/`reset`, linters o formateadores con `--fix`, y cualquier comando que altere el árbol de trabajo. Si los tests no arrancan sin instalar algo, **no lo instales**: regístralo como limitación de la revisión.

**Evidencia exigible:** `ruta/fichero.ext:línea`, o nombre de módulo/función cuando el problema es transversal. Al citar salida de tests o de comandos, indica el comando exacto que ejecutaste.

## Dimensiones obligatorias

### 1. Arquitectura
Separación de responsabilidades y límites entre módulos. Dirección de las dependencias y ciclos entre ellas. Acoplamiento de la lógica de negocio a frameworks, a la base de datos o al transporte. Coherencia de los patrones a lo largo del repo: dos formas distintas de hacer lo mismo es una señal. Gestión de estado y de configuración. Manejo de errores: ¿estrategia uniforme o cada módulo improvisa? Y también sobre-ingeniería: abstracciones con una sola implementación, capas de indirección que no pagan su coste.

### 2. Calidad y mantenibilidad
Legibilidad y nomenclatura. Funciones que hacen demasiado. Duplicación real (no la coincidencia superficial). Complejidad ciclomática en los puntos calientes. Comentarios: si explican el porqué o si repiten el qué. Código muerto, flags obsoletos, `TODO`/`FIXME` antiguos. Consistencia de estilo y si está automatizada. Facilidad para que alguien nuevo cambie algo sin romper otra cosa.

### 3. Cobertura de tests
Qué existe: unitarios, integración, extremo a extremo. **Ejecuta la suite existente y reporta el resultado real**, incluidos tests que fallan, se saltan o son inestables. Mira qué se prueba, no solo cuánto: caminos de error, casos límite, concurrencia, fallos de dependencias externas. Calidad de las aserciones (un test que no puede fallar no es un test). Tests acoplados a la implementación en vez de al comportamiento. Ausencia de tests en el código de mayor riesgo. Si hay informe de cobertura, úsalo, pero no confundas cobertura alta con buenos tests.

### 4. Documentación
README: qué es, cómo instalarlo, cómo ejecutarlo, cómo contribuir. ¿Están los pasos completos y actualizados respecto al código actual? Documentación de API pública. Decisiones de arquitectura registradas (ADR o equivalente) cuando hay elecciones no obvias. Comentarios en las zonas realmente difíciles. Ejemplos que funcionan. Contraste explícito entre lo que documenta el repo y lo que hace el código.

### 5. Seguridad básica
Revisión superficial y honesta, no una auditoría completa; dilo así en la salida. Busca: secretos, claves o credenciales versionadas; validación de entrada en los límites de confianza; inyección (SQL, comandos, plantillas); autenticación y autorización aplicadas en el servidor; datos sensibles en logs; dependencias notoriamente desactualizadas o con CVE conocidos; permisos de ficheros y configuración por defecto insegura; criptografía hecha a mano. Señala también los puntos que **no** has podido revisar.

## Errores a evitar en esta rúbrica

- Reportar preferencias de estilo como defectos cuando el repo es internamente consistente.
- Pedir una arquitectura de escala grande a un proyecto pequeño, o al revés.
- Afirmar "esto está roto" sin haber ejecutado nada ni citar la línea concreta.
