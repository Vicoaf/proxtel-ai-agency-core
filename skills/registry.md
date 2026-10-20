# Registry de skills — catálogo documental V3

Única fuente de verdad documental del catálogo. Para el estado máquina-legible
(usado por agentes y validaciones), ver skills/_registry/skills-registry.json.

Relación: este archivo documenta; skills-registry.json certifica. Si discrepan,
gana skills-registry.json (V2 certificado).

---

## Skills aprobadas (project-capable)

Skills listas para activarse en proyectos de clientes. Estado V2: approved.

| Skill | Área | Distribución | Propósito | Certificación |
|---|---|---|---|---|
| auditor-web | development | project-capable | Auditoría web completa (visual, DOM, accesibilidad básica) | v1.0.0 aprobada por auditoría independiente Antigravity en Área 1.7 M3. SHA256=1A72100200468DDDF182FAC82BCF2B79FB2406CF807C3342457CFF2E1231A288 |
| estratega-seo | development | project-capable | Estrategia SEO y análisis de posicionamiento | v1.0.0 aprobada por auditoría independiente Antigravity en Área 1.7 M3. SHA256=873280C5F14F2791493A2400BDCC7363B665F35586533BEF39918AF0589431A3 |
| maestro-frontend | development | project-capable | Implementación frontend de alta calidad | v1.0.0 aprobada por auditoría independiente Antigravity en Área 1.7 M3. SHA256=1428DF08FC7D0D0CF30E4D710D0D6C7023F2798C3BD6D616A279D248A5BC3C2A |

---

## Skills aprobadas (core)

Skills internas de la agencia. Estado V2: approved. No se activan en proyectos
de clientes sin autorización expresa de Vic.

| Skill | Área | Distribución | Propósito | Certificación |
|---|---|---|---|---|
| proxtel-skill-auditor | core | core | Auditoría formal de skills y certificaciones | v0.2.0 aprobada por governance transition. Decision histórica ADAPT resuelta; governance fresh review APPROVED (C40-V1) |
| proxtel-skill-creator | core | core | Creación y evaluación de skills (Skill Factory) | v0.1.0 aprobada por auditoría independiente Antigravity R3 (PROXTEL-AREA-1.3-CREATOR-INDEPENDENT-AUDIT-R3-V1) |

---

## Politica de skills legacy (base/)

Las versiones legacy de las skills (antes en skills/base/) fueron movidas a
skills/_legacy/base/ el 2026-10-20 para evitar duplicacion con skills/development/.

**Regla:** development/ es canonico. _legacy/base/ es evidencia historica de
provenance. Ningun agente carga _legacy/ automaticamente.

## Politica de skills legacy (base/)

Las versiones legacy de las skills (antes en skills/base/) fueron movidas a
skills/_legacy/base/ el 2026-10-20 para evitar duplicacion con skills/development/.

**Regla:** development/ es canonico. _legacy/base/ es evidencia historica de
provenance. Ningun agente carga _legacy/ automaticamente.

## Skills baseline (core, no promovidas)

Skills existentes preservadas como baseline. Pueden evolucionar mediante
proxtel-skill-creator, pero hoy no están certificadas para uso autónomo.

| Skill | Área | Distribución | Propósito | Estado |
|---|---|---|---|---|
| creador-skills | core | core | Creación de skills (predecesor de proxtel-skill-creator) | baseline-existing. Candidata a evolución |
| inicializador-proyectos | core | core | Inicialización de proyectos nuevos | baseline-existing. Candidata a integración con workflows de ciclo de vida |

---

## Candidatas (en observación)

Skills manuales aún no promovidas. Requieren 3 usos en 2 proyectos distintos.

| Skill | Veces usada manual | Proyectos | Próximo paso |
|---|---|---|---|
| — | — | — | — |

---

## Regla de promoción a global

Una skill se convierte en global solo si cumple las tres condiciones:

1. Se resolvió manualmente ≥3 veces en tareas identificables (no reintentos).
2. En ≥2 proyectos distintos.
3. Pasó por Skill Factory: creación vía proxtel-skill-creator, revisión vía
   proxtel-skill-auditor, tests, y aprobación de Vic.

Mientras no cumpla las tres, se anota en PROJECT-SKILLS.md del proyecto como
candidata, NO en este registry.

### Nota sobre baseline y approved

Las skills baseline (creador-skills, inicializador-proyectos) NO son
equivalentes a approved. Baseline significa que existen y se preservan, pero
no están autorizadas para uso autónomo en proyectos de clientes sin aprobación
expresa de Vic. Solo las marcadas approved (auditor-web, estratega-seo,
maestro-frontend, proxtel-skill-auditor, proxtel-skill-creator) son
project-capable o core operativas.

La autoridad final del estado de cada skill reside en
skills/_registry/skills-registry.json (certificado V2). Este documento es
documental. Si discrepan, gana el JSON.

La promoción a global NO implica activación automática. Toda skill se activa
on-demand según la sección 6.3 de docs/architecture-v3.md.

---

## Cómo se activa una skill en un proyecto

En la raíz del repo del cliente, crear PROJECT-SKILLS.md copiando el template
de templates/PROJECT-SKILLS.md. Ejemplo mínimo:

    # Skills activas en este proyecto
    - auditor-web
    - maestro-frontend

    # Skills explícitamente NO activas
    - estratega-seo  (proyecto interno, sin objetivo SEO)

Los agentes consultan este archivo al arrancar. La activación real es on-demand
según la mecánica propia de cada CLI, y solo para skills cuyo estado en
skills/_registry/skills-registry.json las autorice.

---

## Aislamiento

Las skills globales son reutilizables, pero los contextos de clientes no se
comparten. Una skill no puede transportar credenciales, configuraciones privadas
ni datos de una PBX de un cliente a otra.


