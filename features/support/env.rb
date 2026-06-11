# features/support/env.rb
require 'cucumber/rails'
require 'fabrication'

Capybara.default_driver = :rack_test
Capybara.default_max_wait_time = 10

# Usar transacciones para limpieza automática
Cucumber::Rails::World.use_transactional_tests = true

Before do
  # Limpiar datos de prueba de forma agresiva
  Topic.where("title LIKE '%prueba%' OR title LIKE '%test%' OR title LIKE '%Tema%'").delete_all
  Post.where("raw LIKE '%prueba%' OR raw LIKE '%test%'").delete_all
  Tag.where("name LIKE '%tag%' OR name LIKE '%ruby%' OR name LIKE '%rails%'").delete_all
  
  # Resetear secuencias de Fabricate
  Fabrication.clear_definitions
  
  puts "
--- Iniciando escenario ---"
end

After do
  puts "--- Escenario completado ---
"
end
