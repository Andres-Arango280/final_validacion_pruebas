# language: es
# ============================================================================
# Validaciones de US-05
# ============================================================================

Característica: Validaciones al crear un nuevo tema
  Como usuario registrado
  Quiero ver validaciones claras al crear un tema
  Para evitar errores en la creación

  Antecedentes:
    Dado que estoy autenticado como usuario registrado
    Y estoy en la página de la categoría "General"

  Escenario: Rechazar título vacío
    Cuando hago clic en el botón "Nuevo Tema"
    Y dejo el título vacío
    Y completo el contenido con "Contenido válido"
    Y hago clic en el botón "Crear Tema"
    Entonces debo ver un mensaje de error indicando que el título es obligatorio

  Escenario: Rechazar título muy corto (menos de 15 caracteres)
    Cuando hago clic en el botón "Nuevo Tema"
    Y completo el título con "Título corto"
    Y completo el contenido con "Contenido válido"
    Y hago clic en el botón "Crear Tema"
    Entonces debo ver un mensaje de error indicando que el título debe tener al menos 15 caracteres

  Escenario: Rechazar título duplicado en la misma categoría
    Dado que existe un tema con título "Tema único para prueba de duplicados" en la categoría "General"
    Cuando hago clic en el botón "Nuevo Tema"
    Y completo el título con "Tema único para prueba de duplicados"
    Y completo el contenido con "Contenido diferente"
    Y hago clic en el botón "Crear Tema"
    Entonces debo ver un mensaje de error indicando que el título ya existe

  Escenario: Rechazar contenido vacío
    Cuando hago clic en el botón "Nuevo Tema"
    Y completo el título con "Título válido de veinte caracteres"
    Y dejo el contenido vacío
    Y hago clic en el botón "Crear Tema"
    Entonces debo ver un mensaje de error indicando que el contenido es obligatorio

  Escenario: Validar longitud máxima del título (255 caracteres)
    Cuando hago clic en el botón "Nuevo Tema"
    Y completo el título con un texto de 256 caracteres
    Y completo el contenido con "Contenido válido"
    Y hago clic en el botón "Crear Tema"
    Entonces debo ver un mensaje de error indicando que el título es demasiado largo