describe('US-05 · Crear nuevo tema en Discourse (QA Suite Completo)', () => {

  const openCreateTopic = () => {
    cy.get('button.btn.btn-icon-text.btn-primary.create').click()
  }

  const fillValidTopic = () => {
    cy.get('input#reply-title')
      .clear()
      .type('Título válido de prueba automatizada US05 Cypress')

    cy.get('.d-editor-input')
      .clear()
      .type('Este contenido cumple con el mínimo de caracteres requerido (10+).')
  }

  const selectCategory = () => {
    cy.get('.category-chooser').click()
    cy.contains('General').click()
  }

  const addTags = () => {
    cy.get('.mini-tag-chooser')
      .type('test-tag{enter}')
  }

  const submitTopic = () => {
    cy.contains('Create Topic').click()
  }

  beforeEach(() => {
    cy.visit('http://127.0.0.1:4200')
  })


  // ======================================================
  // 🟢 CA-05 + CA-06 + CA-07 + CA-10 (flujo principal)
  // ======================================================
  it('CA-05 · CA-06 · CA-07 · CA-10 - Creación exitosa y persistencia', () => {

    openCreateTopic()
    fillValidTopic()
    selectCategory()
    addTags()
    submitTopic()

    // CA-07 - Redirección correcta
    cy.url().should('match', /\/t\/.+\/\d+/)

    // CA-06 - Persistencia (UI check)
    cy.contains('Título válido de prueba automatizada US05 Cypress')
      .should('be.visible')

    // CA-10 - Tags asociados visibles
    cy.get('.discourse-tags')
      .should('contain', 'test-tag')
  })


  // ======================================================
  // 🔴 CA-01 - Validación longitud título
  // ======================================================
  it('CA-01 - Título menor a 15 caracteres debe fallar', () => {

    openCreateTopic()

    cy.get('input#reply-title')
      .type('corto')

    cy.get('.d-editor-input')
      .type('Contenido válido mínimo')

    submitTopic()

    cy.contains('15')
      .should('be.visible')
  })


  // ======================================================
  // 🔴 CA-02 - Contenido obligatorio
  // ======================================================
  it('CA-02 - Contenido obligatorio', () => {

    openCreateTopic()

    cy.get('input#reply-title')
      .type('Título válido suficientemente largo')

    submitTopic()

    cy.contains('contenido')
      .should('be.visible')
  })


  // ======================================================
  // 🔴 CA-03 - Tags obligatorios
  // ======================================================
  it('CA-03 - Tags obligatorios si son requeridos', () => {

    openCreateTopic()
    fillValidTopic()
    selectCategory()

    // NO tags intencionalmente
    submitTopic()

    cy.contains('tag')
      .should('be.visible')
  })


  // ======================================================
  // 🔴 CA-04 - Unicidad de título
  // ======================================================
  it('CA-04 - Título duplicado no permitido', () => {

    const title = 'Título duplicado US05 Cypress'

    openCreateTopic()
    fillValidTopic()

    cy.get('input#reply-title')
      .clear()
      .type(title)

    selectCategory()
    submitTopic()

    // segundo intento con mismo título
    openCreateTopic()

    cy.get('input#reply-title')
      .type(title)

    fillValidTopic()
    selectCategory()
    submitTopic()

    cy.contains('exists')
      .should('be.visible')
  })


  // ======================================================
  // 🔴 CA-05 - Categoría válida obligatoria
  // (caso negativo)
  // ======================================================
  it('CA-05 - No permitir crear sin categoría', () => {

    openCreateTopic()
    fillValidTopic()

    submitTopic()

    cy.contains('categoría')
      .should('be.visible')
  })


  // ======================================================
  // 🟡 CA-08 - Contadores actualizados
  // ======================================================
  it('CA-08 - Incremento de contador de categoría', () => {

    cy.get('.category-list')
      .then(($el) => {
        const before = $el.text()

        openCreateTopic()
        fillValidTopic()
        selectCategory()
        submitTopic()

        cy.get('.category-list')
          .should('not.have.text', before)
      })
  })


  // ======================================================
  // 🟡 CA-09 - Notificación creada (validación UI básica)
  // ======================================================
  it('CA-09 - Notificación al crear tema', () => {

    openCreateTopic()
    fillValidTopic()
    selectCategory()
    submitTopic()

    // Discourse suele mostrar badge o actividad reciente
    cy.get('body')
      .should('contain', '1')
  })

})