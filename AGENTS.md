# PROXTEL AI AGENCY — Reglas maestras

Este archivo es la única fuente de verdad de la agencia. Todos los agentes
(Claude Code, Codex, Antigravity) lo leen al arrancar. CLAUDE.md y GEMINI.md
solo lo importan. Si hay conflicto entre este archivo y un AGENTS.md de
proyecto, gana el más cercano al código que se está editando.

Documento de arquitectura aprobado: docs/architecture-v3.md

---

## Identidad

Agencia freelance multi-cliente de Vic. Proyectos independientes por cliente:
CRM a medida, plataformas de trading (TradingView), telefonía IP (Asterisk,
FreePBX, PJSIP, WebRTC), desarrollo web, campañas de Ads.

- PC Windows = máquina maestra: C:\DEV\PROXTEL-AI-AGENCY\
- MacBook Pro = réplica de trabajo: ~/DEV/PROXTEL-AI-AGENCY/
- Sync solo por Git. Prohibido iCloud, Dropbox, OneDrive, Google Drive.

---

## Stack por defecto

- Backend: PHP 8.x + Laravel (por defecto). Node.js cuando el proyecto lo exija.
- Frontend: Blade + Tailwind por defecto. React/Inertia/Vue si el proyecto lo declara.
- BD: MySQL/MariaDB por defecto. PostgreSQL si el proyecto lo declara.
- Trading: librerías TradingView (widget o lightweight-charts según proyecto).
- Telefonía: Asterisk/FreePBX, PJSIP, AMI, dialplan, WebRTC.
- Testing: PHPUnit (backend), Playwright (E2E), Vitest (frontend si aplica).

---

## Comandos estándar

Usar SIEMPRE estos, no inventar otros.

Backend Laravel:

    composer install
    php artisan migrate --seed
    php artisan test
    ./vendor/bin/pint --test

Frontend:

    npm ci
    npm run build
    npm run lint

QA navegador:

    npx playwright test

---

## Ciclo operativo obligatorio por tarea

Ninguna tarea se considera terminada sin pasar los 5 pasos en orden. Evidencia
en .agency-local/audit/T-XXXX/.

1. Claude planifica
   - Entregable: 01-plan.md con alcance, archivos afectados, criterios de aceptación.
2. Codex implementa backend
   - Worktree: task/T-XXXX-api
   - Entregable: 02-codex.md con diff, tests ejecutados y resultado (CODEX_PASS/FAIL/BLOCKED).
3. Antigravity implementa frontend
   - Worktree: task/T-XXXX-ui
   - Entregable: 03-google.md con commits, tests y resultado (FRONTEND_PASS/FAIL/BLOCKED).
4. Claude ejecuta /review
   - Gate técnico obligatorio. Revisa el diff completo de las ramas de implementación.
   - Entregable: 04-claude-review.md con dictamen REVIEW_PASS/FAIL/BLOCKED.
5. Playwright + Vic auditan
   - Playwright valida comportamiento y genera capturas/trazas.
   - Vic revisa las capturas y aprueba visualmente.
   - Entregable: 05-playwright.md con QA_PASS/FAIL/BLOCKED y VISUAL_PASS/FAIL/BLOCKED.
   - Ambos deben ser PASS para cerrar.

Cierre formal: Claude escribe 06-certification.yaml con todos los gates PASS y
evidencias reales. Sin ese archivo, no se solicita merge a main a Vic.

---

## Reglas duras

- Ningún agente escribe directamente en main. Todo pasa por rama + merge autorizado por Vic.
- Si el agente no sabe en qué nivel de permiso está una acción, la trata como Nivel B (ver standards/permissions.md).
- Nunca inventar resultados de tests, auditorías, despliegues o validaciones. Si no se ejecutó, se dice.
- Preservar cambios existentes antes de operaciones potencialmente destructivas (git reset --hard, git clean -fd, force push = Nivel B).
- .agency-local/ y worktrees/ son locales por máquina. Nunca se sincronizan por Git.
- Secretos fuera de Git. .env reales y secrets/ están en .gitignore.
- Si Claude no puede completar el /review obligatorio, se bloquea la promoción a QA. No se sustituye silenciosamente por otra IA.

---

## Skills y agentes on-demand

- El catálogo vive en skills/registry.md. Ninguna skill se activa sin estar registrada.
- Cada proyecto declara sus skills activas en PROJECT-SKILLS.md (raíz del repo del cliente).
- Los agentes cargan solo las skills declaradas en PROJECT-SKILLS.md + las marcadas globales en el registry.
- Regla de promoción: una skill se vuelve global solo tras 3 usos en 2 proyectos distintos y pasar por Skill Factory.

---

## Cuotas y reruteo

Ver tools/quota-log.md. Umbral: 70% semanal = reruteo obligatorio.
Google (Antigravity) absorbe frontend y auditorías visuales para no saturar
Anthropic y OpenAI.

---

## Referencias

- docs/architecture-v3.md — arquitectura aprobada
- standards/permissions.md — niveles A/B
- standards/qa-handoff.md — convención .agency-local/audit/
- standards/concurrency.md — worktrees y ramas
- standards/dual-machine.md — sync PC ↔ Mac
- standards/chatgpt-brief.md — protocolo con ChatGPT
- skills/registry.md — catálogo de skills
- tools/quota-log.md — control de cuotas
