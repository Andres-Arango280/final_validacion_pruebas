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
                echo 'Iniciando contenedor de Ruby en Windows para ejecutar RSpec...'
                
                // Convertimos las barras invertidas de las rutas de Windows a barras inclinadas para Docker
                script {
                    def workspaceLinuxPath = WORKSPACE.replace('\\', '/')
                    
                    // Usamos 'bat' en lugar de 'sh' para que sea compatible con el servidor de Windows
                    bat """
                    docker run --rm -v "${workspaceLinuxPath}":/workspace -w /workspace -e RAILS_ENV=test -e COVERAGE=1 ruby:3.4.9-slim sh -c "echo 'Instalando dependencias del sistema...' && apt-get update -qq && apt-get install -y -qq build-essential git nodejs libpq-dev sqlite3 libsqlite3-dev sed && echo 'Instalando gemas...' && bundle config set --local deployment 'true' && bundle install && gem install simplecov-cobertura && echo 'Ejecutando pruebas estructurales RSpec...' && bundle exec rspec spec/us05_white_box_tests && echo 'Eliminando JSON conflictivo...' && rm -f coverage/.resultset.json && echo 'Corrigiendo rutas absolutas en el XML de cobertura...' && sed -i 's|/workspace/||g' coverage/coverage.xml"
                    """
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo 'Enviando reporte de cobertura corregido a SonarQube...'
                
                // Usamos 'bat' para arrancar el scanner en Windows
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
            echo 'Limpiando el espacio de trabajo en Windows...'
            cleanWs()
        }
    }
}