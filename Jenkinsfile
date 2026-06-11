pipeline {
    agent any

    environment {
        RAILS_ENV = 'test'
        COVERAGE = '1'
        SONAR_TOKEN = 'squ_b1d6d4cc14eb92247c72d213e9e37f39425aabf9'
        SONAR_HOST_URL = 'http://localhost:9000'
        SONAR_SCANNER_VERSION = '5.0.1.3006'
        SONAR_SCANNER_HOME = "${WORKSPACE}\\sonar-scanner"
    }

    stages {
        stage('Download SonarScanner') {
            steps {
                echo '📥 Descargando SonarScanner automáticamente...'
                bat """
                    if not exist "sonar-scanner" (
                        echo Descargando SonarScanner ${SONAR_SCANNER_VERSION}...
                        powershell -Command "Invoke-WebRequest -Uri 'https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}-windows-x64.zip' -OutFile 'sonar-scanner.zip'"
                        powershell -Command "Expand-Archive -Path 'sonar-scanner.zip' -DestinationPath '.' -Force"
                        move sonar-scanner-${SONAR_SCANNER_VERSION}-windows-x64 sonar-scanner
                        del sonar-scanner.zip
                    )
                    echo SonarScanner listo en: %SONAR_SCANNER_HOME%
                    dir sonar-scanner\\bin
                """
            }
        }

        stage('Docker Test Execution') {
            steps {
                echo '🚀 Iniciando infraestructura de pruebas (Redis + Ruby)...'
                script {
                    def workspaceLinuxPath = WORKSPACE.replace('\\', '/')
                    bat """
                    echo "1. Levantando contenedor temporal de Redis..."
                    docker run -d --name redis-test-discourse --network host redis:7-alpine
                    
                    echo "2. Corriendo tests de RSpec con cobertura Cobertura XML..."
                    docker run --rm --network host -v "${workspaceLinuxPath}":/workspace -w /workspace -e RAILS_ENV=test -e COVERAGE=1 ruby:3.4.9-slim sh -c "echo '=== Instalando dependencias ===' && apt-get update -qq && apt-get install -y -qq build-essential git nodejs libpq-dev sqlite3 libsqlite3-dev libyaml-dev sed > /dev/null && echo '=== Instalando gemas ===' && bundle config set --local deployment 'true' && bundle install && gem install simplecov-cobertura && echo '=== Configurando SimpleCov para Cobertura XML ===' && cat > spec/simplecov_helper.rb << 'RUBYEOF' && require 'simplecov' && require 'simplecov-cobertura' && SimpleCov.start 'rails' do &&   add_filter '/spec/' &&   add_filter '/config/' &&   add_filter '/vendor/' &&   add_filter '/db/' &&   track_files 'app/**/*.rb' &&   track_files 'lib/**/*.rb' &&   formatter SimpleCov::Formatter::MultiFormatter.new([ &&     SimpleCov::Formatter::HTMLFormatter, &&     SimpleCov::Formatter::CoberturaFormatter &&   ]) && end && RUBYEOF && echo '=== Ejecutando RSpec ===' && bundle exec rspec spec/us05_white_box_tests spec/us05_api_tests spec/us05_regression_tests --format progress && echo '=== Verificando archivos generados ===' && ls -la coverage/ && echo '=== Corrigiendo rutas XML ===' && sed -i 's|/workspace/||g' coverage/coverage.xml 2>/dev/null || echo 'XML no encontrado, generando reporte vacio' && echo '=== Limpieza ===' && rm -f coverage/.resultset.json"
                    
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
                }
            }
        }

        stage('SonarQube Analysis & Quality Gate') {
            steps {
                echo '🔍 Enviando reporte a SonarQube y validando Quality Gate...'
                bat """
                    echo Ejecutando SonarScanner...
                    "%SONAR_SCANNER_HOME%\\bin\\sonar-scanner.bat" ^
                      -Dsonar.host.url="%SONAR_HOST_URL%" ^
                      -Dsonar.token="%SONAR_TOKEN%" ^
                      -Dsonar.projectKey="discourse-us05-tests" ^
                      -Dsonar.projectName="Discourse US-05 Tests" ^
                      -Dsonar.sources="app,lib" ^
                      -Dsonar.tests="spec" ^
                      -Dsonar.inclusions="app/**/*,lib/**/*,spec/us05_*" ^
                      -Dsonar.sourceEncoding="UTF-8" ^
                      -Dsonar.ruby.coverage.reportPaths="coverage/coverage.xml" ^
                      -Dsonar.qualitygate.wait=true ^
                      -Dsonar.qualitygate.timeout=300
                    
                    if errorlevel 1 (
                        echo SonarQube Analysis FAILED
                        exit /b 1
                    ) else (
                        echo SonarQube Analysis SUCCESS
                    )
                """
            }
        }

        stage('Generate Report') {
            steps {
                echo '📄 Generando reporte final del pipeline...'
                bat """
                    echo ======================================== > pipeline_report.txt
                    echo PIPELINE CI/CD - DISCOURSE US-05 >> pipeline_report.txt
                    echo ======================================== >> pipeline_report.txt
                    echo Build Number: %BUILD_NUMBER% >> pipeline_report.txt
                    echo Date: %DATE% %TIME% >> pipeline_report.txt
                    echo. >> pipeline_report.txt
                    echo ETAPAS COMPLETADAS: >> pipeline_report.txt
                    echo 1. Download SonarScanner >> pipeline_report.txt
                    echo 2. Docker Test Execution >> pipeline_report.txt
                    echo 3. SonarQube Analysis >> pipeline_report.txt
                    echo 4. Quality Gate >> pipeline_report.txt
                    echo ======================================== >> pipeline_report.txt
                    type pipeline_report.txt
                """
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
            bat 'docker stop redis-test-discourse >nul 2>&1 && docker rm redis-test-discourse >nul 2>&1 || ver >nul'
            cleanWs()
        }
        success {
            echo '🎉 PIPELINE COMPLETADO EXITOSAMENTE'
        }
        failure {
            echo '❌ EL PIPELINE FALLO - Revisa los logs'
        }
    }
}