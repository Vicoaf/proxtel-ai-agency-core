# PROXTEL AI AGENCY — Reglas maestras

Documento maestro de política V3 de la agencia. Todos los agentes (Claude Code, Codex, Antigravity) deben aplicar estas reglas al iniciar su trabajo. CLAUDE.md y GEMINI.md solo lo importan.

Si existe un AGENTS.md de proyecto, sus reglas locales se aplican conforme al orden de autoridad definido en este documento. Ninguna regla local puede anular restricciones superiores.

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
- La Mac puede desarrollar y publicar ramas `task/T-XXXX-*` y `mac/*`. No está limitada exclusivamente a `mac/*`.
- Una rama solo puede tener una máquina escritora activa a la vez. Nunca se trabaja simultáneamente sobre la misma rama desde PC y Mac.
- El merge y push a `main` se realizan exclusivamente desde la PC Windows, con autorización expresa de Vic.

---

## Orden de autoridad

La precedencia obligatoria de las reglas de la agencia es:

1. **Restricciones de seguridad V3:** políticas de seguridad, permisos, separación de responsabilidades, gates obligatorios y autorizaciones humanas.
2. **Contratos certificados V2:** interfaces, schemas, adapters, workflows, skills, certificaciones y comportamiento validado del motor existente.
3. **Reglas locales del proyecto:** condiciones y restricciones propias de cada repositorio de cliente, siempre que sean compatibles con los niveles anteriores.
4. **Especializaciones locales:** convenciones, instrucciones y preferencias específicas de implementación, subordinadas a las reglas superiores.

Un `AGENTS.md` local solo puede **ESPECIALIZAR** políticas. Nunca puede anular restricciones de seguridad, autorizaciones de Vic, gates obligatorios ni contratos certificados V2.

Los archivos protegidos mediante `.gitattributes` con `-text -eol` son **inmutables salvo certificación formal**. Esta configuración evita transformaciones de texto y finales de línea, pero no constituye un bloqueo físico de escritura. La prohibición de modificar los archivos certificados sigue siendo obligatoria.

Ante cualquier contradicción entre niveles de autoridad, el agente debe detener la operación afectada, documentar el conflicto y solicitar su resolución. No puede reinterpretar una regla inferior para evadir una restricción superior.

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
4. Claude ejecuta /review (gate técnico obligatorio) → 04-claude-review.md con REVIEW_PASS
5. Playwright realiza QA funcional y genera capturas; Vic realiza la auditoría visual humana independiente sobre esas capturas → 05-playwright.md (QA_PASS + VISUAL_PASS)

Antigravity es el implementador frontend. Puede realizar verificaciones técnicas de su implementación, pero **NO puede emitir la aprobación visual independiente sobre su propio trabajo**. La decisión VISUAL_PASS, VISUAL_FAIL o VISUAL_BLOCKED corresponde exclusivamente a Vic.

Cierre formal: Claude escribe 06-certification.yaml con todos los gates aplicables respaldados por evidencias reales. El archivo debe incluir obligatoriamente:

- `candidate_commit`: SHA exacto del commit integrado que fue revisado y probado.
- `claude_review`: estado REVIEW_PASS y referencia verificable a 04-claude-review.md.
- `playwright_qa`: estado QA_PASS y referencia a 05-playwright.md.
- `visual_review_vic`: estado VISUAL_PASS emitido expresamente por Vic sobre las capturas de Playwright.
- `acceptance_vic`: estado APPROVED mediante aceptación expresa de Vic, nunca inferida del QA de Playwright ni de otra IA.

Claude debe verificar que el commit candidato corresponde exactamente al código revisado y probado, y que no existen modificaciones posteriores que invaliden las evidencias.

Sin 06-certification.yaml completo, válido y verificado, no se solicita autorización de merge a main a Vic.

El orchestrator V2 (proxtel-development-orchestrator) es el motor existente de orquestación certificado. El ciclo V3 establece la política operativa de cinco pasos, pero su ejecución automatizada no está certificada mientras el adapter de Claude permanezca en estado candidate / not-executed.

El ciclo V3 es la política; el orchestrator V2 es el motor existente. No se debe asumir que el motor V2 ya ejecuta automáticamente todos los gates V3.

---

## Reglas duras

- Ningún agente escribe directamente en main. Todo pasa por rama + merge autorizado por Vic.
- Si el agente no sabe en qué nivel de permiso está una acción, la trata como Nivel B (standards/permissions.md).
- Nunca inventar resultados de tests, auditorías, despliegues o validaciones.
- Preservar cambios existentes antes de operaciones destructivas. `git reset --hard` y `git clean -fd` = Nivel B. `git push --force` está PROHIBIDO de forma absoluta sobre `main` y sobre cualquier rama compartida, incluso con aprobación de Vic. Solo se permite `--force-with-lease` en ramas estrictamente personales no compartidas.
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

Estado: Codex y Antigravity certificados en Área 1.2. Claude Code está en estado `candidate / not-executed` (v0.1.0): instalado y verificado (v2.1.268), pero el adapter no se ha ejecutado aún en modo no-interactivo.

No se puede automatizar el ciclo completo de 5 pasos hasta certificar el adapter de Claude Code y validar su integración con los gates V3.

No modificar adapters ni contratos V2 sin certificación formal.

---

## Cuotas y reruteo

Ver tools/quota-log.md y docs/architecture-v3.md sección 5.

El reruteo se determina por la cuota **RESTANTE (R)**, no por el porcentaje consumido ni por un umbral semanal fijo.

R es el menor porcentaje de cuota restante entre las ventanas que limitan al recurso.

| Cuota restante R | Estado operativo | Acción |
|---|---|---|
| R > 30% | Normal | Asignaciones habituales |
| 15–30% | Reserva | No iniciar tareas grandes; priorizar pendientes |
| 5–15% | Crítico | Solo trabajo indispensable y cierre |
| R ≤ 5% | Protección | Detener nuevas asignaciones |
| Límite real alcanzado | Bloqueo | Reasignar trabajo permitido o esperar restablecimiento |

Cuando un porcentaje coincida con el límite entre dos categorías, prevalece el estado más restrictivo.

Reglas por proveedor:

- **Claude Sonnet:** modelo predeterminado para orquestación y revisión de código.
- **Claude Opus:** reservado exclusivamente para decisiones de arquitectura compleja que justifiquen su uso. Suspender preventivamente Opus cuando R ≤ 30%.
- **Claude Code:** cuando Sonnet alcance R ≤ 20%, reservar capacidad para coordinación mínima y /review. Si Claude no puede completar el /review obligatorio, se bloquea la promoción a QA. No se sustituye silenciosamente por otra IA.
- **Codex:** implementador backend habitual. Cuando R ≤ 20%, no iniciar tareas técnicas nuevas de gran alcance. Si se agota su cuota, conservar ramas, commits y evidencias sin declarar terminado el trabajo pendiente.
- **Antigravity:** absorbe prioritariamente la implementación frontend y el apoyo técnico a las auditorías visuales, utilizando la cuota separada de Google. Puede inspeccionar y corregir su implementación, pero no emitir su aprobación visual independiente. Vic realiza la auditoría visual final sobre las capturas de Playwright.
- **Playwright MCP:** mantiene el gate de QA funcional obligatorio independientemente de cualquier redistribución de trabajo entre proveedores.

El reruteo nunca puede eliminar los gates de seguridad, revisión de código, QA funcional ni aprobación visual humana establecidos en V3.

No se habilitan automáticamente créditos adicionales, APIs de pago por consumo ni cambios de suscripción. Todo consumo extraordinario requiere autorización expresa de Vic.

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

AGENTS-OK
