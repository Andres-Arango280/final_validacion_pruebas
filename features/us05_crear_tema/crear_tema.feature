# language: es

Característica: Crear un nuevo tema en Discourse
  Como usuario registrado
  Quiero crear un tema con título y contenido
  Para iniciar una discusión

  Escenario: Crear tema básico exitoso
    Dado que estoy autenticado como usuario
    Cuando creo un tema con título "Mi primer tema de prueba válido"
    Y contenido "Este es el contenido del tema"
    Entonces el tema debe ser creado exitosamente
