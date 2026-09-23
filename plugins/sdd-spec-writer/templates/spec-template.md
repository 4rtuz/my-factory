---
id: NNNN
titulo: <título corto en imperativo, p. ej. "Exportar movimientos en CSV">
estado: Borrador   # Borrador | Propuesta | Aprobada | Implementada | Obsoleta
version: 1
fecha: AAAA-MM-DD
specs_relacionadas: []   # p. ej. [0003, 0007]
---
 
# NNNN — <Título>
 
## 1. Resumen
<!-- 2-3 frases: qué se construye, para quién y qué resultado produce. Sin detalles técnicos. -->
 
## 2. Contexto y problema
<!-- Situación actual, qué problema causa y por qué se aborda ahora. Cita la documentación del repo cuando la uses (ruta y sección). -->
 
## 3. Objetivos y no objetivos
### 3.1 Objetivos
<!-- Resultados verificables, no actividades. Numerados: O-01, O-02… -->
### 3.2 No objetivos
<!-- Lo que queda explícitamente fuera, aunque parezca relacionado. Evita que el alcance crezca durante la implementación. -->
 
## 4. Usuarios y escenarios
<!-- Actores implicados y 1-3 historias: "Como <actor>, quiero <acción> para <beneficio>". -->
 
## 5. Requisitos funcionales
<!-- Formato EARS, uno por fila. Patrones:
     Ubicuo: "El sistema debe <respuesta>."
     Evento: "Cuando <disparador>, el sistema debe <respuesta>."
     Estado: "Mientras <estado>, el sistema debe <respuesta>."
     No deseado: "Si <condición no deseada>, entonces el sistema debe <respuesta>."
     Opcional: "Donde <característica esté presente>, el sistema debe <respuesta>."
     Prioridad MoSCoW: Must | Should | Could. -->
| ID | Requisito (EARS) | Prioridad |
|----|------------------|-----------|
| RF-01 | | |
 
## 6. Requisitos no funcionales
<!-- Cada uno con métrica y umbral numérico. Cubre las categorías que apliquen: rendimiento, seguridad, privacidad y protección de datos, disponibilidad, accesibilidad, observabilidad, compatibilidad. Las que no apliquen se omiten. -->
| ID | Categoría | Requisito | Métrica | Umbral |
|----|-----------|-----------|---------|--------|
| RNF-01 | | | | |
 
## 7. Criterios de aceptación
<!-- Al menos uno por RF. Formato Gherkin, convertible directamente en test. -->
### CA-01 (cubre RF-01)
- **Dado** …
- **Cuando** …
- **Entonces** …
 
## 8. Diseño propuesto
### 8.1 Visión general
<!-- Cómo encaja en la arquitectura existente. Un diagrama Mermaid si aporta. -->
### 8.2 Componentes afectados
<!-- Ficheros o módulos nuevos y modificados, con rutas reales del repo. -->
### 8.3 Modelo de datos
<!-- Entidades, campos, tipos y migraciones. "No aplica" si no hay cambios. -->
### 8.4 Interfaces y contratos
<!-- APIs, eventos, firmas públicas, formatos de entrada y salida, códigos de error. -->
### 8.5 Flujo principal
<!-- Secuencia paso a paso del caso feliz. -->
 
## 9. Casos límite y gestión de errores
| Caso | Comportamiento esperado | Requisito relacionado |
|------|-------------------------|-----------------------|
 
## 10. Dependencias y supuestos
<!-- Dependencias técnicas, de otros equipos o de otras specs. Los supuestos se marcan como tales. -->
 
## 11. Riesgos
| Riesgo | Probabilidad (A/M/B) | Impacto (A/M/B) | Mitigación |
|--------|----------------------|-----------------|------------|
 
## 12. Plan de implementación
<!-- Tareas ordenadas y pequeñas (idealmente una por PR). Cada una indica qué RF cubre y cómo se verifica que está terminada. -->
| ID | Tarea | Cubre | Verificación |
|----|-------|-------|--------------|
| T-01 | | RF-01 | |
 
## 13. Estrategia de pruebas
<!-- Qué se prueba en cada nivel (unitario, integración, e2e) y qué criterios de aceptación cubre cada uno. Datos de prueba siempre ficticios. -->
 
## 14. Matriz de trazabilidad
| RF | Criterios de aceptación | Tareas | Tests |
|----|-------------------------|--------|-------|
| RF-01 | CA-01 | T-01 | |
 
## 15. Preguntas abiertas
<!-- Solo en la versión 1. Se elimina en la versión 2. -->
| ID | Pregunta | Sección afectada | Alternativas |
|----|----------|------------------|--------------|
| P1 | | | |
 
## 16. Decisiones
<!-- En la versión 2: "Ver decisions.md", con la lista de IDs D1…Dn y su título. -->
