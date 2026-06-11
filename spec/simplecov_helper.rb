require 'simplecov'
require 'simplecov-cobertura'

SimpleCov.start 'rails' do
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/vendor/'
  add_filter '/db/'
  add_filter '/admin/'
  add_filter '/plugins/'
  add_filter '/script/'
  
  add_group 'Models', 'app/models'
  add_group 'Controllers', 'app/controllers'
  add_group 'Services', 'app/services'
  add_group 'Lib', 'lib'
  
  track_files 'app/**/*.rb'
  track_files 'lib/**/*.rb'
  
  # IMPORTANTE: Generar formato Cobertura XML para SonarQube
  formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::CoberturaFormatter
  ])
end
