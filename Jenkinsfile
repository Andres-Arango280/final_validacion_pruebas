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
                    echo "1. Levantando contenedor temporal de Redis en el puerto 6379..."
                    docker run -d --name redis-test-discourse --network host redis:7-alpine
                    
                    echo "2. Ejecutando pruebas de RSpec dentro del contenedor de Ruby..."
                    docker run --rm --network host -v "${workspaceLinuxPath}":/workspace -w /workspace -e RAILS_ENV=test -e COVERAGE=1 ruby:3.4.9-slim sh -c "echo 'Instalando dependencias del sistema...' && apt-get update -qq && apt-get install -y -qq build-essential git nodejs libpq-dev sqlite3 libsqlite3-dev libyaml-dev sed && echo 'Instalando gemas...' && bundle config set --local deployment 'true' && bundle install && gem install simplecov-cobertura && echo 'Ejecutando pruebas estructurales RSpec...' && bundle exec rspec spec/us05_white_box_tests && echo 'Eliminando JSON conflictivo...' && rm -f coverage/.resultset.json && echo 'Corrigiendo rutas absolutas en el XML de cobertura...' && sed -i 's|/workspace/||g' coverage/coverage.xml"
                    
                    echo "3. Limpiando contenedor de Redis..."
                    docker stop redis-test-discourse && docker rm redis-test-discourse
                    """
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo 'Enviando reporte de cobertura corregido a SonarQube...'
                
                bat """
                sonar-scanner ^
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

    post {
        always {
            script {
                echo 'Asegurando limpieza de contenedores residuales de Redis...'
                // Por si el pipeline llega a fallar a mitad de camino, evitamos que el puerto se quede bloqueado
                bat 'docker stop redis-test-discourse >nul 2>&1 && docker rm redis-test-discourse >nul 2>&1 || ver >nul'
            }
            echo 'Limpiando el espacio de trabajo en Windows...'
            cleanWs()
        }
    }
}