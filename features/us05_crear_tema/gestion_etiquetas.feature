# language: es
# ============================================================================
# Gestión de Etiquetas - US-05
# ============================================================================

Característica: Gestión de etiquetas al crear tema
  Como usuario registrado
  Quiero gestionar etiquetas al crear un tema
  Para organizar mejor las discusiones

  Antecedentes:
    Dado que estoy autenticado como usuario registrado
    Y estoy en la página de la categoría "General"

  Escenario: Crear tema con etiquetas existentes
    Dado que existen las etiquetas "ruby" y "rails"
    Cuando hago clic en el botón "Nuevo Tema"
    Y completo el título con "Tema con etiquetas existentes"
    Y completo el contenido con "Contenido del tema"
    Y agrego las etiquetas "ruby" y "rails"
    Y hago clic en el botón "Crear Tema"
    Entonces el tema debe tener asociadas las etiquetas "ruby" y "rails"

  Escenario: Crear etiqueta nueva al crear tema
    Cuando hago clic en el botón "Nuevo Tema"
    Y completo el título con "Tema con etiqueta nueva"
    Y completo el contenido con "Contenido del tema"
    Y agrego la etiqueta "nueva-etiqueta-2026"
    Y hago clic en el botón "Crear Tema"
    Entonces la etiqueta "nueva-etiqueta-2026" debe haber sido creada
    Y el tema debe tener asociada la etiqueta "nueva-etiqueta-2026"

  Escenario: Respetar límite máximo de etiquetas
    Dado que la categoría "General" permite máximo 5 etiquetas
    Cuando hago clic en el botón "Nuevo Tema"
    Y completo el título con "Tema con muchas etiquetas"
    Y completo el contenido con "Contenido del tema"
    Y agrego 6 etiquetas diferentes
    Y hago clic en el botón "Crear Tema"
    Entonces debo ver un mensaje de error indicando el límite máximo de etiquetas