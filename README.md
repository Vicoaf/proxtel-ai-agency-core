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
- Google Antigravity — implementación frontend (la auditoría visual independiente la realiza Vic sobre capturas de Playwright)
- ChatGPT — arquitectura estratégica, sin acceso al repo (V3)
- Playwright MCP — QA funcional en navegador (MCP operativo en V2; participación certificada en el ciclo V3 pendiente de integración con adapter Claude)

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
    standards/        Políticas V3 (permissions, qa-handoff, concurrency, dual-machine, chatgpt-brief, pre-flight-checks)
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

Los 6 subagentes son roles internos ejecutables por el orchestrator V2, no agentes autónomos independientes ni departamentos V3. Los 9 departamentos descritos en la visión original NO están implementados; solo CORE y DEVELOPMENT están parcialmente operativos.

Certificaciones en `tests/integration/*` y `tests/skills/*`.

**Nota:** Área 1.6 certifica el orchestrator y workflow de desarrollo, pero NO certifica la ejecución integral del ciclo de 5 pasos V3. Esa integración se certificará en semana 2 con el adapter de Claude.

---

## Adapters de proveedores

- `adapters/claude/adapter.json`
- `adapters/codex/adapter.json`
- `adapters/antigravity/adapter.json`

Especificación común: `config/schemas/proxtel-provider-adapter.schema.json`.

Estado: Codex y Antigravity certificados en Área 1.2. Claude Code en estado `candidate / not-executed` (v0.1.0, CLI v2.1.268 verificada). El adapter de Claude no se ha ejecutado en modo no-interactivo; el ciclo de 5 pasos no es 100% automatizable hasta certificarlo (previsto semana 2).

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

Flujo obligatorio: desarrollo local → producción, con staging intermedio cuando el proyecto lo requiera (según contrato de despliegue de cada cliente). Nunca deploy directo sin autorización de Vic.

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
- MacBook Pro = réplica de trabajo. Trabaja en ramas `task/T-XXXX-*` o `mac/task-T-XXXX`; una sola máquina escritora activa por rama. Merge a main solo desde PC.
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
- `standards/pre-flight-checks.md` — verificaciones obligatorias antes de iniciar tareas
- `tools/quota-log.md` — control de cuotas de las 3 IAs
- `skills/registry.md` — catálogo documental de skills

---

## Estado actual del Core

El estado consolidado del Core V3 vive en `docs/STATUS.md`. Ese documento es
la fuente de verdad para:

- Qué está operativo ahora.
- Qué está pendiente y por qué.
- Gaps conocidos (departamentos no implementados, skills baseline sin promover).
- Métricas del piloto certificado.
- Próximos pasos concretos de la semana 2.

Antes de empezar cualquier trabajo nuevo, leer `docs/STATUS.md`.

---

## Roadmap y certificación

- `docs/certification-plan.md` — plan de certificación del adapter de Claude y
  hoja de ruta de la semana 2. Define los 10 controles C01-C10, las 5 fases
  A-E, y los criterios go/no-go.
- `docs/lessons/pilot-day4-5.md` — 8 fricciones documentadas del piloto T-0001
  con severidad, mitigación aplicada y acción recomendada.

El piloto T-0001 (landing `piloto-v3`) está certificado en `C:\DEV\piloto-v3\`
con tag `t-0001-certified`. Sirve como referencia de ejecución del ciclo V3
en modo asistido.

---

## Herramientas externas (`_piloto-tools/`)

Directorio oficial para herramientas de QA y utilidades Node que NO deben
contaminar los proyectos vanilla. Vive fuera del Core y fuera de los proyectos
de clientes.

- **Ubicación Windows:** `C:\DEV\_piloto-tools\`
- **Ubicación Mac:** `~/DEV/_piloto-tools/`
- **Contenido:** Playwright (`playwright` + `playwright-core`) + utilidades Node.
- **Qué NO contiene:** código de proyectos, evidencias, secretos.

### Uso desde un proyecto

    cd C:\DEV\<proyecto>\<worktree-de-tarea>
    $env:NODE_PATH = "C:\DEV\_piloto-tools\node_modules"
    node .agency-local\audit\T-XXXX\capture.js

### Por qué existe (fricción F4)

En el piloto T-0001, Playwright estaba solo en la caché de `npx` y no era
accesible desde `require('playwright')`. Ver `docs/lessons/pilot-day4-5.md`
sección F4 para el detalle completo.
