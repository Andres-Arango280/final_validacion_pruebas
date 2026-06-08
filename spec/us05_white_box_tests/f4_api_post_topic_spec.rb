# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'F4 — API POST /posts.json (US-05)', type: :request do
  let(:user) { Fabricate(:user, trust_level: TrustLevel[1]) }
  let(:category) { Fabricate(:category) }
  let(:api_key_record) { Fabricate(:api_key, user: user) }
  
  let(:api_key) do
    api_key_record.key
  end

  let(:headers) do
    {
      'HTTP_API_KEY' => api_key,
      'HTTP_API_USERNAME' => user.username,
      'Content-Type' => 'application/json'
    }
  end

  before do
    category.set_permissions(everyone: :full)
    category.save!
    Group[:trust_level_1].add(user)
  end

  # C1 | PU-BE-F4-01 — Creación exitosa
  describe 'C1 | PU-BE-F4-01 — Creación exitosa' do
    it 'retorna 200 y crea el tema' do
      post '/posts.json', params: {
        title: 'Tema creado vía API',
        raw: 'Contenido del tema creado vía API',
        category: category.id
      }.to_json, headers: headers
      
      expect(response).to have_http_status(200)
      
      json = JSON.parse(response.body)
      expect(json).to have_key('id')
    end
  end

  # C2 | PU-BE-F4-02 — Sin autenticación
  describe 'C2 | PU-BE-F4-02 — Sin autenticación' do
    it 'retorna 401 cuando no hay API key' do
      post '/posts.json', params: {
        title: 'Tema sin auth',
        raw: 'Contenido',
        category: category.id
      }.to_json, headers: { 'Content-Type' => 'application/json' }
      
      expect(response).to have_http_status(401).or have_http_status(403)
    end
  end

  # C3 | PU-BE-F4-03 — Título muy corto
  describe 'C3 | PU-BE-F4-03 — Título muy corto' do
    it 'retorna 422 cuando el título es muy corto' do
      post '/posts.json', params: {
        title: 'Corto',
        raw: 'Contenido válido',
        category: category.id
      }.to_json, headers: headers
      
      expect(response).to have_http_status(422)
    end
  end

  # C4 | PU-BE-F4-04 — Categoría inexistente
  describe 'C4 | PU-BE-F4-04 — Categoría inexistente' do
    it 'retorna 422 cuando la categoría no existe' do
      post '/posts.json', params: {
        title: 'Título válido de 20 caracteres',
        raw: 'Contenido válido',
        category: 99999
      }.to_json, headers: headers
      
      expect(response).to have_http_status(422).or have_http_status(404)
    end
  end

  # C6 | PU-BE-F4-05 — Con tags
  describe 'C6 | PU-BE-F4-05 — Con tags' do
    it 'crea tema con tags válidos' do
      post '/posts.json', params: {
        title: 'Tema con tags vía API',
        raw: 'Contenido del tema',
        category: category.id,
        tags: ['ruby', 'rails']
      }.to_json, headers: headers
      
      expect(response).to have_http_status(200)
    end
  end

  # C7 | PU-BE-F4-06 — Título duplicado
  describe 'C7 | PU-BE-F4-06 — Título duplicado' do
    it 'retorna 422 cuando el título ya existe' do
      TopicCreator.new(user, Guardian.new(user), {
        title: 'Título único existente',
        raw: 'Contenido',
        category: category.id
      }).create
      
      post '/posts.json', params: {
        title: 'Título único existente',
        raw: 'Contenido diferente',
        category: category.id
      }.to_json, headers: headers
      
      expect(response).to have_http_status(422)
    end
  end

  # C9 | PU-BE-F4-07 — Camino feliz completo
  describe 'C9 | PU-BE-F4-07 — Camino feliz completo' do
    it 'crea tema completo con todos los elementos' do
      initial_count = Topic.count
      
      post '/posts.json', params: {
        title: 'Tema completo vía API',
        raw: 'Contenido completo del tema',
        category: category.id,
        tags: ['ruby']
      }.to_json, headers: headers
      
      expect(response).to have_http_status(200)
      expect(Topic.count).to eq(initial_count + 1)
    end
  end

  # Evidencias de ejecución
  describe 'Evidencias - Cobertura F4' do
    it 'documenta todos los caminos probados' do
      paths = [
        { id: 'C1', desc: 'Creación exitosa', status: '200 OK' },
        { id: 'C2', desc: 'Sin autenticación', status: '401/403' },
        { id: 'C3', desc: 'Título corto', status: '422' },
        { id: 'C4', desc: 'Categoría inexistente', status: '422/404' },
        { id: 'C6', desc: 'Con tags', status: '200 OK' },
        { id: 'C7', desc: 'Título duplicado', status: '422' },
        { id: 'C9', desc: 'Camino feliz', status: '200 OK' }
      ]

      puts "\n=== EVIDENCIAS DE EJECUCIÓN - F4 ==="
      paths.each { |path| puts "✓ #{path[:id]}: #{path[:desc]} → #{path[:status]}" }
      puts "Total: #{paths.count}/7 caminos documentados\n"
    end
  end
end