pipeline {
    // Cambiamos el agente a 'any' para que no dependa del plugin de Docker
    agent any

    environment {
        RAILS_ENV = 'test'
        COVERAGE = '1'
        SONAR_TOKEN = 'squ_b1d6d4cc14eb92247c72d213e9e37f39425aabf9'
    }

    stages {
        stage('Run Everything inside Docker Container') {
            steps {
                echo 'Corriendo el contenedor de Ruby e iniciando el flujo completo...'
                
                // Levantamos el contenedor dinámicamente usando comandos SH puros
                sh """
                docker run --rm -v \$(pwd):/workspace -w /workspace -e RAILS_ENV=test -e COVERAGE=1 ruby:3.4.9-slim sh -c "
                    echo 'Instalando dependencias en el contenedor...' && \
                    apt-get update -qq && apt-get install -y -qq build-essential git nodejs libpq-dev sqlite3 libsqlite3-dev sed && \
                    echo 'Instalando gemas...' && \
                    bundle config set --local deployment 'true' && \
                    bundle install && \
                    gem install simplecov-cobertura && \
                    echo 'Corriendo pruebas...' && \
                    bundle exec rspec spec/us05_white_box_tests && \
                    echo 'Ajustando reporte...' && \
                    rm -f coverage/.resultset.json && \
                    sed -i 's|/workspace/||g' coverage/coverage.xml
                "
                """
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo 'Enviando reporte consolidado a SonarQube...'
                // El análisis se lanza desde el agente principal apuntando al volumen compartido
                sh """
                sonar-scanner \
                  -Dsonar.host.url="http://localhost:9000" \
                  -Dsonar.token="${SONAR_TOKEN}" \
                  -Dsonar.projectKey="discourse-us05-tests" \
                  -Dsonar.projectName="Discourse US-05 Tests" \
                  -Dsonar.sources="app,lib" \
                  -Dsonar.tests="spec" \
                  -Dsonar.inclusions="app/**/*,lib/**/*,spec/us05_*" \
                  -Dsonar.sourceEncoding="UTF-8" \
                  -Dsonar.ruby.coverage.reportPaths="coverage/coverage.xml"
                """
            }
        }
    }

    post {
        always {
            echo 'Limpiando espacio de trabajo...'
            cleanWs()
        }
    }
}