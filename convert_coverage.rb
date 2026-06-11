require 'simplecov'
require 'simplecov-cobertura'

# Configurar SimpleCov para generar formato Cobertura
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::CoberturaFormatter
])

# Cargar el resultado existente
result = SimpleCov::ResultMerger.merged_result
SimpleCov::Formatter::CoberturaFormatter.new.format(result)
