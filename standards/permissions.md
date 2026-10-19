# Niveles de permisos (A / B)

Define qué puede hacer un agente sin preguntar y qué requiere aprobación
explícita de Vic. Es la primera línea de defensa contra acciones destructivas
o caras.

Documento relacionado: docs/architecture-v3.md sección 3.4 (matriz de permisos)

---

## Nivel A — Autónomo (sin aprobación de Vic)

Permitido en worktree o rama local, sin pedir permiso:

- Crear, editar y borrar archivos dentro de worktrees/task-NNN-*/.
- Ejecutar composer install, npm ci, npm run build, npm run lint.
- Ejecutar php artisan test, ./vendor/bin/pint, npx playwright test.
- Leer cualquier archivo del repo.
- Crear commits en la rama de tarea.
- Instalar dependencias dev (--save-dev, --dev).
- Crear ramas locales de tarea (task/T-XXXX-api, task/T-XXXX-ui).

---

## Nivel B — Requiere aprobación explícita de Vic

Requiere APROBADO de Vic antes de ejecutar:

- Push a main o a cualquier rama protegida.
- Merge de rama de tarea a main.
- Ejecutar migraciones de BD (php artisan migrate, migrate:rollback, migrate:fresh).
- Instalar dependencias de producción (composer require, npm install <pkg>).
- Modificar .env, config/*, policies/, middleware/ de seguridad.
- Cualquier operación que consuma dinero: deploy, API de pago, SaaS, envíos.
- git reset --hard, git clean -fd, git push --force, git branch -D.
- Acceder a producción o a datos reales de cliente.
- Modificar AGENTS.md, CLAUDE.md, GEMINI.md o cualquier archivo de standards/.
- Modificar skills/registry.md.
- Crear o modificar 06-certification.yaml sin evidencia completa.

---

## Regla dura

Si el agente no sabe con certeza en qué nivel está una acción, la trata como
Nivel B y pide aprobación. La ambigüedad nunca autoriza; siempre frena.

---

## Cómo se pide aprobación (Nivel B)

El agente escribe en el chat o en tasks/NNN-approval-request.md:

    NIVEL B — Solicitud de aprobación
    Acción: <comando o cambio exacto>
    Motivo: <por qué es necesario>
    Riesgo: <qué puede romperse>
    Rollback: <cómo se revierte>

Vic responde APROBADO o RECHAZADO y esa respuesta se archiva en
tasks/NNN-approval-log.md.

---

## Registro de aprobaciones

Cada aprobación de Nivel B queda registrada en la evidencia de la tarea
(tasks/NNN-approval-log.md) con:

- Fecha y hora.
- Acción solicitada.
- Motivo declarado por el agente.
- Decisión de Vic (APROBADO / RECHAZADO).
- Motivo de la decisión cuando aplique.
