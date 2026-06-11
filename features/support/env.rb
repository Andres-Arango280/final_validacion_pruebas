# features/support/env.rb
require 'cucumber/rails'
require 'fabrication'

Capybara.default_driver = :rack_test
Capybara.default_max_wait_time = 10

Before do
  puts "\n--- Iniciando escenario ---"
end

After do
  puts "--- Escenario completado ---\n"
end
