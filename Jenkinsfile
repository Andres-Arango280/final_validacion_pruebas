pipeline {
    // Usamos el agente general 'any' debido a que el entorno corre sobre Windows y llamaremos a Docker manualmente
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
                
                // Ejecutamos el contenedor compartiendo el workspace actual de Windows hacia el contenedor Linux de Docker
                // Instalamos dependencias, corremos las pruebas y generamos el XML de cobertura
                withEnv(["WORKSPACE_DIR=${WORKSPACE.replace('\\', '/')}"]) {
                    sh """
                    docker run --rm -v "${WORKSPACE_DIR}":/workspace -w /workspace -e RAILS_ENV=test -e COVERAGE=1 ruby:3.4.9-slim sh -c "
                        echo 'Instalando dependencias del sistema...' && \
                        apt-get update -qq && apt-get install -y -qq build-essential git nodejs libpq-dev sqlite3 libsqlite3-dev sed && \
                        echo 'Instalando gemas...' && \
                        bundle config set --local deployment 'true' && \
                        bundle install && \
                        gem install simplecov-cobertura && \
                        echo 'Ejecutando pruebas estructurales RSpec...' && \
                        bundle exec rspec spec/us05_white_box_tests && \
                        echo 'Eliminando JSON conflictivo...' && \
                        rm -f coverage/.resultset.json && \
                        echo 'Corrigiendo rutas absolutas en el XML de cobertura...' && \
                        sed -i 's|/workspace/||g' coverage/coverage.xml
                    "
                    """
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo 'Enviando reporte de cobertura corregido a SonarQube...'
                
                // Ejecutamos el scanner desde el agente principal apuntando al XML de cobertura procesado
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
            // El bloque 'node' le da el contexto físico de Windows a Jenkins para evitar fallos de FilePath al limpiar
            node {
                echo 'Limpiando el espacio de trabajo de Windows...'
                cleanWs()
            }
        }
    }
}