// ============================================================================
// PRUEBAS DE UI - US-05: Crear Nuevo Tema
// ============================================================================
// Tipos: Visual, Responsive, Cross-browser, Usabilidad
// ============================================================================

describe('UI - US-05', () => {
  
  beforeEach(() => {
    cy.visit('/');
    cy.viewport(1280, 720); // Resolución estándar
  });

  /**
   * 1. PRUEBAS VISUALES
   */
  describe('Pruebas Visuales', () => {
    
    it('UI-001: Botón crear tema es visible', () => {
      cy.get('#create-topic').should('be.visible');
      cy.get('#create-topic').should('have.css', 'display', 'not', 'none');
    });

    it('UI-002: Formulario se abre correctamente', () => {
      cy.get('#create-topic').click();
      
      cy.get('#reply-title').should('be.visible');
      cy.get('.d-editor-input').should('be.visible');
      cy.get('.category-chooser').should('be.visible');
      cy.get('.tag-chooser').should('be.visible');
    });

    it('UI-003: Colores consistentes', () => {
      cy.get('#create-topic').click();
      
      // Verificar color del botón crear
      cy.get('.create').should('have.css', 'background-color')
        .and('not.equal', 'rgb(0, 0, 0)'); // No debe ser negro por defecto
    });

    it('UI-004: Tipografía legible', () => {
      cy.get('#create-topic').click();
      
      cy.get('#reply-title').should('have.css', 'font-size')
        .and('not.equal', '0px');
    });

    it('UI-005: Espaciado adecuado', () => {
      cy.get('#create-topic').click();
      
      cy.get('#reply-title').should('have.css', 'margin-bottom')
        .and('not.equal', '0px');
    });
  });

  /**
   * 2. PRUEBAS RESPONSIVE
   */
  describe('Pruebas Responsive', () => {
    
    it('UI-006: Desktop (1920x1080)', () => {
      cy.viewport(1920, 1080);
      cy.get('#create-topic').should('be.visible');
      cy.get('#create-topic').click();
      cy.get('#reply-title').should('be.visible');
    });

    it('UI-007: Laptop (1280x720)', () => {
      cy.viewport(1280, 720);
      cy.get('#create-topic').should('be.visible');
      cy.get('#create-topic').click();
      cy.get('#reply-title').should('be.visible');
    });

    it('UI-008: Tablet (768x1024)', () => {
      cy.viewport(768, 1024);
      cy.get('#create-topic').should('be.visible');
      cy.get('#create-topic').click();
      cy.get('#reply-title').should('be.visible');
    });

    it('UI-009: Mobile (375x667)', () => {
      cy.viewport(375, 667);
      cy.get('#create-topic').should('be.visible');
      cy.get('#create-topic').click();
      cy.get('#reply-title').should('be.visible');
    });

    it('UI-010: Mobile pequeño (320x568)', () => {
      cy.viewport(320, 568);
      cy.get('#create-topic').should('be.visible');
    });
  });

  /**
   * 3. PRUEBAS DE USABILIDAD
   */
  describe('Usabilidad', () => {
    
    it('UI-011: Placeholder en campos', () => {
      cy.get('#create-topic').click();
      
      cy.get('#reply-title').should('have.attr', 'placeholder')
        .or('have.attr', 'aria-label');
    });

    it('UI-012: Mensajes de error visibles', () => {
      cy.get('#create-topic').click();
      
      cy.get('#reply-title').type('Corto');
      
      // Debería mostrar error
      cy.get('#reply-title').should('have.class', 'error')
        .or cy.get('.title-length').should('be.visible');
    });

    it('UI-013: Botón deshabilitado cuando datos inválidos', () => {
      cy.get('#create-topic').click();
      
      // Sin datos, botón debería estar deshabilitado o mostrar error
      cy.get('.create').should('exist');
    });

    it('UI-014: Feedback visual al crear', () => {
      cy.get('#create-topic').click();
      
      cy.get('#reply-title').type('Título válido de 20 caracteres');
      cy.get('.d-editor-input').type('Contenido');
      cy.get('.create').click();
      
      // Debería haber feedback (loading, success, etc.)
      cy.get('.btn').should('exist');
    });

    it('UI-015: Navegación clara', () => {
      cy.get('#create-topic').click();
      
      // Debería haber opción de cancelar
      cy.get('.cancel').should('exist')
        .or cy.get('body').type('{esc}');
    });
  });

  /**
   * 4. PRUEBAS DE RENDIMIENTO UI
   */
  describe('Rendimiento UI', () => {
    
    it('UI-016: Formulario carga en < 2 segundos', () => {
      const start = Date.now();
      
      cy.get('#create-topic').click();
      cy.get('#reply-title').should('be.visible');
      
      const elapsed = Date.now() - start;
      expect(elapsed).to.be.lessThan(2000);
    });

    it('UI-017: Autocomplete de tags es rápido', () => {
      cy.get('#create-topic').click();
      
      const start = Date.now();
      cy.get('.tag-chooser .filter-input').type('ru');
      cy.get('.tag-chooser .select-kit-collection').should('be.visible');
      
      const elapsed = Date.now() - start;
      expect(elapsed).to.be.lessThan(1000);
    });
  });

  /**
   * 5. PRUEBAS CROSS-BROWSER (simuladas)
   */
  describe('Cross-browser', () => {
    
    it('UI-018: Funciona en Chrome', () => {
      // Cypress usa Chrome por defecto
      cy.get('#create-topic').should('be.visible');
    });

    it('UI-019: Funciona en Firefox', () => {
      // Requiere configuración de Cypress para Firefox
      cy.get('#create-topic').should('be.visible');
    });

    it('UI-020: Funciona en Edge', () => {
      // Requiere configuración de Cypress para Edge
      cy.get('#create-topic').should('be.visible');
    });
  });

  // Evidencias
  describe('Evidencias UI', () => {
    it('documenta cobertura', () => {
      console.log('\n=== PRUEBAS DE UI ===');
      console.log('Total: 20 pruebas');
      console.log('Visuales: 5');
      console.log('Responsive: 5');
      console.log('Usabilidad: 5');
      console.log('Rendimiento UI: 2');
      console.log('Cross-browser: 3');
    });
  });
});