# PROXTEL AI Agency Development System

Sistema maestro de desarrollo asistido por IA para proyectos web, Laravel, CRM,
plataformas de trading, telefonía IP y SaaS.

Estado: V1 (fundamentos) + V2 (motor certificado) + V3 (capa de política en curso)
Máquina maestra: PC Windows. Réplica de trabajo: MacBook Pro. Sync solo por Git.

---

## Objetivo

Mantener en un único repositorio:

- Arquitectura de la agencia (V3).
- Políticas de operación multiagente (V3).
- Skills reutilizables certificadas (V2).
- Agentes y subagentes certificados (V2).
- Adapters de proveedores de IA (V2).
- Workflows certificados (V2).
- Templates de proyectos.
- Scripts de instalación y sincronización.
- Estándares técnicos.
- Documentación de la agencia.

---

## Arquitectura por capas

    CAPA 4 — POLÍTICA (V3)
      AGENTS.md + CLAUDE.md + GEMINI.md
      standards/*.md + tools/quota-log.md
      docs/architecture-v3.md
      → Define CÓMO trabajan las IAs juntas.

    CAPA 3 — ORQUESTACIÓN (V2, certificada)
      agents/development/proxtel-development-orchestrator/
      agents/development/subagents/*
      adapters/{claude,codex,antigravity}/
      workflows/{core,development}/
      → Define QUIÉN ejecuta qué y cómo se coordina.

    CAPA 2 — SKILLS Y CAPACIDADES (V2, certificada)
      skills/core/* (proxtel-skill-auditor, proxtel-skill-creator)
      skills/development/* (auditor-web, estratega-seo, maestro-frontend)
      skills/base/* (creador-skills, inicializador-proyectos)
      skills/_registry/skills-registry.json
      → Define CON QUÉ se ejecuta.

    CAPA 1 — PROYECTOS DE CLIENTES (fuera del Core)
      i-Tkt, TRDStation, PROXTEL PBX, nuevos clientes.
      Cada uno con su PROJECT-SKILLS.md.
      → Define PARA QUÉ se ejecuta.

---

## Herramientas principales

### IDE principal

Visual Studio Code

Perfil: PROXTEL AI Agency

### Inteligencias artificiales

- Claude Code — orquestador, revisión de código, /review (V3)
- OpenAI Codex — implementación backend (V2/V3)
- Google Antigravity — implementación frontend + auditor visual (V2/V3)
- ChatGPT — arquitectura estratégica, sin acceso al repo (V3)
- Playwright MCP — QA funcional en navegador (V3)

### Backend

- PHP 8.x
- Laravel
- MySQL 8.x instalado directamente en la PC
  (no Laragon, no entornos virtuales para la BD)

### Frontend

- HTML
- CSS
- JavaScript
- Bootstrap
- Vite

Las tecnologías adicionales como GSAP, Three.js, Livewire, Vue, React o Tailwind
se incorporan únicamente cuando el proyecto las justifique.

### Base de datos

- MySQL 8.x instalado directamente en Windows
- TablePlus para administración visual
- Laravel Herd únicamente como runtime para PHP/Laravel

---

## Estructura del repositorio

    adapters/         Adaptadores de proveedores IA (claude, codex, antigravity)
    agents/           Agentes y subagentes (orchestrator + 6 subagentes)
    bootstrap/        Scripts de bootstrap dual PC ↔ Mac
    config/           Schemas y configuraciones de la agencia
    docs/             Documentación técnica (arquitectura, lecciones, etc.)
    scripts/          Instalación, sincronización y validación
    skills/           Skills certificadas + registry.md + _registry/skills-registry.json
    standards/        Políticas V3 (permissions, qa-handoff, concurrency, dual-machine, chatgpt-brief)
    templates/        Plantillas de proyectos (crm, landing-page, laravel, saas, website)
    tests/            Tests de integración y certificaciones del V2
    tools/            quota-log.md y utilidades deterministas
    workflows/        Workflows certificados (skill-factory, software-delivery)

Archivos raíz:

    AGENTS.md         Reglas maestras para todas las IAs
    CLAUDE.md         Import @AGENTS.md + notas de Claude Code
    GEMINI.md         Import @AGENTS.md + notas de Antigravity
    .gitattributes    Preservación byte-exact de 345 rutas certificadas
    .gitignore        Exclusión de secretos, .agency-local/, worktrees

---

## Skills (catálogo real)

Detalle completo en `skills/registry.md` y `skills/_registry/skills-registry.json`.

### Aprobadas (project-capable)

- `auditor-web` — auditoría web (v1.0.0, aprobada por auditoría independiente Antigravity en Área 1.7 M3)
- `estratega-seo` — estrategia SEO (v1.0.0, aprobada por auditoría independiente Antigravity en Área 1.7 M3)
- `maestro-frontend` — implementación frontend (v1.0.0, aprobada por auditoría independiente Antigravity en Área 1.7 M3)

### Aprobadas (core)

- `proxtel-skill-auditor` — auditoría de skills (v0.2.0, aprobada por governance transition)
- `proxtel-skill-creator` — creación de skills (v0.1.0, aprobada por auditoría independiente Antigravity R3)

### Baseline (core, no promovidas)

- `creador-skills` — creación de skills (baseline, candidata a evolución)
- `inicializador-proyectos` — inicialización de proyectos (baseline, candidata a integración)

---

## Agentes y workflows certificados

- `proxtel-development-orchestrator` — agente orquestador del desarrollo (aprobado en Área 1.6)
- `proxtel-workflow/software-delivery` — workflow de entrega de software (aprobado en Área 1.6)
- `skill-factory-workflow` — workflow de creación de skills (aprobado en Área 1.4)
- 6 subagentes: architecture-specialist, backend-specialist, database-specialist,
  frontend-specialist, qa-browser-specialist, security-reviewer

Certificaciones en `tests/integration/*` y `tests/skills/*`.

---

## Adapters de proveedores

- `adapters/claude/adapter.json`
- `adapters/codex/adapter.json`
- `adapters/antigravity/adapter.json`

Especificación común: `config/schemas/proxtel-provider-adapter.schema.json`.
Estado: aprobados en Área 1.2.

---

## Política de trabajo (V3)

Antes de modificar proyectos existentes:

1. Inspeccionar.
2. Revisar Git.
3. Auditar.
4. Crear un plan.
5. Implementar cambios controlados.
6. Ejecutar pruebas.
7. Revisar diff.
8. Validar en navegador cuando corresponda.

Ver `AGENTS.md` y `docs/architecture-v3.md` para el ciclo operativo completo de 5 pasos.

---

## Producción

Nunca se despliega directamente a producción sin autorización explícita de Vic.

Flujo obligatorio: desarrollo local → staging → producción.
El merge a main solo ocurre desde la PC maestra con autorización de Vic.

---

## Fuente de verdad

- `AGENTS.md` (V3) — reglas maestras de la agencia.
- `skills/_registry/skills-registry.json` (V2) — estado máquina-legible de las skills.
- `skills/registry.md` (V3) — catálogo documental de skills.
- `docs/architecture-v3.md` (V3) — arquitectura aprobada.

Las ubicaciones globales de Antigravity, Claude Code y Codex se sincronizan
mediante `bootstrap/windows-setup.ps1` y `bootstrap/mac-setup.sh`.

---

## Dual machine

- PC Windows = máquina maestra. Autoriza merges a main.
- MacBook Pro = réplica de trabajo. Solo push a ramas mac/*.
- Sync solo por Git. Prohibido iCloud, Dropbox, OneDrive, Google Drive.
- Detalle completo en `standards/dual-machine.md`.

---

## Documentación relacionada

- `docs/architecture-v3.md` — arquitectura aprobada de las 3 generaciones
- `standards/permissions.md` — niveles de permiso A/B
- `standards/qa-handoff.md` — convención `.agency-local/audit/`
- `standards/concurrency.md` — worktrees y ramas
- `standards/dual-machine.md` — PC ↔ Mac
- `standards/chatgpt-brief.md` — protocolo con ChatGPT
- `tools/quota-log.md` — control de cuotas de las 3 IAs
- `skills/registry.md` — catálogo documental de skills
