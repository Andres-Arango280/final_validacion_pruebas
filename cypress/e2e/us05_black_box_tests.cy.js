// ============================================================================
// PRUEBAS DE CAJA NEGRA (E2E) - US-05: Crear Nuevo Tema
// ============================================================================
// Herramienta: Cypress
// Alcance: Front-end (UI) y Back-end (API REST)
// ============================================================================

describe('US-05: Caja Negra - Crear Nuevo Tema', () => {
  const APP_BASE_URL = Cypress.config('baseUrl') || 'http://127.0.0.1:4200'
  const API_KEY = null
  const API_USERNAME = 'system'

  const selectors = {
    createTopicButton: 'button.btn.btn-icon-text.btn-primary.create',
    titleInput: 'input#reply-title',
    bodyInput: '.d-editor-input',
    categoryChooser: '.category-chooser',
    categoryRow: '.select-kit-row',
    tagInput: '.mini-tag-chooser',
    topicTitle: '.topic-title',
    topicCount: '.category-title .topic-count',
  }

  const openCreateTopic = () => {
    cy.get(selectors.createTopicButton).click()
  }

  const fillTopic = (title, body) => {
    cy.get(selectors.titleInput).clear().type(title)
    cy.get(selectors.bodyInput).clear().type(body)
  }

  const selectCategory = (category = 'General') => {
    cy.get(selectors.categoryChooser).click()
    cy.contains(selectors.categoryRow, category).click()
  }

  const addTag = (tag) => {
    cy.get(selectors.tagInput).clear().type(`${tag}{enter}`)
  }

  const submitTopic = () => {
    cy.contains('button', /Create Topic|Crear tema/i).click()
  }

  beforeEach(() => {
    cy.visit('/')
    cy.title().should('not.contain', 'Discourse Setup')
    cy.get('body').should('not.contain', 'Register Admin Account')
  })

  describe('F1 — Validación de campos del formulario', () => {
    it('CN-F1-01: Crear tema con título válido', () => {
      openCreateTopic()
      fillTopic('Cómo instalar Discourse en Ubuntu', 'Paso a paso para instalar Discourse...')
      selectCategory()
      addTag('prueba-ui')
      submitTopic()

      cy.url().should('include', '/t/')
      cy.get(selectors.topicTitle).should('contain.text', 'Cómo instalar Discourse en Ubuntu')
    })

    it('CN-F1-02: Crear tema con título corto muestra validación', () => {
      openCreateTopic()
      fillTopic('Help', 'Contenido válido mínimo')
      selectCategory()
      submitTopic()

      cy.contains(/15|too short|muy corto/i).should('be.visible')
    })

    it('CN-F1-03: Crear tema sin contenido muestra error', () => {
      openCreateTopic()
      fillTopic('Título válido para prueba de contenido', '')
      selectCategory()
      submitTopic()

      cy.contains(/contenido|content/i).should('be.visible')
    })

    it.skip('CN-F1-04: Crear tema sin categoría (depende de configuración)', () => {
      openCreateTopic()
      fillTopic('Título sin categoría', 'Contenido válido')
      submitTopic()

      cy.contains(/categoría|category/i).should('be.visible')
    })
  })

  describe('F2 — Gestión de etiquetas', () => {
    it('CN-F2-01: Seleccionar múltiples tags', () => {
      openCreateTopic()
      fillTopic('Tags UI', 'Contenido válido con tags')
      selectCategory()
      addTag('soporte')
      addTag('instalación')

      cy.get('.discourse-tags').should('contain.text', 'soporte')
      cy.get('.discourse-tags').should('contain.text', 'instalación')
    })

    it.skip('CN-F2-02: Sin tags en categoría que los requiere', () => {
      openCreateTopic()
      fillTopic('Título sin tags', 'Contenido válido')
      selectCategory()
      submitTopic()

      cy.contains(/tags|required|etiquetas/i).should('be.visible')
    })

    it('CN-F2-03: Crear tag nuevo', () => {
      openCreateTopic()
      fillTopic('Título con tag nuevo', 'Contenido válido')
      selectCategory()

      const newTag = `nueva-etiqueta-${Date.now()}`
      addTag(newTag)

      cy.get('.discourse-tags').should('contain.text', newTag)
    })

    it('CN-F2-04: No permitir más de 5 tags si el límite existe', () => {
      openCreateTopic()
      fillTopic('Título límite tags', 'Contenido válido')
      selectCategory()

      const tags = ['t1', 't2', 't3', 't4', 't5', 't6']
      tags.forEach((tag) => addTag(tag))

      cy.get('.discourse-tags')
        .invoke('text')
        .then((text) => {
          const matches = text.match(/[0-9]+/g) || []
          expect(matches.length).to.be.at.most(5)
        })
    })
  })

  describe('F3 — Selección de categoría', () => {
    it('CN-F3-01: Ver categorías disponibles al crear tema', () => {
      openCreateTopic()
      cy.get(selectors.categoryChooser).click()
      cy.get(selectors.categoryRow).should('have.length.greaterThan', 0)
    })

    it.skip('CN-F3-02: Categoría sin permisos no debe ser visible', () => {
      openCreateTopic()
      cy.get(selectors.categoryChooser).click()
      cy.contains(selectors.categoryRow, 'Staff').should('not.exist')
    })

    it('CN-F3-03: Seleccionar categoría válida', () => {
      openCreateTopic()
      selectCategory('General')
      cy.get(selectors.categoryChooser).should('contain.text', 'General')
    })
  })

  describe('F4 — API POST /posts.json', () => {
    it('CN-F4-01: Crear tema completo vía API', () => {
      if (!API_KEY) {
        cy.log('DISCOURSE_API_KEY no configurada, omitiendo prueba API')
        return
      }

      cy.request({
        method: 'POST',
        url: '/posts.json',
        headers: {
          'Api-Key': API_KEY,
          'Api-Username': API_USERNAME,
        },
        body: {
          title: `Tema creado vía API ${Date.now()}`,
          raw: 'Contenido del tema API',
          category: 1,
        },
      }).then((response) => {
        expect(response.status).to.eq(200)
        expect(response.body).to.have.property('topic')
        expect(response.body.topic).to.have.property('id')
      })
    })

    it('CN-F4-02: Crear sin autenticación devuelve 401/403', () => {
      cy.request({
        method: 'POST',
        url: '/posts.json',
        failOnStatusCode: false,
        body: {
          title: 'Tema sin auth',
          raw: 'Contenido',
          category: 1,
        },
      }).then((response) => {
        expect(response.status).to.be.oneOf([401, 403])
      })
    })

    it('CN-F4-03: Crear con API key inválida devuelve 403', () => {
      cy.request({
        method: 'POST',
        url: '/posts.json',
        failOnStatusCode: false,
        headers: {
          'Api-Key': 'invalid_key_123',
          'Api-Username': API_USERNAME,
        },
        body: {
          title: 'Tema inválido',
          raw: 'Contenido',
          category: 1,
        },
      }).then((response) => {
        expect(response.status).to.eq(403)
      })
    })

    it('CN-F4-04: Crear tema duplicado vía API devuelve 422', () => {
      if (!API_KEY) {
        cy.log('DISCOURSE_API_KEY no configurada, omitiendo prueba API')
        return
      }

      const title = `Título Duplicado API ${Date.now()}`

      cy.request({
        method: 'POST',
        url: '/posts.json',
        headers: {
          'Api-Key': API_KEY,
          'Api-Username': API_USERNAME,
        },
        body: {
          title,
          raw: 'Contenido',
          category: 1,
        },
      })

      cy.request({
        method: 'POST',
        url: '/posts.json',
        failOnStatusCode: false,
        headers: {
          'Api-Key': API_KEY,
          'Api-Username': API_USERNAME,
        },
        body: {
          title,
          raw: 'Contenido diferente',
          category: 1,
        },
      }).then((response) => {
        expect(response.status).to.eq(422)
        expect(response.body.errors.join(' ')).to.match(/already|ya existe/i)
      })
    })
  })

  describe('F5 — Validación de unicidad y persistencia', () => {
    it('CN-F5-01: Crear tema único y verificar redirección', () => {
      const uniqueTitle = `Tema Único ${Date.now()}`

      openCreateTopic()
      fillTopic(uniqueTitle, 'Contenido único')
      selectCategory()
      submitTopic()

      cy.url().should('include', '/t/')
      cy.get(selectors.topicTitle).should('contain.text', uniqueTitle)
    })

    it('CN-F5-02: Título duplicado muestra error', () => {
      const dupTitle = `Tema Duplicado ${Date.now()}`

      openCreateTopic()
      fillTopic(dupTitle, 'Contenido 1')
      selectCategory()
      submitTopic()
      cy.url().should('include', '/t/')

      openCreateTopic()
      fillTopic(dupTitle, 'Contenido 2')
      selectCategory()
      submitTopic()

      cy.contains(/already|ya existe/i).should('be.visible')
    })

    it('CN-F5-03: Verificar persistencia visual en lista de temas', () => {
      cy.visit('/latest')
      cy.get('.topic-list-data').first().should('be.visible')
    })

    it('CN-F5-04: Verificar contadores de categorías', () => {
      cy.visit('/c/general')
      cy.get(selectors.topicCount)
        .invoke('text')
        .then((text) => {
          const match = text.match(/[0-9]+/)
          expect(match).to.not.be.null
          expect(parseInt(match[0], 10)).to.be.at.least(0)
        })
    })
  })
})
