# PROXTEL AI AGENCY — Reglas maestras

Única fuente de verdad de la agencia. Todos los agentes (Claude Code, Codex,
Antigravity) lo leen al arrancar. CLAUDE.md y GEMINI.md solo lo importan.
Si hay conflicto entre este archivo y un AGENTS.md de proyecto, gana el más
cercano al código que se está editando.

Arquitectura aprobada: docs/architecture-v3.md
Estado de skills (máquina-legible): skills/_registry/skills-registry.json
Catálogo documental: skills/registry.md

---

## Identidad

Agencia freelance multi-cliente de Vic. Proyectos independientes por cliente:
CRM a medida, plataformas de trading (TradingView), telefonía IP (Asterisk,
FreePBX, PJSIP, WebRTC), desarrollo web, campañas de Ads.

- PC Windows = máquina maestra: C:\DEV\PROXTEL-AI-AGENCY\
- MacBook Pro = réplica de trabajo: ~/DEV/PROXTEL-AI-AGENCY/
- Sync solo por Git. Prohibido iCloud, Dropbox, OneDrive, Google Drive.

---

## Arquitectura por capas

    CAPA 4 — POLÍTICA (V3, este archivo + standards/)
      Define CÓMO trabajan las IAs juntas.

    CAPA 3 — ORQUESTACIÓN (V2, certificada)
      agents/development/proxtel-development-orchestrator/
      agents/development/subagents/*
      adapters/{claude,codex,antigravity}/
      workflows/{core,development}/
      Define QUIÉN ejecuta qué y cómo se coordina.

    CAPA 2 — SKILLS (V2, certificada)
      skills/core/* + skills/development/* + skills/base/*
      skills/_registry/skills-registry.json
      Define CON QUÉ se ejecuta.

    CAPA 1 — PROYECTOS DE CLIENTES
      i-Tkt, TRDStation, PROXTEL PBX, nuevos.
      Cada uno con su PROJECT-SKILLS.md.

---

## Stack por defecto

- Backend: PHP 8.x + Laravel (por defecto). Node.js cuando el proyecto lo exija.
- Frontend: Blade + Tailwind por defecto. React/Inertia/Vue si el proyecto lo declara.
- BD: MySQL 8.x instalado directamente en la PC (no Laragon, no entornos virtuales).
  PostgreSQL si el proyecto lo declara.
- Runtime PHP: Laravel Herd. Administración BD: TablePlus.
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
en .agency-local/audit/T-XXXX/. Ver docs/architecture-v3.md sección 2.

1. Claude planifica → 01-plan.md
2. Codex implementa backend (worktree task/T-XXXX-api) → 02-codex.md
3. Antigravity implementa frontend (worktree task/T-XXXX-ui) → 03-google.md
4. Claude ejecuta /review (gate técnico obligatorio) → 04-claude-review.md
5. Playwright + Vic auditan → 05-playwright.md (QA_PASS + VISUAL_PASS)

Cierre formal: Claude escribe 06-certification.yaml con todos los gates PASS y
evidencias reales. Sin ese archivo, no se solicita merge a main a Vic.

El orchestrator V2 (proxtel-development-orchestrator) implementa este ciclo a
nivel de agentes. El ciclo V3 es la política; el orchestrator V2 es la ejecución.

---

## Reglas duras

- Ningún agente escribe directamente en main. Todo pasa por rama + merge autorizado por Vic.
- Si el agente no sabe en qué nivel de permiso está una acción, la trata como Nivel B (standards/permissions.md).
- Nunca inventar resultados de tests, auditorías, despliegues o validaciones.
- Preservar cambios existentes antes de operaciones destructivas (git reset --hard, git clean -fd, force push = Nivel B).
- .agency-local/ y worktrees/ son locales por máquina. Nunca se sincronizan por Git.
- Secretos fuera de Git. .env reales y secrets/ están en .gitignore.
- Si Claude no puede completar el /review obligatorio, se bloquea la promoción a QA. No se sustituye silenciosamente por otra IA.
- No tocar los archivos protegidos en .gitattributes con -text -eol. Son certificaciones byte-exact del V2.

---

## Skills y agentes on-demand

- Catálogo documental: skills/registry.md. Estado máquina-legible: skills/_registry/skills-registry.json.
- Cada proyecto declara sus skills activas en PROJECT-SKILLS.md (raíz del repo del cliente).
- Los agentes cargan solo las skills declaradas en PROJECT-SKILLS.md + las marcadas globales en el registry.
- Regla de promoción: una skill se vuelve global solo tras 3 usos en 2 proyectos distintos y pasar por Skill Factory (proxtel-skill-creator).
- Template de PROJECT-SKILLS.md: templates/PROJECT-SKILLS.md.

---

## Adapters de proveedores

- adapters/claude/adapter.json
- adapters/codex/adapter.json
- adapters/antigravity/adapter.json

Especificación: config/schemas/proxtel-provider-adapter.schema.json.
Estado: aprobados en Área 1.2. No modificar sin certificación.

---

## Cuotas y reruteo

Ver tools/quota-log.md. Umbral: 70% semanal = reruteo obligatorio.
Google (Antigravity) absorbe frontend y auditorías visuales para no saturar
Anthropic y OpenAI.

---

## Referencias

- docs/architecture-v3.md — arquitectura aprobada V1+V2+V3
- README.md — overview del sistema completo
- standards/permissions.md — niveles A/B
- standards/qa-handoff.md — convención .agency-local/audit/
- standards/concurrency.md — worktrees y ramas
- standards/dual-machine.md — sync PC ↔ Mac
- standards/chatgpt-brief.md — protocolo con ChatGPT
- skills/registry.md — catálogo documental
- skills/_registry/skills-registry.json — estado máquina-legible V2
- tools/quota-log.md — control de cuotas
- templates/PROJECT-SKILLS.md — template para proyectos de clientes
