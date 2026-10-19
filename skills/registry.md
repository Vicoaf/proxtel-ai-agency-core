# Registry de skills

Única fuente de verdad del catálogo de skills globales. Ninguna skill se activa
en un proyecto si no está registrada aquí. Ver docs/architecture-v3.md sección 6.

---

## Skills activas (globales)

| Skill | Propósito | Activación | Estado | Proyectos |
|---|---|---|---|---|
| qa-frontend-audit | Auditoría visual + DOM con Playwright | on-demand | activa | i-Tkt, TRDStation |
| redesign-existing | Rediseño de UI existente preservando estructura | on-demand | activa | TRDStation |
| image-to-code | Referencia visual → código | manual | activa | TRDStation |

---

## Skills en borrador (no globales aún)

| Skill | Propósito | Estado | Motivo |
|---|---|---|---|
| laravel-migration-review | Revisar migraciones Laravel antes de merge | borrador | Pendiente 3 usos |

---

## Candidatas (en observación)

| Skill | Veces usada manual | Proyectos | Próximo paso |
|---|---|---|---|
| — | — | — | — |

---

## Regla de promoción a global

Una skill se convierte en global solo si cumple las tres condiciones:

1. Se resolvió manualmente ≥3 veces en tareas identificables (no reintentos).
2. En ≥2 proyectos distintos.
3. Pasó por Skill Factory: creación, revisión, tests y aprobación de Claude + Vic.

Mientras no cumpla las tres, se anota en PROJECT-SKILLS.md del proyecto como
candidata, NO en este registry.

---

## Cómo se activa una skill en un proyecto

En la raíz del repo del cliente, crear PROJECT-SKILLS.md:

    # Skills activas en este proyecto
    - qa-frontend-audit
    - laravel-migration-review

    # Skills explícitamente NO activas
    - image-to-code  (no hay referencias visuales)

Los agentes leen este archivo al arrancar y cargan solo lo declarado.

---

## Aislamiento

Las skills globales son reutilizables, pero los contextos de clientes no se
comparten. Una skill no puede transportar credenciales, configuraciones privadas
ni datos de una PBX de un cliente a otra.
