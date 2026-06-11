
# Casos de Prueba Generados con IA (Ejemplo)

## Escenarios Positivos (Happy Path)

### TC-001: Crear tema con todos los campos válidos
**Given** estoy autenticado como usuario registrado
**And** estoy en la categoría "General"
**When** creo un tema con:
  | Campo | Valor |
  | Título | "Guía completa de instalación de Discourse en Ubuntu 2024" |
  | Contenido | "Este tutorial explica paso a paso cómo instalar..." |
  | Categoría | "General" |
  | Etiquetas | ["tutorial", "instalación", "ubuntu"] |
**Then** el tema se crea exitosamente
**And** recibo código de estado 200
**And** el tema aparece en la lista de temas recientes

### TC-002: Crear tema con título de exactamente 15 caracteres
**Given** estoy autenticado como usuario registrado
**When** creo un tema con título de 15 caracteres exactos
**Then** el tema se crea exitosamente (límite mínimo aceptado)

### TC-003: Crear tema con título de exactamente 255 caracteres
**Given** estoy autenticado como usuario registrado
**When** creo un tema con título de 255 caracteres exactos
**Then** el tema se crea exitosamente (límite máximo aceptado)

### TC-004: Crear tema sin etiquetas (campo opcional)
**Given** estoy autenticado como usuario registrado
**When** creo un tema sin especificar etiquetas
**Then** el tema se crea exitosamente
**And** el tema tiene 0 etiquetas asociadas

### TC-005: Crear tema con 5 etiquetas (máximo permitido)
**Given** estoy autenticado como usuario registrado
**When** creo un tema con exactamente 5 etiquetas
**Then** el tema se crea exitosamente
**And** las 5 etiquetas quedan asociadas al tema

## Escenarios Negativos (Edge Cases)

### TC-006: Rechazar título con 14 caracteres (1 menos del mínimo)
**Given** estoy autenticado como usuario registrado
**When** intento crear un tema con título de 14 caracteres
**Then** recibo error de validación
**And** el mensaje indica "El título debe tener al menos 15 caracteres"
**And** el tema NO se crea

### TC-007: Rechazar título con 256 caracteres (1 más del máximo)
**Given** estoy autenticado como usuario registrado
**When** intento crear un tema con título de 256 caracteres
**Then** recibo error de validación
**And** el mensaje indica "El título no puede exceder 255 caracteres"

### TC-008: Rechazar título vacío
**Given** estoy autenticado como usuario registrado
**When** intento crear un tema con título vacío
**Then** recibo error de validación
**And** el mensaje indica "El título es obligatorio"

### TC-009: Rechazar contenido vacío
**Given** estoy autenticado como usuario registrado
**When** intento crear un tema con contenido vacío
**Then** recibo error de validación
**And** el mensaje indica "El contenido es obligatorio"

### TC-010: Rechazar título duplicado en misma categoría
**Given** ya existe un tema con título "Tema Existente" en categoría "General"
**And** estoy autenticado como usuario registrado
**When** intento crear otro tema con el mismo título en "General"
**Then** recibo error de duplicado
**And** el mensaje indica "Ya existe un tema con ese título en esta categoría"

### TC-011: Rechazar 6 etiquetas (excede máximo de 5)
**Given** estoy autenticado como usuario registrado
**When** intento crear un tema con 6 etiquetas
**Then** recibo error de validación
**And** el mensaje indica "Máximo 5 etiquetas permitidas por tema"

### TC-012: Permitir título duplicado en categoría diferente
**Given** ya existe un tema con título "Tema Existente" en categoría "General"
**When** creo un tema con el mismo título en categoría "Soporte"
**Then** el tema se crea exitosamente (títulos únicos por categoría)

### TC-013: Rechazar categoría inexistente
**Given** estoy autenticado como usuario registrado
**When** intento crear un tema con categoría_id = 99999 (no existe)
**Then** recibo error 404 o 422
**And** el mensaje indica "Categoría no encontrada"

### TC-014: Rechazar creación en categoría archivada
**Given** la categoría "Archivo" está marcada como archivada
**When** intento crear un tema en esa categoría
**Then** recibo error de validación
**And** el mensaje indica "No se puede crear temas en categorías archivadas"

### TC-015: Rechazar contenido con menos de 10 caracteres
**Given** estoy autenticado como usuario registrado
**When** intento crear un tema con contenido de 9 caracteres
**Then** recibo error de validación
**And** el mensaje indica "El contenido debe tener al menos 10 caracteres"

## Escenarios de Seguridad

### TC-016: Prevenir inyección XSS en título
**Given** estoy autenticado como usuario registrado
**When** intento crear un tema con título: "<script>alert('XSS')</script>Título válido"
**Then** el sistema sanitiza el input
**And** el título se almacena sin el script malicioso
**And** el tema se crea con título seguro

### TC-017: Prevenir inyección SQL en contenido
**Given** estoy autenticado como usuario registrado
**When** intento crear un tema con contenido: "Contenido'; DROP TABLE topics; --"
**Then** el sistema usa consultas parametrizadas
**And** el contenido se almacena como texto literal
**And** la base de datos no se ve afectada

### TC-018: Validar permisos de usuario
**Given** soy un usuario con trust_level = 0 (nuevo)
**And** la categoría requiere trust_level mínimo = 1
**When** intento crear un tema en esa categoría
**Then** recibo error 403 Forbidden
**And** el mensaje indica "No tienes permisos para crear temas en esta categoría"

## Escenarios de Rendimiento

### TC-019: Crear tema con contenido muy largo (10,000 caracteres)
**Given** estoy autenticado como usuario registrado
**When** creo un tema con contenido de 10,000 caracteres
**Then** el tema se crea exitosamente
**And** el tiempo de respuesta es menor a 2 segundos

### TC-020: Crear 10 temas consecutivos (stress test)
**Given** estoy autenticado como usuario registrado
**When** creo 10 temas consecutivos en menos de 1 minuto
**Then** todos los temas se crean exitosamente
**And** no hay rate limiting aplicado (o se aplica correctamente)
**And** el tiempo promedio por tema es menor a 1 segundo

## Métricas de Calidad de las Pruebas Generadas

- **Cobertura de criterios de aceptación:** 100% (8/8 criterios cubiertos)
- **Casos positivos:** 5 (25%)
- **Casos negativos:** 10 (50%)
- **Casos de seguridad:** 3 (15%)
- **Casos de rendimiento:** 2 (10%)
- **Total de casos:** 20
- **Valores límite probados:** 15, 255 (título), 10 (contenido), 5 (etiquetas)
- **Técnicas de diseño aplicadas:**
  - Análisis de valores límite ✓
  - Particiones de equivalencia ✓
  - Tabla de decisiones ✓
  - Casos de error ✓
