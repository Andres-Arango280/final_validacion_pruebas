#!/bin/bash

echo "========================================================================"
echo "🤖 PIPELINE DE IA APLICADA A TESTING"
echo "US-05: Crear Nuevo Tema en Discourse"
echo "========================================================================"
echo ""

# Paso 1: Generar casos de prueba con OpenAI/Claude
echo "📝 PASO 1: Generando casos de prueba con IA..."
cd generators
python3 openai_generator.py
cd ..
echo ""

# Paso 2: Ejecutar pruebas con Stagehand
echo "🚀 PASO 2: Ejecutando pruebas E2E con Stagehand..."
cd stagehand
if [ -f "node_modules/@browserbasehq/stagehand/package.json" ]; then
    node stagehand_tests.js
else
    echo "⚠️  Stagehand no instalado. Ejecutando en modo demostración..."
    node stagehand_tests.js
fi
cd ..
echo ""

# Paso 3: Evaluar calidad con DeepEval
echo "📊 PASO 3: Evaluando calidad de pruebas con DeepEval..."
cd deepeval
python3 evaluate_tests.py
cd ..
echo ""

# Paso 4: Generar reporte final
echo "📄 PASO 4: Generando reporte final..."
python3 generate_final_report.py
echo ""

echo "========================================================================"
echo "✅ PIPELINE COMPLETADO"
echo "========================================================================"
echo ""
echo "📁 Reportes generados:"
echo "   - reports/stagehand_results.json"
echo "   - reports/deepeval_results.json"
echo "   - reports/ia_testing_final_report.md"
echo ""
