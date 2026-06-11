pipeline {
    agent any

    environment {
        RAILS_ENV = 'test'
        COVERAGE = '1'
        SONAR_TOKEN = 'squ_b1d6d4cc14eb92247c72d213e9e37f39425aabf9'
    }

    stages {
        stage('Docker Test Execution') {
            steps {
                echo 'Iniciando infraestructura de pruebas (Redis + Ruby) en Windows...'
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
        }

        stage('SonarQube Analysis') {
            steps {
                echo 'Buscando instalación de SonarQube Scanner...'
                script {
                    // Esto fuerza a Jenkins a buscar la ruta real en el disco de Windows
                    def scannerHome = tool 'SonarScanner'
                    
                    echo "Enviando reporte de cobertura corregido a SonarQube desde ${scannerHome}..."
                    
                    // Ejecutamos usando la ruta absoluta del archivo .bat del scanner
                    bat """
                    "${scannerHome}\\bin\\sonar-scanner.bat" ^
                      -Dsonar.host.url="http://localhost:9000" ^
                      -Dsonar.token="${SONAR_TOKEN}" ^
                      -Dsonar.projectKey="discourse-us05-tests" ^
                      -Dsonar.projectName="Discourse US-05 Tests" ^
                      -Dsonar.sources="app,lib" ^
                      -Dsonar.tests="spec" ^
                      -Dsonar.inclusions="app/**/*,lib/**/*,spec/us05_*" ^
                      -Dsonar.sourceEncoding="UTF-8" ^
                      -Dsonar.ruby.coverage.reportPaths="coverage/coverage.xml"
                    """
                }
            }
        }
    }

    post {
        always {
            script {
                echo 'Asegurando limpieza de contenedores residuales de Redis...'
                bat 'docker stop redis-test-discourse >nul 2>&1 && docker rm redis-test-discourse >nul 2>&1 || ver >nul'
            }
            echo 'Limpiando el espacio de trabajo en Windows...'
            cleanWs()
        }
    }
}