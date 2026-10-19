# Convención de handoff QA (Playwright → Vic)

Define cómo Playwright entrega la evidencia de pruebas y cómo Vic la revisa
para aprobar el gate visual. Sin esta convención, Vic revisa a ciegas y la
aprobación visual no es verificable.

Documento relacionado: docs/architecture-v3.md secciones 2 (paso 5) y 7.5

---

## Estructura obligatoria

Toda auditoría vive en:

    .agency-local/audit/T-XXXX/
    ├── 01-plan.md
    ├── 02-codex.md
    ├── 03-google.md
    ├── 04-claude-review.md
    ├── 05-playwright.md
    ├── 06-certification.yaml
    ├── screenshots/
    │   ├── home-1440.png
    │   ├── home-768.png
    │   ├── home-390.png
    │   └── <ruta>-<viewport>.png
    ├── traces/
    │   └── <flujo>.zip
    └── logs/
        ├── console.log
        └── network.har

El directorio .agency-local/ NO se versiona en Git (está en .gitignore).

---

## Quién escribe qué

- Playwright MCP escribe todo excepto 04-claude-review.md y 06-certification.yaml.
- Claude escribe 01-plan.md, 04-claude-review.md y 06-certification.yaml.
- Codex escribe 02-codex.md.
- Antigravity escribe 03-google.md.
- Vic añade su decisión visual dentro de 05-playwright.md en las secciones
  #revision-visual-vic y #aceptacion-vic.
- Nadie modifica los artefactos de Playwright después de generados.

---

## Contenido mínimo de 05-playwright.md

Debe contener estas secciones, en este orden:

### #resultado-playwright

- Lista de rutas auditadas y viewports.
- Errores de consola (con severidad).
- Requests fallidos (4xx, 5xx) con URL y status.
- Elementos visibles pero no clicables o desbordados.
- Resultado por ruta: QA_PASS / QA_FAIL / QA_BLOCKED con motivo.

### #revision-visual-vic

- Vic revisa screenshots/ y confirma coherencia con el diseño aprobado.
- Resultado: VISUAL_PASS / VISUAL_FAIL / VISUAL_BLOCKED.
- Observaciones concretas si falla, con referencia a screenshot específico.

### #aceptacion-vic

- Decisión final de Vic sobre la tarea.
- Aprobado: APPROVED.
- Rechazado: REJECTED con motivo.

---

## Criterio de paso a aprobación de Vic

Una tarea pasa a Vic solo si:

- 04-claude-review.md contiene REVIEW_PASS.
- 05-playwright.md contiene QA_PASS con screenshots y trazas adjuntas.
- 01-plan.md, 02-codex.md y 03-google.md existen y respaldan los resultados.
- No hay modificaciones de código posteriores a la ejecución de Playwright.
- 06-certification.yaml debe incluir candidate_commit exacto (SHA del commit
  revisado y probado), visual_review_vic.status=PASS y
  acceptance_vic.status=APPROVED. La aceptación de Vic no se infiere del QA
  de Playwright.
- Si cualquier evidencia falta o el commit revisado no coincide con el commit
  certificado, el gate queda bloqueado. Claude no solicita merge.

Si falta cualquier elemento, Claude no solicita aprobación de Vic.
