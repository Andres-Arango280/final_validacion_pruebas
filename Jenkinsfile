pipeline {
    agent any

    environment {
        RAILS_ENV = 'test'
        COVERAGE = '1'
        SONAR_TOKEN = 'squ_b1d6d4cc14eb92247c72d213e9e37f39425aabf9'
        SONAR_HOST_URL = 'http://localhost:9000'
    }

    stages {
        stage('Docker Test Execution') {
            steps {
                echo '🚀 Iniciando infraestructura de pruebas (Redis + Ruby)...'
                script {
                    def workspaceLinuxPath = WORKSPACE.replace('\\', '/')
                    bat """
                    echo "1. Levantando contenedor temporal de Redis..."
                    docker run -d --name redis-test-discourse --network host redis:7-alpine
                    
                    echo "2. Corriendo tests de RSpec dentro de Ruby..."
                    docker run --rm --network host -v "${workspaceLinuxPath}":/workspace -w /workspace -e RAILS_ENV=test -e COVERAGE=1 ruby:3.4.9-slim sh -c "echo 'Instalando dependencias...' && apt-get update -qq && apt-get install -y -qq build-essential git nodejs libpq-dev sqlite3 libsqlite3-dev libyaml-dev sed && echo 'Instalando gemas...' && bundle config set --local deployment 'true' && bundle install && gem install simplecov-cobertura && echo 'Ejecutando RSpec...' && bundle exec rspec spec/us05_white_box_tests && echo 'Limpiando JSON...' && rm -f coverage/.resultset.json && echo 'Corrigiendo rutas XML...' && sed -i 's|/workspace/||g' coverage/coverage.xml"
                    
                    echo "3. Apagando contenedor de Redis..."
                    docker stop redis-test-discourse && docker rm redis-test-discourse
                    """
                }
            }
            post {
                always {
                    echo '📊 Archivando reportes de cobertura...'
                    archiveArtifacts artifacts: 'coverage/index.html', allowEmptyArchive: true
                    archiveArtifacts artifacts: 'coverage/coverage.xml', allowEmptyArchive: true
                    archiveArtifacts artifacts: 'coverage/.resultset.json', allowEmptyArchive: true
                }
            }
        }

        stage('SonarQube Analysis & Quality Gate') {
            steps {
                echo '🔍 Enviando reporte y validando métricas de SonarQube...'
                script {
                    def scannerHome = tool 'SonarScanner'
                    
                    echo "Usando SonarScanner desde: ${scannerHome}"
                    
                    // Al incluir wait=true, este script fallará por sí solo si no pasa el Quality Gate
                    bat """
                    "${scannerHome}\\bin\\sonar-scanner.bat" ^
                      -Dsonar.host.url="${SONAR_HOST_URL}" ^
                      -Dsonar.token="${SONAR_TOKEN}" ^
                      -Dsonar.projectKey="discourse-us05-tests" ^
                      -Dsonar.projectName="Discourse US-05 Tests" ^
                      -Dsonar.sources="app,lib" ^
                      -Dsonar.tests="spec" ^
                      -Dsonar.inclusions="app/**/*,lib/**/*,spec/us05_*" ^
                      -Dsonar.sourceEncoding="UTF-8" ^
                      -Dsonar.ruby.coverage.reportPaths="coverage/coverage.xml" ^
                      -Dsonar.qualitygate.wait=true ^
                      -Dsonar.qualitygate.timeout=300
                    """
                }
            }
        }

        stage('Generate Report') {
            steps {
                echo '📄 Generando reporte final del pipeline...'
                script {
                    def buildStatus = currentBuild.result ?: 'SUCCESS'
                    
                    bat """
                    echo ======================================== > pipeline_report.txt
                    echo PIPELINE CI/CD - DISCOURSE US-05 >> pipeline_report.txt
                    echo ======================================== >> pipeline_report.txt
                    echo Build Number: %BUILD_NUMBER% >> pipeline_report.txt
                    echo Build Status: ${buildStatus} >> pipeline_report.txt
                    echo Date: %DATE% %TIME% >> pipeline_report.txt
                    echo. >> pipeline_report.txt
                    echo ETAPAS COMPLETADAS: >> pipeline_report.txt
                    echo ✓ Docker Test Execution >> pipeline_report.txt
                    echo ✓ SonarQube Analysis ^& Quality Gate >> pipeline_report.txt
                    echo ✓ Generate Report >> pipeline_report.txt
                    echo. >> pipeline_report.txt
                    echo METRICAS: >> pipeline_report.txt
                    echo - Cobertura: Ver coverage/index.html >> pipeline_report.txt
                    echo - SonarQube: ${SONAR_HOST_URL} >> pipeline_report.txt
                    echo ======================================== >> pipeline_report.txt
                    """
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: 'pipeline_report.txt', allowEmptyArchive: true
                }
            }
        }
    }

    post {
        always {
            echo '🧹 Limpiando recursos...'
            script {
                bat 'docker stop redis-test-discourse >nul 2>&1 && docker rm redis-test-discourse >nul 2>&1 || ver >nul'
            }
            cleanWs()
        }
        success {
            echo '🎉 PIPELINE COMPLETADO EXITOSAMENTE'
            echo '✅ Todas las etapas pasaron correctamente'
        }
        failure {
            echo '❌ EL PIPELINE FALLO'
            echo 'Revisa los logs de cada etapa para identificar el problema'
        }
        unstable {
            echo '⚠️ Pipeline completado con advertencias'
        }
    }
}