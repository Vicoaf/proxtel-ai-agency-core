# Orchestrator contract

Define cómo el orchestrator externo (PowerShell) invoca a las CLIs de IA en
modo no-interactivo para ejecutar los pasos del ciclo V3.

**Motivación:** el adapter de Claude está certificado para structured-output
transport puro con `--permission-prompts none`. Eso significa que **no puede
hacer file I/O** (Read, Write, Bash). No puede leer `01-plan.md` ni escribir
`04-claude-review.md` por sí mismo.

**Solución:** el orchestrator hace el I/O y le pasa a Claude todo el contexto
en el prompt. Claude devuelve solo el JSON estructurado. El orchestrator
parsea, valida, y escribe el archivo correspondiente.

Patrón estándar de agencias multi-agente (Anthropic SDK, OpenAI SDK).

---

## Arquitectura

    [Orchestrator externo PowerShell]
           │
           │ 1. Lee archivos (01-plan.md, 03-google.md, git diff)
           │ 2. Compone el prompt con el contexto embebido
           │ 3. Invoca claude --print <prompt> --output-format json --json-schema <schema>
           │ 4. Parsea el JSON devuelto por Claude
           │ 5. Valida contra schema
           │ 6. Escribe el archivo de evidencia (04-claude-review.md)
           │
           ▼
    [Claude via adapter]
           │
           └─ Devuelve solo JSON (structured output, sin file I/O)

---

## Contrato del paso 4 — Review

### Función

    Invoke-ReviewStep -TaskId "T-0001" -WorkingDir "C:\DEV\piloto-v3-T-0001-int"

### Inputs

| Input | Tipo | Descripción |
|---|---|---|
| TaskId | string | ID de la tarea (ej. T-0001) |
| WorkingDir | string | Worktree de integración (*-T-0001-int) |
| SkipPreflight | switch | Salta los pre-flight checks (solo para tests) |

### Pre-flight checks (obligatorios)

1. Working tree clean. `git status --porcelain` debe estar vacío.
2. Rama correcta. `git branch --show-current` debe ser `task/T-XXXX-int`.
3. Evidencias previas existen:
   - `.agency-local/audit/T-XXXX/01-plan.md`
   - `.agency-local/audit/T-XXXX/03-google.md`
   - `.agency-local/audit/T-XXXX/02-codex.md` (si aplica; NOT_APPLICABLE si no)
4. Commit base existe. `git rev-parse HEAD` devuelve SHA válido.
5. Diff disponible. `git diff main..HEAD --stat` devuelve algo.

Si un pre-flight falla, el orchestrator aborta con exit code 1 y escribe el
error en `.agency-local/audit/T-XXXX/04-claude-review.ERROR.md`.

### Flujo

1. Leer archivos de contexto:
   - `01-plan.md` (contenido completo)
   - `03-google.md` (contenido completo)
   - `git diff main..HEAD` (diff completo)
   - `git rev-parse HEAD` (SHA del candidate)
   - `PROJECT-SKILLS.md` (skills activas)
2. Componer el prompt (ver sección "Prompt template").
3. Invocar Claude:
       claude --print <prompt> --output-format json --json-schema <schema> --model sonnet
4. Parsear `.structured_output` del JSON. Validar 7 campos. Si falla → exit 2.
5. Escribir `04-claude-review.md` con formato YAML esperado por `standards/qa-handoff.md`.

### Outputs

| Output | Ubicación | Formato |
|---|---|---|
| Reporte | `.agency-local/audit/T-XXXX/04-claude-review.md` | YAML con `status: REVIEW_PASS/FAIL/BLOCKED` |
| Log ejecución | `.agency-local/audit/T-XXXX/logs/orchestrator-review.log` | Texto plano |
| Raw response | `.agency-local/audit/T-XXXX/logs/claude-review-raw.json` | JSON crudo |

### Exit codes

| Code | Significado |
|---|---|
| 0 | REVIEW_PASS |
| 1 | Pre-flight falló |
| 2 | Claude devolvió output inválido (schema mismatch) |
| 3 | REVIEW_FAIL (Claude determinó fallos) |
| 4 | REVIEW_BLOCKED (Claude no pudo completar) |
| 5 | Error de invocación (timeout, red, auth) |

---

## Schema de structured output para el paso 4

    {
        "type": "object",
        "additionalProperties": false,
        "required": ["status", "candidate_commit", "hallazgos", "observaciones"],
        "properties": {
            "status": {"type": "string", "enum": ["REVIEW_PASS", "REVIEW_FAIL", "REVIEW_BLOCKED"]},
            "candidate_commit": {"type": "string", "pattern": "^[a-f0-9]{40}$"},
            "hallazgos": {
                "type": "object",
                "additionalProperties": false,
                "required": ["archivos_fuera_de_alcance", "sin_urls_externas", "html_semantico", "responsive_implementado", "accesibilidad_basica", "js_sin_errores", "contenido_ficticio_marcado"],
                "properties": {
                    "archivos_fuera_de_alcance": {"type": "string", "enum": ["PASS", "FAIL"]},
                    "sin_urls_externas": {"type": "string", "enum": ["PASS", "FAIL"]},
                    "html_semantico": {"type": "string", "enum": ["PASS", "FAIL"]},
                    "responsive_implementado": {"type": "string", "enum": ["PASS", "FAIL"]},
                    "accesibilidad_basica": {"type": "string", "enum": ["PASS", "FAIL"]},
                    "js_sin_errores": {"type": "string", "enum": ["PASS", "FAIL"]},
                    "contenido_ficticio_marcado": {"type": "string", "enum": ["PASS", "FAIL"]}
                }
            },
            "observaciones": {"type": "array", "items": {"type": "string"}, "minItems": 1, "maxItems": 10}
        }
    }

---

## Prompt template para el paso 4

El orchestrator compone el prompt embebiendo el contexto:

    Eres el revisor técnico del paso 4 del ciclo V3 de PROXTEL AI Agency.

    TAREA: {TaskId}
    CANDIDATE COMMIT: {git rev-parse HEAD}
    BASE: main

    PLAN (01-plan.md):
    ---
    {contenido completo de 01-plan.md}
    ---

    IMPLEMENTACIÓN (03-google.md):
    ---
    {contenido completo de 03-google.md}
    ---

    DIFF main..HEAD:
    ---
    {git diff main..HEAD}
    ---

    SKILLS ACTIVAS (PROJECT-SKILLS.md):
    ---
    {contenido completo de PROJECT-SKILLS.md}
    ---

    CRITERIOS DE REVIEW (7 hallazgos obligatorios):
    1. archivos_fuera_de_alcance: ¿Hay archivos en el diff fuera de google_scope?
    2. sin_urls_externas: ¿Hay https://, cdn., googleapis en el código?
    3. html_semantico: ¿1 h1, h2 por sección, h3 en tarjetas, lang="es", landmarks?
    4. responsive_implementado: ¿Media queries para 1440, 768, 390?
    5. accesibilidad_basica: ¿Focus visible, contraste suficiente, jerarquía coherente?
    6. js_sin_errores: ¿JS sintácticamente válido, sin eval, sin requests externos?
    7. contenido_ficticio_marcado: ¿Testimonios marcados como "Ejemplo ficticio"?

    INSTRUCCIONES:
    - Devuelve SOLO el JSON que cumple el schema.
    - No uses herramientas, archivos, shell, network, MCP.
    - No expliques el razonamiento.
    - Marca cada hallazgo PASS o FAIL con evidencia.
    - Si algún hallazgo es FAIL, status es REVIEW_FAIL.
    - Si hay error técnico que impide el review, status es REVIEW_BLOCKED.

---

## Contrato del paso 6 — Certification

### Función

    Invoke-CertificationStep -TaskId "T-0001" -WorkingDir "C:\DEV\piloto-v3-T-0001-int"

### Pre-flight checks

1. Las 5 evidencias existen: `01-plan.md`, `02-codex.md` (si aplica), `03-google.md`, `04-claude-review.md`, `05-playwright.md`
2. `04-claude-review.md` contiene `status: REVIEW_PASS`
3. `05-playwright.md` contiene `QA_PASS` + `VISUAL_PASS` + `APPROVED`
4. `candidate_commit` en `04-claude-review.md` coincide con `git rev-parse HEAD`
5. Working tree clean

### Flujo

1. Leer las 5 evidencias + SHA actual
2. Componer prompt con el resumen estructurado
3. Invocar `claude --print <prompt> --output-format json --json-schema <certification-schema>`
4. Parsear y validar el JSON
5. Escribir `06-certification.yaml` con el formato esperado
6. Verificar que `candidate_commit` del YAML coincide con `git rev-parse HEAD`

### Outputs

| Output | Ubicación | Formato |
|---|---|---|
| Certificación | `.agency-local/audit/T-XXXX/06-certification.yaml` | YAML con `status: READY_FOR_MERGE_AUTHORIZATION` |
| Log | `.agency-local/audit/T-XXXX/logs/orchestrator-certification.log` | Texto plano |

### Exit codes

| Code | Significado |
|---|---|
| 0 | READY_FOR_MERGE_AUTHORIZATION |
| 1 | Pre-flight falló (evidencias incompletas o commit no coincide) |
| 2 | Claude devolvió output inválido |
| 3 | BLOCKED (Claude no pudo certificar) |

---

## Reglas duras del orchestrator

1. **NO escribe código de producción.** Solo evidencia en `.agency-local/audit/`.
2. **NO modifica** `adapters/`, `standards/`, `AGENTS.md` ni archivos tracked.
3. **NO invoca Claude con** `--dangerously-skip-permissions`. Jamás.
4. **NO invoca Claude con tools habilitadas.** `--permission-prompts none` obligatorio.
5. **Toda invocación queda registrada** en `.agency-local/audit/T-XXXX/logs/`: prompt completo (hash + contenido), response completa, timestamp, costo estimado.
6. **Si el schema no valida, ABORTA.** No intenta "arreglar" el output. Escribe el error y sale con código 2.
7. **Nunca emite `READY_FOR_MERGE_AUTHORIZATION`** si alguna evidencia falta o el SHA no coincide.

---

## Scripts a construir

| Script | Función | Estado |
|---|---|---|
| `tools/run-review-step.ps1` | Ejecuta paso 4 (review) | Pendiente D4.2b |
| `tools/run-certification-step.ps1` | Ejecuta paso 6 (certification) | Pendiente D4.2e |

---

## Referencias

- `adapters/claude/adapter.json` — capabilities del adapter (sin file I/O)
- `standards/pre-flight-checks.md` — pre-flight Fase D
- `standards/qa-handoff.md` — formato de `04-claude-review.md` y `06-certification.yaml`
- `docs/architecture-v3.md` sección 2 — ciclo de 5 pasos
- `docs/lessons/pilot-day4-5.md` — fricciones del piloto
