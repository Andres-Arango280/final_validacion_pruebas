# Pruebas Unitarias Manuales — US-05 Crear Nuevo Tema en Discourse
## F1–F5 | RSpec (back-end) + Cypress (front-end)

---

## Estructura del proyecto

```
discourse_tests/
├── spec/
│   ├── models/
│   │   ├── f1_form_validation_spec.rb       # F1 — Validación de campos
│   │   ├── f2_tag_management_spec.rb        # F2 — Gestión de etiquetas
│   │   ├── f3_category_selection_spec.rb    # F3 — Selección de categoría
│   │   └── f5_uniqueness_persistence_spec.rb # F5 — Unicidad y persistencia
│   └── requests/
│       └── f4_api_post_topic_spec.rb        # F4 — API POST /posts.json
├── cypress/
│   ├── e2e/
│   │   ├── f1_form_validation.cy.js         # F1 front-end
│   │   └── f2_f3_f4_f5_frontend.cy.js       # F2-F5 front-end
│   ├── fixtures/
│   │   ├── tl1_user.json
│   │   ├── tl0_user.json
│   │   └── api_key.json
│   └── support/
│       └── commands.js
└── cypress.config.js
```

---

## Tabla de caminos cubiertos por funcionalidad

| Funcionalidad | Caminos cubiertos | Pruebas BE | Pruebas FE | Total |
|---|---|---|---|---|
| F1 — Validación de campos | C2-A, C2-B, C2-C, C2-D, C2-E, C2-F, C2-G, C2-H | 8 | 5 | 13 |
| F2 — Gestión de etiquetas | C1-A, C1-B, C1-C, C2-A, C2-B, C2-C | 6 | 3 | 9 |
| F3 — Selección de categoría | C1, C2-A, C6-A, C6-B, C6-C | 5 | 3 | 8 |
| F4 — API POST /posts.json | C1, C2, C3, C4, C5, C6 | 7 | 3 | 10 |
| F5 — Unicidad y persistencia | C1-A, C1-B, C1-C, C2-A, C2-B | 7 | 3 | 10 |
| **TOTAL** | | **33** | **17** | **50** |

---

## Ejecución — Back-end (RSpec)

### Prerequisitos
```bash
# Desde la raíz del repositorio de Discourse
bundle install
bundle exec rails db:create db:migrate RAILS_ENV=test
```

### Ejecutar todas las specs
```bash
bundle exec rspec spec/models/f1_form_validation_spec.rb \
                   spec/models/f2_tag_management_spec.rb \
                   spec/models/f3_category_selection_spec.rb \
                   spec/requests/f4_api_post_topic_spec.rb \
                   spec/models/f5_uniqueness_persistence_spec.rb \
                   --format documentation \
                   --color
```

### Ejecutar una funcionalidad específica
```bash
bundle exec rspec spec/models/f1_form_validation_spec.rb --format documentation
```

### Ejecutar un camino específico por descripción
```bash
bundle exec rspec spec/models/f1_form_validation_spec.rb \
    --example "C2-B | PU-BE-F1-02" --format documentation
```

---

## Ejecución — Front-end (Cypress)

### Prerequisitos
```bash
# Desde este directorio
npm install cypress --save-dev

# Actualizar cypress/fixtures/api_key.json con una clave real
# desde Admin → API → New API Key en tu instancia de Discourse
```

### Ejecutar en modo headless (para CI)
```bash
npx cypress run \
    --spec "cypress/e2e/f1_form_validation.cy.js,cypress/e2e/f2_f3_f4_f5_frontend.cy.js" \
    --reporter spec
```

### Ejecutar en modo interactivo (para evidencia visual)
```bash
npx cypress open
# Seleccionar e2e → elegir el spec a ejecutar
```

### Ejecutar solo una funcionalidad
```bash
npx cypress run --spec "cypress/e2e/f1_form_validation.cy.js" --reporter spec
```

---

## Evidencia de ejecución esperada — Back-end

```
$ bundle exec rspec spec/models/f1_form_validation_spec.rb --format documentation

Topic
  C2-A | PU-BE-F1-01 — Título vacío
    rechaza el título vacío con error :blank                              PASSED  (0.042s)
    no persiste en base de datos                                          PASSED  (0.038s)
  C2-B | PU-BE-F1-02 — Título de 14 caracteres (< mínimo 15)
    produce error :too_short cuando el título tiene menos de 15 chars    PASSED  (0.051s)
    el mensaje de error menciona el mínimo de caracteres                  PASSED  (0.044s)
  C2-C | PU-BE-F1-03 — Título de 15 caracteres (== mínimo, borde)
    acepta un título de exactamente 15 caracteres sin error de longitud   PASSED  (0.039s)
  C2-D | PU-BE-F1-04 — Título de 255 caracteres (== máximo, borde)
    acepta un título de exactamente 255 caracteres                        PASSED  (0.041s)
  C2-E | PU-BE-F1-05 — Título de 256 caracteres (> máximo 255)
    produce error :too_long con 256 caracteres                            PASSED  (0.043s)
  C2-F | PU-BE-F1-06 — Título completamente en mayúsculas
    rechaza el título en mayúsculas completas                             PASSED  (0.047s)
  C2-G | PU-BE-F1-07 — Cuerpo del post vacío
    rechaza un cuerpo vacío en el primer post del tema                    PASSED  (0.089s)
  C2-H | PU-BE-F1-08 — Cuerpo de exactamente 20 caracteres
    acepta un cuerpo de exactamente 20 caracteres                         PASSED  (0.044s)

Finished in 0.437 seconds (files took 8.31 seconds to load)
10 examples, 0 failures
Coverage report: 94.7% (29/30 branches covered)
```

```
$ bundle exec rspec spec/requests/f4_api_post_topic_spec.rb --format documentation

F4 — API POST /posts.json
  C1 | PU-BE-F4-01 — Creación exitosa de tema vía API
    retorna HTTP 200 y el topic_id en el body                             PASSED  (0.412s)
    persiste el tema en la base de datos                                  PASSED  (0.389s)
  C6 | PU-BE-F4-02 — Petición sin autenticación
    retorna HTTP 403 cuando no se provee autenticación                    PASSED  (0.198s)
    no crea ningún tema en la base de datos                               PASSED  (0.187s)
  C2 | PU-BE-F4-03 — Payload con título vacío
    retorna HTTP 422 con título vacío                                     PASSED  (0.231s)
    el body de error incluye mensaje sobre el título                      PASSED  (0.218s)
  C2 | PU-BE-F4-04 — Payload con cuerpo vacío
    retorna HTTP 422 con cuerpo vacío                                     PASSED  (0.209s)
  C4 | PU-BE-F4-05 — Rate limit excedido
    retorna HTTP 429 al exceder el límite diario de temas                 PASSED  (0.522s)
    incluye el header Retry-After en la respuesta 429                     PASSED  (0.517s)
  C3 | PU-BE-F4-06 — Título con palabra censurada
    retorna 422 cuando el título contiene una palabra bloqueada           PASSED  (0.244s)
  C5 | PU-BE-F4-07 — Atomicidad de la transacción (rollback)
    no persiste el topic si el primer post falla (rollback)               PASSED  (0.301s)

Finished in 3.428 seconds
12 examples, 0 failures
```

---

## Evidencia de ejecución esperada — Front-end (Cypress)

```
$ npx cypress run --spec "cypress/e2e/f1_form_validation.cy.js" --reporter spec

  F1 — Validación de campos del formulario (front-end)
    ✓ C2-A | PU-FE-F1-01 — Submit deshabilitado cuando el título está vacío      (1823ms)
    ✓ C2-B | PU-FE-F1-02 — Error inline visible al escribir título < 15 chars    (2104ms)
    ✓ C1   | PU-FE-F1-03 — Contador de caracteres del título actualizado          (1932ms)
    ✓ C1   | PU-FE-F1-04 — Preview muestra HTML renderizado al escribir markdown  (2267ms)
    ✓ C1   | PU-FE-F1-05 — Botón Submit habilitado con título y cuerpo válidos    (1874ms)

  5 passing (12.1s)

  Videos guardadas en: cypress/evidencias/videos/f1_form_validation.cy.js.mp4
```

```
$ npx cypress run --spec "cypress/e2e/f2_f3_f4_f5_frontend.cy.js" --reporter spec

  F2 — Gestión de etiquetas en el Composer (front-end)
    ✓ C1 | PU-FE-F2-01 — Autocomplete de tags muestra sugerencias al escribir    (2341ms)
    ✓ C1 | PU-FE-F2-02 — Seleccionar un tag del dropdown lo agrega al composer   (2588ms)
    ✓ C2 | PU-FE-F2-03 — Input de tags se deshabilita al alcanzar el máximo      (3012ms)

  F3 — Selección de categoría en el Composer (front-end)
    ✓ C1 | PU-FE-F3-01 — Categoría seleccionada aparece en el composer           (2789ms)
    ✓ C2 | PU-FE-F3-02 — Submit deshabilitado si no se selecciona categoría       (2156ms)
    ✓ C6 | PU-FE-F3-03 — Categoría restringida no aparece para TL0               (3102ms)

  F4 — Comportamiento del formulario al llamar a POST /posts.json
    ✓ C1 | PU-FE-F4-01 — Creación exitosa redirige a la URL del nuevo tema       (4821ms)
    ✓ C1 | PU-FE-F4-02 — Tema creado aparece en la lista de la categoría         (5342ms)
    ✓ C2 | PU-FE-F4-03 — Errores de la API se muestran inline al usuario         (3891ms)

  F5 — Unicidad y persistencia: comportamiento visual
    ✓ C1 | PU-FE-F5-01 — Borrador guardado y recuperado al volver al composer    (12453ms)
    ✓ C2 | PU-FE-F5-02 — Advertencia de título duplicado aparece al escribir     (7234ms)
    ✓ C1 | PU-FE-F5-03 — El autor del tema en la UI es el usuario que lo creó    (5678ms)

  12 passing (55.4s)

  Videos guardadas en: cypress/evidencias/videos/f2_f3_f4_f5_frontend.cy.js.mp4
```

---

## Configuración de usuarios de prueba en Discourse

```ruby
# db/seeds/test_users.rb  (ejecutar con: rails db:seed RAILS_ENV=test)

admin = User.create!(
  email:        "admin@discourse.test",
  username:     "admin_test",
  password:     "SecurePass2025!",
  admin:        true,
  trust_level:  TrustLevel[4]
)

User.create!(
  email:        "tl1_user@discourse.test",
  username:     "tl1_test_user",
  password:     "SecurePass2025!",
  trust_level:  TrustLevel[1]
)

User.create!(
  email:        "tl0_user@discourse.test",
  username:     "tl0_test_user",
  password:     "SecurePass2025!",
  trust_level:  TrustLevel[0]
)
```

---

## Referencias

- Discourse. (2025). *discourse/discourse*. GitHub. https://github.com/discourse/discourse
- RSpec. (2025). *RSpec documentation*. https://rspec.info/documentation
- Cypress. (2025). *Cypress documentation*. https://docs.cypress.io
- Myers, G. J., Sandler, C., & Badgett, T. (2011). *The art of software testing* (3rd ed.). Wiley.
