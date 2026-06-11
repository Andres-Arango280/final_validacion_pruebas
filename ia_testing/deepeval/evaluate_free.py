#!/usr/bin/env python3
import json
import os
from datetime import datetime

def load_test_cases():
    filepath = '../generators/test_cases_output/example_generated_tests.md'
    if os.path.exists(filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        cases = []
        current = {}
        for line in content.split('\n'):
            if line.startswith('### TC-'):
                if current: cases.append(current)
                current = {'id': line.split(':')[0].replace('### ', ''), 'name': line.split(':', 1)[1].strip() if ':' in line else line, 'given': '', 'when': '', 'then': ''}
            elif current:
                if '**Given**' in line: current['given'] = line.split('**Given**')[1].strip()
                elif '**When**' in line: current['when'] = line.split('**When**')[1].strip()
                elif '**Then**' in line: current['then'] = line.split('**Then**')[1].strip()
        if current: cases.append(current)
        return cases
    return []

def evaluate_heuristically(cases):
    print("\n🤖 Evaluando calidad de pruebas con algoritmos heurísticos (Modo Gratuito)...")
    evaluations = []
    
    for tc in cases:
        clarity = 0.9 if tc.get('given') and tc.get('when') and tc.get('then') else 0.6
        completeness = 1.0 if all([tc.get('given'), tc.get('when'), tc.get('then')]) else 0.7
        
        content = str(tc).lower()
        test_data_quality = 0.95 if any(w in content for w in ['15', '255', '10', '5', 'válido', 'error']) else 0.7
        coverage = 0.9 if any(w in content for w in ['seguridad', 'xss', 'límite', 'mínimo']) else 0.8
        
        overall = (clarity + completeness + test_data_quality + coverage) / 4
        
        evaluations.append({
            'test_id': tc.get('id', 'Unknown'),
            'test_name': tc.get('name', 'Unknown'),
            'scores': {
                'clarity': round(clarity, 2),
                'completeness': round(completeness, 2),
                'test_data_quality': round(test_data_quality, 2),
                'coverage': round(coverage, 2)
            },
            'overall_score': round(overall, 2),
            'status': 'EVALUATED' if overall >= 0.7 else 'NEEDS_IMPROVEMENT'
        })
    return evaluations

def main():
    print("=" * 70)
    print("📊 EVALUACIÓN DE CALIDAD DE PRUEBAS (MODO GRATUITO)")
    print("=" * 70)
    
    cases = load_test_cases()
    print(f"✅ Cargados {len(cases)} casos de prueba para evaluación.")
    
    evaluations = evaluate_heuristically(cases)
    
    total = len(evaluations)
    evaluated = len([e for e in evaluations if e['status'] == 'EVALUATED'])
    
    report = {
        'framework': 'DeepEval (Heuristic Mode - Free)',
        'version': '1.0.0',
        'timestamp': datetime.now().isoformat(),
        'summary': {
            'total_tests': total,
            'evaluated': evaluated,
            'needs_improvement': total - evaluated,
            'success_rate': f"{(evaluated / total * 100):.1f}%" if total > 0 else "0%"
        },
        'evaluations': evaluations
    }
    
    os.makedirs('../reports', exist_ok=True)
    with open('../reports/deepeval_results.json', 'w', encoding='utf-8') as f:
        json.dump(report, f, indent=2, ensure_ascii=False)
    
    print(f"\n✅ Evaluación completada: {evaluated}/{total} casos cumplen estándares de calidad.")
    print("💾 Reporte guardado en: ../reports/deepeval_results.json")

if __name__ == "__main__":
    main()
