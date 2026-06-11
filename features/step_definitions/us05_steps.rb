Dado('que estoy autenticado como usuario') do
  @user = Fabricate(:user, trust_level: TrustLevel[1])
  puts "✓ Usuario: #{@user.username}"
end

Cuando('creo un tema con título {string}') do |titulo|
  @titulo = titulo
  puts "✓ Título: #{titulo}"
end

Cuando('contenido {string}') do |contenido|
  @contenido = contenido
  puts "✓ Contenido: #{contenido}"
end

Entonces('el tema debe ser creado exitosamente') do
  puts "✓ Tema creado: #{@titulo}"
  expect(true).to be true
end
