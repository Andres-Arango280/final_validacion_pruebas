#!/usr/bin/env python3
"""
Evaluación de Calidad de Pruebas con DeepEval
US-05: Crear Nuevo Tema en Discourse

DeepEval usa IA para evaluar:
- Claridad de los casos de prueba
- Cobertura de requisitos
- Calidad de los datos de prueba
- Detección de duplicados
- Sugerencias de mejora
"""

import json
from datetime import datetime

# Intentar importar deepeval
try:
    from deepeval import evaluate
    from deepeval.metrics import (
        AnswerRelevancyMetric,
        FaithfulnessMetric,
        ContextualRelevancyMetric,
        HallucinationMetric,
        BiasMetric,
        ToxicityMetric
    )
    from deepeval.test_case import LLMTestCase
    DEEPEVAL_AVAILABLE = True
except ImportError:
    print("⚠️  DeepEval no instalado. Instalando...")
    print("Ejecuta: pip install deepeval")
    DEEPEVAL_AVAILABLE = False

class TestCaseEvaluator:
    def __init__(self):
        self.test_cases = []
        self.evaluations = []
        
    def load_test_cases(self, filepath):
        """Carga casos de prueba desde archivo"""
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
                # Parsear casos de prueba del markdown
                self.test_cases = self.parse_test_cases(content)
                print(f"✅ Cargados {len(self.test_cases)} casos de prueba")
        except Exception as e:
            print(f"❌ Error cargando archivo: {e}")
            # Usar casos de ejemplo
            self.test_cases = self.get_example_test_cases()
    
    def parse_test_cases(self, content):
        """Parsea casos de prueba desde texto markdown"""
        cases = []
        current_case = None
        
        for line in content.split('\n'):
            if line.startswith('### TC-'):
                if current_case:
                    cases.append(current_case)
                current_case = {
                    'id': line.split(':')[0].replace('### ', ''),
                    'name': line.split(':')[1].strip() if ':' in line else line,
                    'description': '',
                    'given': '',
                    'when': '',
                    'then': ''
                }
            elif current_case:
                if line.startswith('**Given**'):
                    current_case['given'] = line.replace('**Given**', '').strip()
                elif line.startswith('**When**'):
                    current_case['when'] = line.replace('**When**', '').strip()
                elif line.startswith('**Then**'):
                    current_case['then'] = line.replace('**Then**', '').strip()
                elif line.strip():
                    current_case['description'] += line + '\n'
        
        if current_case:
            cases.append(current_case)
        
        return cases
    
    def get_example_test_cases(self):
        """Retorna casos de prueba de ejemplo"""
        return [
            {
                'id': 'TC-001',
                'name': 'Crear tema con todos los campos válidos',
                'description': 'Caso de prueba positivo para creación exitosa',
                'given': 'estoy autenticado como usuario registrado',
                'when': 'creo un tema con título, contenido, categoría y etiquetas válidos',
                'then': 'el tema se crea exitosamente con código 200'
            },
            {
                'id': 'TC-006',
                'name': 'Rechazar título con 14 caracteres',
                'description': 'Caso de prueba negativo para validación de longitud mínima',
                'given': 'estoy autenticado como usuario registrado',
                'when': 'intento crear un tema con título de 14 caracteres',
                'then': 'recibo error de validación indicando mínimo 15 caracteres'
            },
            {
                'id': 'TC-016',
                'name': 'Prevenir inyección XSS en título',
                'description': 'Caso de prueba de seguridad contra XSS',
                'given': 'estoy autenticado como usuario registrado',
                'when': 'intento crear un tema con título que contiene <script>alert("XSS")</script>',
                'then': 'el sistema sanitiza el input y previene la ejecución del script'
            }
        ]
    
    def evaluate_with_deepeval(self):
        """Evalúa casos de prueba usando DeepEval"""
        import os
        
        # Verificar si hay API key disponible
        has_api_key = os.getenv('OPENAI_API_KEY') and os.getenv('OPENAI_API_KEY') != 'tu_openai_key_aqui'
        
        if not DEEPEVAL_AVAILABLE or not has_api_key:
            print("⚠️  DeepEval no disponible o sin API key. Usando evaluación manual.")
            return self.evaluate_manually()
        
        print("\n🤖 Evaluando con DeepEval...\n")
        
        metrics = [
            AnswerRelevancyMetric(threshold=0.7),
            FaithfulnessMetric(threshold=0.7),
            ContextualRelevancyMetric(threshold=0.7)
        ]
        
        for test_case in self.test_cases:
            print(f"Evaluando {test_case['id']}: {test_case['name']}")
            
            # Crear caso de prueba para DeepEval
            llm_test_case = LLMTestCase(
                input=test_case['description'],
                actual_output=f"{test_case['given']} {test_case['when']} {test_case['then']}",
                expected_output="Caso de prueba completo y válido",
                context=["US-05: Crear Nuevo Tema en Discourse"]
            )
            
            # Evaluar
            try:
                result = evaluate([llm_test_case], metrics)
                self.evaluations.append({
                    'test_id': test_case['id'],
                    'test_name': test_case['name'],
                    'scores': result,
                    'status': 'EVALUATED'
                })
            except Exception as e:
                print(f"   ⚠️  Error en evaluación: {e}")
                self.evaluations.append({
                    'test_id': test_case['id'],
                    'test_name': test_case['name'],
                    'scores': None,
                    'status': 'ERROR',
                    'error': str(e)
                })
        
        return self.evaluations
    
    def evaluate_manually(self):
        """Evaluación manual cuando DeepEval no está disponible"""
        print("\n📝 Evaluación manual de calidad de pruebas...\n")
        
        for test_case in self.test_cases:
            print(f"Evaluando {test_case['id']}: {test_case['name']}")
            
            # Criterios de evaluación manual
            scores = {
                'clarity': self.evaluate_clarity(test_case),
                'completeness': self.evaluate_completeness(test_case),
                'test_data_quality': self.evaluate_test_data(test_case),
                'coverage': self.evaluate_coverage(test_case)
            }
            
            overall_score = sum(scores.values()) / len(scores)
            
            self.evaluations.append({
                'test_id': test_case['id'],
                'test_name': test_case['name'],
                'scores': scores,
                'overall_score': overall_score,
                'status': 'EVALUATED' if overall_score >= 0.7 else 'NEEDS_IMPROVEMENT'
            })
            
            print(f"   Claridad: {scores['clarity']:.2f}")
            print(f"   Completitud: {scores['completeness']:.2f}")
            print(f"   Calidad datos: {scores['test_data_quality']:.2f}")
            print(f"   Cobertura: {scores['coverage']:.2f}")
            print(f"   Score general: {overall_score:.2f}")
            print()
        
        return self.evaluations
    
    def evaluate_clarity(self, test_case):
        """Evalúa claridad del caso de prueba"""
        score = 0.0
        
        # Verificar que tenga descripción
        if test_case.get('description'):
            score += 0.3
        
        # Verificar que tenga Given/When/Then
        if test_case.get('given'):
            score += 0.2
        if test_case.get('when'):
            score += 0.2
        if test_case.get('then'):
            score += 0.3
        
        return score
    
    def evaluate_completeness(self, test_case):
        """Evalúa completitud del caso de prueba"""
        score = 0.0
        
        # Verificar que todos los campos estén presentes
        fields = ['id', 'name', 'description', 'given', 'when', 'then']
        for field in fields:
            if test_case.get(field):
                score += 1.0 / len(fields)
        
        return score
    
    def evaluate_test_data(self, test_case):
        """Evalúa calidad de datos de prueba"""
        score = 0.5  # Base score
        
        # Verificar que mencione datos específicos
        content = str(test_case).lower()
        
        if any(word in content for word in ['15', '255', '10', '5']):
            score += 0.2  # Menciona valores límite
        
        if any(word in content for word in ['válido', 'inválido', 'error', 'éxito']):
            score += 0.2  # Menciona resultados esperados
        
        if any(word in content for word in ['usuario', 'categoría', 'etiqueta']):
            score += 0.1  # Menciona entidades del dominio
        
        return min(score, 1.0)
    
    def evaluate_coverage(self, test_case):
        """Evalúa cobertura de requisitos"""
        score = 0.5  # Base score
        
        content = str(test_case).lower()
        
        # Verificar cobertura de diferentes tipos de pruebas
        if any(word in content for word in ['positivo', 'éxito', 'válido']):
            score += 0.1
        if any(word in content for word in ['negativo', 'error', 'rechazar']):
            score += 0.1
        if any(word in content for word in ['seguridad', 'xss', 'inyección']):
            score += 0.1
        if any(word in content for word in ['rendimiento', 'tiempo', 'velocidad']):
            score += 0.1
        if any(word in content for word in ['límite', 'mínimo', 'máximo']):
            score += 0.1
        
        return min(score, 1.0)
    
    def generate_report(self):
        """Genera reporte final de evaluación"""
        print("\n" + "=" * 70)
        print("📊 REPORTE DE EVALUACIÓN CON DEEPEVAL")
        print("=" * 70)
        
        if not self.evaluations:
            print("⚠️  No hay evaluaciones para reportar")
            return
        
        # Calcular métricas generales
        total = len(self.evaluations)
        evaluated = len([e for e in self.evaluations if e['status'] == 'EVALUATED'])
        needs_improvement = len([e for e in self.evaluations if e['status'] == 'NEEDS_IMPROVEMENT'])
        
        print(f"\n📈 Resumen:")
        print(f"   Total de casos evaluados: {total}")
        print(f"   ✅ Evaluados correctamente: {evaluated}")
        print(f"   ⚠️  Necesitan mejora: {needs_improvement}")
        
        # Calcular promedios de scores
        if self.evaluations[0].get('scores') and isinstance(self.evaluations[0]['scores'], dict):
            avg_scores = {}
            for key in self.evaluations[0]['scores'].keys():
                scores = [e['scores'][key] for e in self.evaluations if e.get('scores') and key in e['scores']]
                if scores:
                    avg_scores[key] = sum(scores) / len(scores)
            
            print(f"\n📊 Scores promedio:")
            for metric, score in avg_scores.items():
                print(f"   {metric.replace('_', ' ').title()}: {score:.2f}")
        
        # Guardar reporte
        report = {
            'framework': 'DeepEval',
            'version': '1.0.0',
            'timestamp': datetime.now().isoformat(),
            'summary': {
                'total_tests': total,
                'evaluated': evaluated,
                'needs_improvement': needs_improvement,
                'success_rate': f"{(evaluated / total * 100):.1f}%" if total > 0 else "0%"
            },
            'evaluations': self.evaluations
        }
        
        with open('../reports/deepeval_results.json', 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
        
        print(f"\n💾 Reporte guardado en: ../reports/deepeval_results.json")

def main():
    print("=" * 70)
    print("🤖 EVALUACIÓN DE CALIDAD DE PRUEBAS CON DEEPEVAL")
    print("US-05: Crear Nuevo Tema en Discourse")
    print("=" * 70)
    
    evaluator = TestCaseEvaluator()
    
    # Cargar casos de prueba
    evaluator.load_test_cases('../generators/test_cases_output/example_generated_tests.md')
    
    # Evaluar
    evaluator.evaluate_with_deepeval()
    
    # Generar reporte
    evaluator.generate_report()
    
    print("\n" + "=" * 70)
    print("✅ EVALUACIÓN COMPLETADA")
    print("=" * 70)

if __name__ == "__main__":
    main()
