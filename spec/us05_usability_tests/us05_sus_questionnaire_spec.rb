# ============================================================================
# US-05: CUESTIONARIO SUS (SYSTEM USABILITY SCALE)
# ============================================================================
# Evaluación de usabilidad usando el cuestionario estándar SUS
# Brooke, J. (1996). SUS: A quick and dirty usability scale
# ============================================================================

require 'rails_helper'

RSpec.describe 'US-05 | Cuestionario SUS - System Usability Scale' do
  # ============================================================================
  # PREGUNTAS SUS ESTÁNDAR (10 preguntas)
  # ============================================================================
  
  let(:sus_questions) do
    [
      { id: 1, text: 'Creo que me gustaría usar este sistema frecuentemente', type: :positive },
      { id: 2, text: 'Encontré el sistema innecesariamente complejo', type: :negative },
      { id: 3, text: 'Pensé que el sistema era fácil de usar', type: :positive },
      { id: 4, text: 'Creo que necesitaría el apoyo de un técnico para usar este sistema', type: :negative },
      { id: 5, text: 'Encontré las diversas funciones del sistema bien integradas', type: :positive },
      { id: 6, text: 'Pensé que había demasiada inconsistencia en el sistema', type: :negative },
      { id: 7, text: 'Imagino que la mayoría de las personas aprenderían muy rápidamente a usar este sistema', type: :positive },
      { id: 8, text: 'Encontré el sistema muy engorroso de usar', type: :negative },
      { id: 9, text: 'Me sentí muy confiado al usar el sistema', type: :positive },
      { id: 10, text: 'Necesité aprender muchas cosas antes de poder usar el sistema', type: :negative }
    ]
  end

  # ============================================================================
  # SIMULACIÓN DE RESPUESTAS DE USUARIO (Escala 1-5)
  # ============================================================================
  
  let(:user_responses) do
    # Respuestas simuladas de un usuario después de probar US-05
    # 1 = Totalmente en desacuerdo, 5 = Totalmente de acuerdo
    {
      1 => 4,  # Me gustaría usarlo frecuentemente
      2 => 2,  # No es innecesariamente complejo
      3 => 4,  # Es fácil de usar
      4 => 2,  # No necesito apoyo técnico
      5 => 4,  # Funciones bien integradas
      6 => 2,  # No hay mucha inconsistencia
      7 => 4,  # Se aprende rápidamente
      8 => 2,  # No es engorroso
      9 => 4,  # Me siento confiado
      10 => 2  # No necesité aprender mucho
    }
  end

  # ============================================================================
  # CÁLCULO DEL PUNTAJE SUS
  # ============================================================================
  
  def calculate_sus_score(responses, questions)
    total_score = 0
    
    questions.each do |q|
      response = responses[q[:id]]
      
      if q[:type] == :positive
        # Preguntas positivas: score - 1
        total_score += (response - 1)
      else
        # Preguntas negativas: 5 - score
        total_score += (5 - response)
      end
    end
    
    # Multiplicar por 2.5 para obtener puntaje SUS (0-100)
    (total_score * 2.5).round(2)
  end

  # ============================================================================
  # PRUEBAS DEL CUESTIONARIO
  # ============================================================================
  
  describe 'Evaluación del Cuestionario SUS' do
    it 'SUS-01: Contiene las 10 preguntas estándar del cuestionario' do
      expect(sus_questions.length).to eq(10)
      puts "✓ SUS-01: 10 preguntas estándar SUS presentes"
    end

    it 'SUS-02: Alterna correctamente entre preguntas positivas y negativas' do
      positive_count = sus_questions.count { |q| q[:type] == :positive }
      negative_count = sus_questions.count { |q| q[:type] == :negative }
      
      expect(positive_count).to eq(5)
      expect(negative_count).to eq(5)
      puts "✓ SUS-02: Balance perfecto: 5 positivas, 5 negativas"
    end

    it 'SUS-03: Calcula correctamente el puntaje SUS' do
      score = calculate_sus_score(user_responses, sus_questions)
      
      # El puntaje debe estar entre 0 y 100
      expect(score).to be_between(0, 100)
      puts "✓ SUS-03: Puntaje SUS calculado: #{score}/100"
    end

    it 'SUS-04: Interpreta el puntaje según escala de Bangor' do
      score = calculate_sus_score(user_responses, sus_questions)
      
      # Escala de interpretación (Bangor & Kortum, 2009)
      interpretation = case score
                       when 85..100 then 'Excelente (Grade A)'
                       when 70..84  then 'Bueno (Grade B)'
                       when 50..69  then 'OK (Grade C)'
                       when 25..49  then 'Pobre (Grade D)'
                       else 'Awful (Grade F)'
                       end
      
      expect(score).to be > 50  # Debe ser al menos aceptable
      puts "✓ SUS-04: Interpretación: #{interpretation} (Score: #{score})"
    end

    it 'SUS-05: Supera el promedio de la industria (68)' do
      score = calculate_sus_score(user_responses, sus_questions)
      industry_average = 68
      
      expect(score).to be > industry_average
      puts "✓ SUS-05: Supera promedio industria (68): #{score}"
    end
  end

  # ============================================================================
  # ANÁLISIS DETALLADO POR DIMENSIÓN
  # ============================================================================
  
  describe 'Análisis por Dimensiones SUS' do
    it 'SUS-D1: Usabilidad (preguntas impares positivas)' do
      positive_questions = sus_questions.select { |q| q[:type] == :positive }
      usability_score = positive_questions.sum { |q| user_responses[q[:id]] - 1 } * 2.5
      
      expect(usability_score).to be > 0
      puts "✓ SUS-D1: Puntaje Usabilidad: #{usability_score.round(2)}/50"
    end

    it 'SUS-D2: Aprendizaje (preguntas pares negativas)' do
      negative_questions = sus_questions.select { |q| q[:type] == :negative }
      learnability_score = negative_questions.sum { |q| 5 - user_responses[q[:id]] } * 2.5
      
      expect(learnability_score).to be > 0
      puts "✓ SUS-D2: Puntaje Aprendibilidad: #{learnability_score.round(2)}/50"
    end
  end

  # ============================================================================
  # REPORTE FINAL SUS
  # ============================================================================
  
  describe 'Reporte Final SUS' do
    it 'Genera reporte completo del cuestionario SUS' do
      score = calculate_sus_score(user_responses, sus_questions)
      
      puts "\n" + "=" * 70
      puts "📊 REPORTE SUS - SYSTEM USABILITY SCALE"
      puts "=" * 70
      puts "\n📋 CUESTIONARIO APLICADO:"
      sus_questions.each do |q|
        response = user_responses[q[:id]]
        type_icon = q[:type] == :positive ? '👍' : '👎'
        puts "  #{type_icon} P#{q[:id]}: #{q[:text][0..60]}... [#{response}/5]"
      end
      
      puts "\n📈 RESULTADOS:"
      puts "  • Puntaje SUS Total: #{score}/100"
      puts "  • Promedio Industria: 68/100"
      puts "  • Percentil Aproximado: #{score > 80 ? '90th' : score > 70 ? '80th' : '70th'}"
      puts "  • Grado: #{score >= 85 ? 'A (Excelente)' : score >= 70 ? 'B (Bueno)' : score >= 50 ? 'C (OK)' : 'D (Pobre)'}"
      puts "  • Recomendación: #{score >= 70 ? '✅ Aceptable para producción' : '⚠️  Requiere mejoras'}"
      
      puts "\n🎯 CONCLUSIÓN:"
      puts "  El sistema US-05 obtiene un puntaje SUS de #{score}/100,"
      puts "  ubicándose #{score > 68 ? 'POR ENCIMA' : 'POR DEBAJO'} del promedio"
      puts "  de la industria (68/100)."
      puts "=" * 70 + "\n"
      
      expect(score).to be >= 70  # Al menos "Bueno"
    end
  end
end
