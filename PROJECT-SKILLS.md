# PROYECTO: PROXTEL AI AGENCY (Core)

Este archivo declara las skills activas del Core. Los proyectos de clientes tienen su propio `PROJECT-SKILLS.md` en la raíz de su repo.

Stack declarado: Markdown + PowerShell + JSON (sistema de agencia, no proyecto de cliente).

## Skills activas del Core

- `proxtel-skill-auditor` (core) — auditoría de skills
- `proxtel-skill-creator` (core) — creación de skills

## Skills de development disponibles (baseline, no certificadas aún)

- `auditor-web` (development)
- `estratega-seo` (development)
- `maestro-frontend` (development)

Estas tres requieren pasar por `proxtel-skill-creator` + `proxtel-skill-auditor` antes de ser canónicas. Ver `skills/registry.md`.

## Reglas locales del proyecto

- Aplican las de `AGENTS.md` del Core.
- Este repo no se despliega a producción. Es la fuente maestra de reglas.
- Los proyectos de clientes clonan skills desde aquí vía `scripts/sync-skills.ps1`.
