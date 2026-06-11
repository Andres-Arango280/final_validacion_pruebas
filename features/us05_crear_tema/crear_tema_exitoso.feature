# language: es
# ============================================================================
# US-05: Crear Nuevo Tema en Discourse
# Historia de Usuario: Como usuario quiero crear un tema en una categoría
# ============================================================================

Característica: Crear un nuevo tema en una categoría
  Como usuario registrado de Discourse
  Quiero crear un tema con título, contenido y etiquetas
  Para iniciar una discusión con la comunidad

  Antecedentes:
    Dado que estoy autenticado como usuario registrado
    Y estoy en la página de la categoría "General"

  Escenario: Crear tema con todos los campos válidos
    Cuando hago clic en el botón "Nuevo Tema"
    Y completo el título con "Guía completa de instalación de Discourse"
    Y completo el contenido con "Este es un tutorial paso a paso para instalar Discourse en Ubuntu"
    Y selecciono la categoría "General"
    Y agrego las etiquetas "tutorial" e "instalación"
    Y hago clic en el botón "Crear Tema"
    Entonces debo ver el tema creado con el título "Guía completa de instalación de Discourse"
    Y el tema debe estar en la categoría "General"
    Y las etiquetas "tutorial" e "instalación" deben estar asociadas al tema

  Escenario: Crear tema sin etiquetas (opcional)
    Cuando hago clic en el botón "Nuevo Tema"
    Y completo el título con "Tema sin etiquetas de prueba"
    Y completo el contenido con "Contenido del tema sin etiquetas"
    Y selecciono la categoría "General"
    Y hago clic en el botón "Crear Tema"
    Entonces debo ver el tema creado exitosamente

  Esquema del escenario: Crear tema con diferentes longitudes de título
    Cuando hago clic en el botón "Nuevo Tema"
    Y completo el título con "<titulo>"
    Y completo el contenido con "Contenido válido de prueba para el escenario"
    Y selecciono la categoría "General"
    Y hago clic en el botón "Crear Tema"
    Entonces debo ver el resultado "<resultado>"

    Ejemplos:
      | titulo                                          | resultado              |
      | Título exactamente quince caracteres            | tema creado            |
      | Título de dieciséis caracteres válido           | tema creado            |
      | Título muy corto                                | error de validación    |
      