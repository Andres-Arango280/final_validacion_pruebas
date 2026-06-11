pipeline {
    agent {
        docker {
            image 'ruby:3.4.9-slim'
            args '-u root:root'
        }
    }

    environment {
        RAILS_ENV = 'test'
        COVERAGE = '1'
        SONAR_TOKEN = 'squ_b1d6d4cc14eb92247c72d213e9e37f39425aabf9'
        BUNDLE_PATH = "vendor/bundle"
    }

    stages {
        stage('Prepare Environment') {
            steps {
                echo 'Instalando dependencias del sistema dentro de Docker...'
                sh '''
                    apt-get update -qq && apt-get install -y -qq \
                    build-essential git nodejs libpq-dev sqlite3 libsqlite3-dev sed
                '''
            }
        }

        stage('Install Gem Dependencies') {
            steps {
                echo 'Instalando gemas del proyecto...'
                sh 'bundle config set --local deployment "true"'
                sh 'bundle install'
                sh 'gem install simplecov-cobertura'
            }
        }

        stage('Run White Box Tests') {
            steps {
                echo 'Ejecutando pruebas estructurales RSpec...'
                sh 'bundle exec rspec spec/us05_white_box_tests'
            }
        }

        stage('Fix Coverage Paths & Scan') {
            steps {
                echo 'Corrigiendo rutas del XML y enviando a SonarQube...'
                // Borramos el JSON conflictivo
                sh 'rm -f coverage/.resultset.json'
                
                // Truco del sed dinámico: adapta las rutas de Docker a lo que espera SonarQube
                sh "sed -i 's|'\$(pwd)'/||g' coverage/coverage.xml"
                
                // Ejecutamos el scanner
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
            echo 'Limpiando el espacio de trabajo en Jenkins...'
            cleanWs()
        }
    }
}