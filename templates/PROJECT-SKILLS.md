# PROJECT-SKILLS.md — Template

Template para la raíz de cada repositorio de cliente. Copiar este archivo a
<repo-del-cliente>/PROJECT-SKILLS.md y rellenar.

Los agentes (Claude Code, Codex, Antigravity) lo leen al arrancar y cargan solo
las skills declaradas como activas. Ver skills/registry.md para el catálogo
completo.

---

# PROYECTO: <nombre-del-proyecto>

Cliente: <nombre-cliente>
Tipo: <CRM | trading | web | PBX | SaaS | landing | otro>
Stack declarado: <Laravel + MySQL | Node + Postgres | ...>
Rama base: <main | develop>
Máquina de desarrollo actual: <PC | Mac>
Ciclo V3 activo: <sí | no (proyecto legacy pre-V3)>

---

## Skills activas en este proyecto

Skills que los agentes pueden usar sin restricción adicional.

- <skill-id-1>  (ej. auditor-web)
- <skill-id-2>  (ej. maestro-frontend)

---

## Skills explícitamente NO activas

Skills del catálogo que NO aplican a este proyecto. Motivo entre paréntesis.

- <skill-id-3>  (ej. estratega-seo — proyecto interno sin objetivo SEO)
- <skill-id-4>  (ej. creador-skills — no se crearán skills nuevas aquí)

---

## Candidatas (en observación)

Skills que se están usando manualmente en este proyecto y podrían promoverse a
globales tras 3 usos en 2 proyectos. Ver skills/registry.md.

| Skill | Veces usada aquí | Motivo de la observación |
|---|---|---|
| — | — | — |

---

## Reglas locales del proyecto

Reglas que sobrescriben o complementan AGENTS.md global. Si hay conflicto,
estas reglas ganan porque están más cerca del código.

- <regla-1>  (ej. no usar Tailwind, usar Bootstrap por decisión del cliente)
- <regla-2>  (ej. todas las migraciones requieren aprobación del DBA del cliente)
- <regla-3>  (ej. producción es AWS, staging es DigitalOcean, no confundir credenciales)

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

Ver docs/architecture-v3.md sección 7.8 para condiciones de incorporación.
