# START-TASK.md — Checklist de inicio de tarea

Plantilla para el inicio de cualquier tarea en un proyecto. Copiar este archivo
a `<repo-del-cliente>/TASKS/T-XXXX-START.md` y completar antes de escribir código.

Complementa a `standards/pre-flight-checks.md` con una checklist ejecutable
para el humano (Vic) al iniciar cada tarea.

---

# TAREA T-XXXX

Fecha de inicio: YYYY-MM-DD
Proyecto: <nombre-proyecto>
Rama base: main
Máquina: <PC | Mac>
Worktree esperado: <C:\DEV\<proyecto> | C:\DEV\<proyecto>-T-XXXX-api | -ui | -int>

---

## Pre-flight (ejecutar antes de tocar código)

### 1. Verificar directorio y rama

- [ ] `pwd` muestra el worktree correcto
- [ ] `git branch --show-current` muestra la rama esperada:
      - `main` si es planificación
      - `task/T-XXXX-api` si es backend
      - `task/T-XXXX-ui` si es frontend
      - `task/T-XXXX-int` si es review/QA
- [ ] `git status` está clean o solo tiene cambios autorizados
- [ ] `git worktree list` incluye este directorio

**Si falla cualquiera:** detener y corregir. Ver `standards/pre-flight-checks.md`
Fase A.

### 2. Validar PROJECT-SKILLS.md

- [ ] Ejecutar `C:\DEV\PROXTEL-AI-AGENCY\tools\check-project-skills.ps1 -Path <ruta>`
- [ ] Resultado: `PASS`

**Si falla:** restaurar el archivo. El script imprime la acción sugerida.

### 3. Verificar skills autorizadas

- [ ] Leer `PROJECT-SKILLS.md` y confirmar qué skills están activas
- [ ] Verificar que las skills declaradas siguen `approved` en
      `C:\DEV\PROXTEL-AI-AGENCY\skills\_registry\skills-registry.json`
- [ ] Anotar en el plan qué skills se usarán

### 4. Verificar cuotas de las 3 CLIs

- [ ] Consultar `C:\DEV\PROXTEL-AI-AGENCY\tools\quota-log.md`
- [ ] Si R ≤ 20% en algún proveedor, aplicar reruteo según
      `C:\DEV\PROXTEL-AI-AGENCY\AGENTS.md` sección "Cuotas y reruteo"

---

## Planificación (paso 1 del ciclo)

- [ ] Crear `.agency-local/audit/T-XXXX/01-plan.md` con:
      - `task_id`, `project`, `objective`, `base_branch`
      - `codex_scope`, `google_scope`
      - `skills_activas` (solo las de `PROJECT-SKILLS.md`)
      - `acceptance` (criterios verificables)
      - Archivos permitidos para cada implementador
      - Archivos prohibidos
      - Riesgos identificados
      - Restricciones duras

**Validación del plan:** el plan debe ser ejecutable sin ambigüedad. Si un
implementador no puede seguir el plan sin preguntar, el plan falla.

---

## Implementación

### Si Codex implementa backend (paso 2)

- [ ] Anotar el SHA del commit base antes de empezar
- [ ] Al terminar, escribir `.agency-local/audit/T-XXXX/02-codex.md` con:
      - `status: CODEX_PASS | CODEX_FAIL | CODEX_BLOCKED`
      - `diff_stats`
      - `pruebas_ejecutadas`
      - `archivos_creados`
- [ ] Verificar que NO hay archivos fuera del `codex_scope`

### Si Antigravity implementa frontend (paso 3)

- [ ] Anotar el SHA del commit base antes de empezar
- [ ] Al terminar, escribir `.agency-local/audit/T-XXXX/03-google.md` con:
      - `status: FRONTEND_PASS | FRONTEND_FAIL | FRONTEND_BLOCKED`
      - `archivos_creados`
      - `pruebas_tecnicas`
- [ ] Verificar que NO hay archivos fuera del `google_scope`
- [ ] Verificar que NO hay URLs externas (CDN, fuentes, imágenes remotas)

---

## Review (paso 4 del ciclo)

- [ ] Claude ejecuta `/review` sobre el diff
- [ ] Escribe `.agency-local/audit/T-XXXX/04-claude-review.md` con:
      - `status: REVIEW_PASS | REVIEW_FAIL | REVIEW_BLOCKED`
      - `candidate_commit: <SHA actual del HEAD>`
      - `hallazgos` (uno por check, PASS/FAIL)
      - `observaciones`

**El review es obligatorio.** No se sustituye por un resumen. Si falla, se
devuelve al implementador.

---

## QA (paso 5 del ciclo)

- [ ] Levantar servidor local: `npx serve -l 8000`
- [ ] Health check: `Invoke-WebRequest http://localhost:8000 -UseBasicParsing | Select-Object StatusCode` → debe ser `200`
- [ ] Ejecutar Playwright contra las rutas
- [ ] Capturar screenshots (1440, 768, 390)
- [ ] Capturar logs de consola y network
- [ ] Escribir `.agency-local/audit/T-XXXX/05-playwright.md` con:
      - `status: QA_PASS | QA_FAIL | QA_BLOCKED`
      - `resultado: VISUAL_PASS | VISUAL_FAIL | VISUAL_BLOCKED` (decisión de Vic)
      - `decision: APPROVED | REJECTED`
      - Evidencias (screenshots, dom, logs)

**El gate visual es de Vic.** Playwright valida comportamiento. Vic valida
la interfaz.

---

## Cierre (paso 6 del ciclo)

- [ ] Verificar que los 5 archivos de evidencia existen y son válidos
- [ ] Ejecutar `standards/pre-flight-checks.md` Fase D (cierre)
- [ ] Escribir `.agency-local/audit/T-XXXX/06-certification.yaml` con:
      - `status: READY_FOR_MERGE_AUTHORIZATION`
      - `candidate_commit` (debe coincidir con `git rev-parse HEAD`)
      - `verification` (todos los checks en `true`)
      - `acceptance_vic: APPROVED`
- [ ] Notificar a Vic para autorización de merge

---

## Merge (autorizado por Vic)

- [ ] `git checkout main`
- [ ] `git merge task/T-XXXX-int --no-ff -m "merge(T-XXXX): ..."`
- [ ] `git tag -a t-XXXX-certified -m "..."`
- [ ] Push a `origin/main` desde PC Windows

**Prohibido:** automerge, merge desde Mac, force push a main.

---

## Cierre administrativo

- [ ] Actualizar `docs/STATUS.md` con el hito (si aplica)
- [ ] Actualizar `tools/quota-log.md` con las cuotas usadas
- [ ] Si se usó una skill nueva, evaluar si cumple la regla de promoción
      (3 usos en 2 proyectos)
- [ ] Si se detectó una fricción nueva, añadirla a `docs/lessons/`
- [ ] Si se descubrió un pitfall nuevo, añadirlo a
      `standards/pre-flight-checks.md`

---

## Comandos de referencia rápida

    # Verificación
    .\tools\check-project-skills.ps1
    git branch --show-current
    git worktree list
    git status

    # Ciclo
    git worktree add -b task/T-XXXX-api "../<repo>-T-XXXX-api" main
    git worktree add -b task/T-XXXX-ui "../<repo>-T-XXXX-ui" main
    git worktree add -b task/T-XXXX-int "../<repo>-T-XXXX-int" main

    # QA
    npx serve -l 8000
    Invoke-WebRequest http://localhost:8000 -UseBasicParsing | Select-Object StatusCode
    $env:NODE_PATH = "C:\DEV\_piloto-tools\node_modules"

    # Cierre
    git merge task/T-XXXX-int --no-ff
    git tag -a t-XXXX-certified -m "..."
    git push origin main

---

## Documentos relacionados

- `C:\DEV\PROXTEL-AI-AGENCY\AGENTS.md` — reglas maestras
- `C:\DEV\PROXTEL-AI-AGENCY\standards\pre-flight-checks.md` — pre-flight técnico
- `C:\DEV\PROXTEL-AI-AGENCY\standards\permissions.md` — niveles A/B
- `C:\DEV\PROXTEL-AI-AGENCY\standards\qa-handoff.md` — convención `.agency-local/`
- `C:\DEV\PROXTEL-AI-AGENCY\standards\concurrency.md` — worktrees
- `C:\DEV\PROXTEL-AI-AGENCY\tools\check-project-skills.ps1` — validador
- `C:\DEV\PROXTEL-AI-AGENCY\tools\quota-log.md` — cuotas
- `C:\DEV\PROXTEL-AI-AGENCY\docs\architecture-v3.md` — arquitectura
- `C:\DEV\PROXTEL-AI-AGENCY\docs\lessons\pilot-day4-5.md` — fricciones del piloto

---

**Esta checklist se copia al iniciar cada tarea.** No es opcional. Es la
materialización operativa de las 8 fricciones del piloto T-0001 y del ciclo
V3 completo.
