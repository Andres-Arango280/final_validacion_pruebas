# features/support/screenplay_pattern.rb

# ============================================================================
# PATRÓN SCREENPLAY PARA BDD
# ============================================================================
# El patrón Screenplay separa las pruebas en:
# - Actors (Usuarios que realizan acciones)
# - Tasks (Tareas que los actores realizan)
# - Abilities (Habilidades de los actores)
# ============================================================================

module Screenplay
  # Actor: Representa al usuario que interactúa con el sistema
  class Actor
    attr_reader :nombre, :habilidades

    def initialize(nombre)
      @nombre = nombre
      @habilidades = []
    end

    def puede(habilidad)
      @habilidades << habilidad
    end

    def intenta(*tareas)
      tareas.each do |tarea|
        tarea.perform_as(self)
      end
    end
  end

  # Task: Representa una acción que el actor realiza
  class Task
    def perform_as(actor)
      raise NotImplementedError
    end
  end

  # Ability: Representa una habilidad del actor
  class Ability
    def execute(actor, context)
      raise NotImplementedError
    end
  end
end

# ============================================================================
# IMPLEMENTACIÓN ESPECÍFICA PARA US-05
# ============================================================================

module US05
  # Actors
  class UsuarioRegistrado < Screenplay::Actor
    def initialize
      super('Usuario Registrado')
      puede(CrearTemas.new)
      puede(GestionarEtiquetas.new)
    end
  end

  # Tasks
  class CrearTema < Screenplay::Task
    def initialize(titulo:, contenido:, categoria:, etiquetas: [])
      @titulo = titulo
      @contenido = contenido
      @categoria = categoria
      @etiquetas = etiquetas
    end

    def perform_as(actor)
      visit "/c/#{@categoria}"
      click_button 'create-topic'
      fill_in 'reply-title', with: @titulo
      fill_in 'd-editor-input', with: @contenido
      @etiquetas.each { |tag| agregar_etiqueta(tag) }
      click_button 'create'
    end
  end

  class VerificarCreacion < Screenplay::Task
    def initialize(titulo_esperado:)
      @titulo_esperado = titulo_esperado
    end

    def perform_as(actor)
      expect(page).to have_content(@titulo_esperado)
      expect(current_path).to include('/t/')
    end
  end

  # Abilities
  class CrearTemas < Screenplay::Ability
    def execute(actor, context)
      # Lógica de creación de temas
    end
  end

  class GestionarEtiquetas < Screenplay::Ability
    def execute(actor, context)
      # Lógica de gestión de etiquetas
    end
  end
end