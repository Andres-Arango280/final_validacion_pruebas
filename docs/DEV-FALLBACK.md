# Arranque alternativo de desarrollo (fallback)

Este documento explica cómo arrancar Discourse en desarrollo sin usar `bin/pitchfork`,
usando Puma directamente como servidor de desarrollo. Útil cuando Pitchfork/mold falla.

Requisitos
- Tener las gemas instaladas (`bundle install`).

Uso rápido

1. Ejecutar el script (desde la raíz del repo):

```bash
# ejecutar sin cambiar permisos
bash bin/dev_server

# o marcar ejecutable y ejecutar
chmod +x bin/dev_server
./bin/dev_server
```

Qué hace
- Ejecuta:

```bash
DISABLE_MOLD=1 RAILS_ENV=development bundle exec rails server -p 4200 -b 127.0.0.1
```

- Arranca `Puma` en `127.0.0.1:4200` y es la forma más sencilla de poner la app disponible cuando
  `bin/pitchfork` no puede arrancar la familia de procesos (molds/worker/services).

Notas y advertencias
- Esta es una solución temporal de desarrollo. No reemplaza la supervisión y las optimizaciones
  que proporciona Pitchfork (promociones `mold`, reinicios controlados, servicios como Sidekiq).
- Si el proceso termina con `exit code 137` (killed), puede ser un OOM: prueba a:
  - Cerrar procesos que consuman memoria.
  - Ejecutar sin `DISABLE_MOLD=1` para ver si el problema cambia.
  - Aumentar recursos del entorno donde estás ejecutando (memoria/swap).
- Si necesitas que esto se ejecute automáticamente en tu flujo, podemos añadir un `Makefile` o
  un `Procfile.dev` y un `bin/dev` más completo.

Soporte y próximos pasos
- Si quieres, puedo:
  - Añadir `chmod +x` al archivo en el repositorio (nota: git almacena modo, la copia local puede necesitarlo).
  - Crear un `Makefile` con `make dev` para simplificar el arranque.
  - Investigar y arreglar la causa raíz por la que `bin/pitchfork` falla.

Fin del documento.
