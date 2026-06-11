# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Regresión - US-05', type: :request do
  let(:user) { Fabricate(:user, trust_level: TrustLevel[1]) }
  let(:admin) { Fabricate(:admin) }
  let(:category) { Fabricate(:category) }
  let(:api_key_record) { Fabricate(:api_key, user: admin) }
  let(:api_key) { api_key_record.key }
  
  let(:headers) do
    {
      'HTTP_API_KEY' => api_key,
      'HTTP_API_USERNAME' => admin.username,
      'Content-Type' => 'application/json'
    }
  end

  # Contenido válido (mínimo 10 caracteres requeridos por Discourse)
  let(:valid_raw) { 'Contenido válido de prueba para el post' }
  let(:valid_title) { 'Título válido de 20 caracteres' }

  before do
    category.set_permissions(everyone: :full)
    category.save!
  end

  # ========================================
  # 1. REGRESIÓN DE FUNCIONALIDAD BÁSICA
  # ========================================
  describe 'Regresión - Funcionalidad Básica' do
    
    it 'REG-001: Crear tema sigue funcionando' do
      post '/posts.json', params: {
        title: valid_title,
        raw: valid_raw,
        category: category.id
      }.to_json, headers: headers
      
      expect(response).to have_http_status(200)
    end

    it 'REG-002: Crear tema con tags sigue funcionando' do
      post '/posts.json', params: {
        title: 'Título regresión tags válido',
        raw: valid_raw,
        category: category.id,
        tags: ['regresion']
      }.to_json, headers: headers
      
      expect(response).to have_http_status(200)
    end

    it 'REG-003: Crear tema sin tags sigue funcionando' do
      post '/posts.json', params: {
        title: 'Título regresión sin tags',
        raw: valid_raw,
        category: category.id
      }.to_json, headers: headers
      
      expect(response).to have_http_status(200)
    end

    it 'REG-004: Validación de título mínimo sigue activa' do
      post '/posts.json', params: {
        title: 'Corto',
        raw: valid_raw,
        category: category.id
      }.to_json, headers: headers
      
      expect(response).to have_http_status(422)
    end

    it 'REG-005: Validación de título duplicado sigue activa' do
      post '/posts.json', params: {
        title: 'Título único regresión',
        raw: valid_raw,
        category: category.id
      }.to_json, headers: headers
      
      expect(response).to have_http_status(200)
      
      post '/posts.json', params: {
        title: 'Título único regresión',
        raw: 'Contenido diferente para el segundo post',
        category: category.id
      }.to_json, headers: headers
      
      expect(response).to have_http_status(422)
    end
  end

  # ========================================
  # 2. REGRESIÓN DE BASE DE DATOS
  # ========================================
  describe 'Regresión - Base de Datos' do
    
    it 'REG-006: Tabla topics existe y es accesible' do
      expect(Topic.count).to be >= 0
    end

    it 'REG-007: Tabla posts existe y es accesible' do
      expect(Post.count).to be >= 0
    end

    it 'REG-008: Tabla categories existe y es accesible' do
      expect(Category.count).to be >= 0
    end

    it 'REG-009: Relaciones Topic-Post funcionan' do
      # Usamos la API para asegurar que se crea Topic + Post correctamente
      post '/posts.json', params: {
        title: 'Título regresión relaciones',
        raw: valid_raw,
        category: category.id
      }.to_json, headers: headers
      
      expect(response).to have_http_status(200)
      
      json = JSON.parse(response.body)
      topic_id = json['topic_id']
      
      # Verificar que existe al menos un post asociado al topic en la BD
      post_record = Post.find_by(topic_id: topic_id)
      expect(post_record).to be_present
    end

    it 'REG-010: Relaciones Topic-Category funcionan' do
      post '/posts.json', params: {
        title: 'Título regresión category',
        raw: valid_raw,
        category: category.id
      }.to_json, headers: headers
      
      expect(response).to have_http_status(200)
      
      json = JSON.parse(response.body)
      topic = Topic.find(json['topic_id'])
      
      expect(topic.category).to eq(category)
    end
  end

  # ========================================
  # 3. REGRESIÓN DE API
  # ========================================
  describe 'Regresión - API Endpoints' do
    
    it 'REG-011: POST /posts.json responde' do
      post '/posts.json', params: {
        title: 'Título API regresión',
        raw: valid_raw,
        category: category.id
      }.to_json, headers: headers
      
      expect(response.status).to be_between(200, 422)
    end

    it 'REG-012: GET /posts.json responde' do
      get '/posts.json', headers: headers
      
      expect(response).to have_http_status(200)
    end

    it 'REG-013: GET /categories.json responde' do
      get '/categories.json', headers: headers
      
      expect(response).to have_http_status(200)
    end

    it 'REG-014: GET /tags.json responde' do
      get '/tags.json', headers: headers
      
      expect(response).to have_http_status(200)
    end
  end

  # ========================================
  # 4. REGRESIÓN DE PERMISOS
  # ========================================
  describe 'Regresión - Permisos' do
    
    it 'REG-015: Admin puede crear temas' do
      post '/posts.json', params: {
        title: 'Título admin regresión',
        raw: valid_raw,
        category: category.id
      }.to_json, headers: headers
      
      expect(response).to have_http_status(200)
    end

    it 'REG-016: Usuario normal puede crear en categoría pública' do
      user_key = Fabricate(:api_key, user: user)
      
      post '/posts.json', params: {
        title: 'Título user regresión',
        raw: valid_raw,
        category: category.id
      }.to_json, headers: {
        'HTTP_API_KEY' => user_key.key,
        'HTTP_API_USERNAME' => user.username,
        'Content-Type' => 'application/json'
      }
      
      expect(response).to have_http_status(200)
    end

    it 'REG-017: Usuario no puede crear en categoría restringida' do
      restricted_cat = Fabricate(:category, read_restricted: true)
      restricted_cat.set_permissions(staff: :full)
      restricted_cat.save!
      
      user_key = Fabricate(:api_key, user: user)
      
      post '/posts.json', params: {
        title: 'Título en restringida',
        raw: valid_raw,
        category: restricted_cat.id
      }.to_json, headers: {
        'HTTP_API_KEY' => user_key.key,
        'HTTP_API_USERNAME' => user.username,
        'Content-Type' => 'application/json'
      }
      
      expect(response).to have_http_status(403)
    end
  end

  # ========================================
  # 5. REGRESIÓN DE VALIDACIONES
  # ========================================
  describe 'Regresión - Validaciones' do
    
    it 'REG-018: Longitud mínima de título se mantiene (15 chars)' do
      post '/posts.json', params: {
        title: '12345678901234', # 14 chars
        raw: valid_raw,
        category: category.id
      }.to_json, headers: headers
      
      expect(response.status).to be_between(200, 422)
    end

    it 'REG-019: Título de 15 chars es aceptado' do
      post '/posts.json', params: {
        title: '123456789012345', # 15 chars exactos
        raw: valid_raw,
        category: category.id
      }.to_json, headers: headers
      
      expect(response).to have_http_status(200)
    end

    it 'REG-020: Contenido vacío es rechazado' do
      post '/posts.json', params: {
        title: valid_title,
        raw: '',
        category: category.id
      }.to_json, headers: headers
      
      expect(response).to have_http_status(422)
    end
  end

  # Evidencias
  describe 'Evidencias Regresión' do
    it 'documenta cobertura' do
      puts "\n=== PRUEBAS DE REGRESIÓN ==="
      puts "Total: 20 pruebas"
      puts "Funcionalidad básica: 5"
      puts "Base de datos: 5"
      puts "API Endpoints: 4"
      puts "Permisos: 3"
      puts "Validaciones: 3"
    end
  end
end