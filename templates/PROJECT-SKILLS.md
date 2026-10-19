# PROJECT-SKILLS.md — Template

Template para la raíz de cada repositorio de cliente. Copiar este archivo a
`<repo-del-cliente>/PROJECT-SKILLS.md` y rellenar.

Los agentes (Claude Code, Codex, Antigravity) consultan este archivo como referencia de selección. La activación real es on-demand, verificada por cada CLI según su propia mecánica de skills locales. Este archivo declara la intención, no fuerza la carga.

Ver `<AGENCY_CORE>/skills/registry.md` para el catálogo completo.

El estado autorizado de cada skill debe verificarse en `<AGENCY_CORE>/skills/_registry/skills-registry.json`, fuente máquina-legible del Core V2.

---

# PROYECTO: <nombre-del-proyecto>

Cliente: <nombre-cliente>
Tipo: <CRM | trading | web | PBX | SaaS | landing | otro>
Stack declarado: <Laravel + MySQL | Node + Postgres | ...>
Rama base: main
Ciclo V3 activo: <sí | no (proyecto legacy pre-V3)>

Si el proyecto utiliza `develop` como rama base, debe documentarse explícitamente en la sección "Reglas locales del proyecto". La rama predeterminada es `main`.

El estado dinámico (máquina, rama activa, tarea en curso) vive en `.agency-local/briefs/STATE-BRIEF.txt`, no aquí.

---

## Skills activas en este proyecto

Skills que los agentes pueden utilizar únicamente cuando su estado y alcance estén autorizados en `<AGENCY_CORE>/skills/_registry/skills-registry.json`.

Cada skill debe declarar su ID exacto y el campo obligatorio **Estado autorizado en Core**, utilizando el estado real registrado en el JSON V2.

Estados reconocidos: `approved`, `baseline-existing`, `quarantine`.

Una skill declarada aquí no adquiere nuevos permisos ni puede promoverse localmente. Las skills con estado `baseline-existing` NO pueden activarse sin autorización expresa de Vic. Las skills en `quarantine` no están autorizadas para su activación ordinaria.

- <skill-id-1> (ej. auditor-web)
  - Estado autorizado en Core: <skill-id-1> — <approved | baseline-existing | quarantine>

- <skill-id-2> (ej. maestro-frontend)
  - Estado autorizado en Core: <skill-id-2> — <approved | baseline-existing | quarantine>

---

## Skills explícitamente NO activas

Skills del catálogo que NO aplican a este proyecto. Motivo entre paréntesis.

Cada entrada debe conservar su ID exacto y estado autorizado en Core, aunque esté excluida localmente.

- <skill-id-3> (ej. estratega-seo — proyecto interno sin objetivo SEO)
  - Estado autorizado en Core: <skill-id-3> — <approved | baseline-existing | quarantine>

- <skill-id-4> (ej. creador-skills — no se crearán skills nuevas aquí)
  - Estado autorizado en Core: <skill-id-4> — <approved | baseline-existing | quarantine>

---

## Candidatas (en observación)

Skills que se están usando manualmente en este proyecto y podrían promoverse a globales tras un mínimo de 3 usos satisfactorios en al menos 2 proyectos independientes. Ver `<AGENCY_CORE>/skills/registry.md`.

Cada uso debe corresponder a una tarea identificable `T-XXXX` con evidencia verificable. Los reintentos de una misma tarea no cuentan como usos independientes.

Cada candidata debe indicar su ID exacto y el campo obligatorio **Estado autorizado en Core**, obtenido de `<AGENCY_CORE>/skills/_registry/skills-registry.json`. La observación no concede autorización de ejecución ni altera el estado de la skill.

| Skill | Tareas donde se usó (T-XXXX) | Nº de usos | Motivo de la observación |
|---|---|---|---|
| <skill-id> (Estado autorizado en Core: <estado>) | <T-XXXX, T-YYYY> | <número> | <motivo> |

La promoción global requiere además pruebas satisfactorias, parametrización, ausencia de secretos, versión, responsable de mantenimiento, revisión técnica de Claude y aprobación expresa de Vic. No es automática.

---

## Reglas locales del proyecto

Reglas que especializan o complementan AGENTS.md global.

Las reglas locales pueden complementar o concretar AGENTS.md global. No pueden anular restricciones de seguridad, autorizaciones, gates obligatorios ni contratos certificados V2.

En caso de conflicto, prevalece el orden de autoridad establecido en `<AGENCY_CORE>/AGENTS.md`. El agente debe detener la operación afectada y solicitar resolución, sin modificar ni reinterpretar los contratos certificados.

- <regla-1> (ej. no usar Tailwind, usar Bootstrap por decisión del cliente)
- <regla-2> (ej. todas las migraciones requieren aprobación del DBA del cliente)
- <regla-3> (ej. producción es AWS, staging es DigitalOcean, no confundir credenciales)

---

## Contexto adicional del cliente

Información que los agentes deben conocer al arrancar cada tarea.

- Idioma del producto: <es | en | ambos>
- Zona horaria: <UTC | America/Mexico_City | ...>
- Restricciones regulatorias: <ninguna | GDPR | MiFID | ...>
- Contacto técnico del cliente: <nombre-email>

---

## Notas de adopción V3

Si el proyecto es legacy (existía antes del ciclo V3), documentar aquí:

- Fecha de estabilización (tarea en curso cerrada): <fecha>
- Fecha de creación de este PROJECT-SKILLS.md: <fecha>
- Primera tarea ejecutada con ciclo V3: <T-XXXX>
- Estado de adopción V3: <no-iniciado | estabilizado | activo>

Ver `<AGENCY_CORE>/docs/architecture-v3.md` sección 7.8 para condiciones de transición.

PROJECT-SKILLS-OK
