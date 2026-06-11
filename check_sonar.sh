#!/bin/bash

SONAR_URL="http://localhost:9000"
SONAR_USER="admin"
SONAR_PASSWORD="Brahian12345%"  # ← CAMBIA ESTO

echo "=== VERIFICACIÓN SONARQUBE ==="
echo ""

# 1. Estado del sistema
echo "1. Estado del sistema:"
curl -s -u $SONAR_USER:$SONAR_PASSWORD "$SONAR_URL/api/system/status" | jq -r '.status' | awk '{print "   Status:", $0}'
echo ""

# 2. Estado del último análisis
echo "2. Último análisis:"
curl -s -u $SONAR_USER:$SONAR_PASSWORD "$SONAR_URL/api/ce/activity?component=discourse-us05-tests" | jq -r '.tasks[0] | "   Status: \(.status)\n   Fecha: \(.submittedAt)"'
echo ""

# 3. Métricas principales
echo "3. Métricas principales:"
curl -s -u $SONAR_USER:$SONAR_PASSWORD "$SONAR_URL/api/measures/component?component=discourse-us05-tests&metricKeys=coverage,bugs,vulnerabilities,code_smells,duplicated_lines_density,ncloc" | jq -r '.component.measures[] | "   \(.metric): \(.value)"'
echo ""

# 4. Quality Gate
echo "4. Quality Gate:"
curl -s -u $SONAR_USER:$SONAR_PASSWORD "$SONAR_URL/api/qualitygates/project_status?projectKey=discourse-us05-tests" | jq -r '.projectStatus.status' | awk '{print "   Status:", $0}'
echo ""

echo "============================"
