# Orchestrator contract

Define cómo el orchestrator externo (PowerShell) invoca a las CLIs de IA en
modo no-interactivo para ejecutar los pasos del ciclo V3.

**Motivación:** el adapter de Claude (`adapters/claude/adapter.json`) está
certificado para structured-output transport puro con `--permission-prompts none`.
Eso significa que **no puede hacer file I/O** (Read, Write, Bash). No puede
leer `01-plan.md` ni escribir `04-claude-review.md` por sí mismo.

**Solución:** el orchestrator hace el I/O y le pasa a Claude todo el cono
en el prompt. Claude devuelve solo el JSON estructurado. El orchestrator
parsea, valida, y escribe el archivo correspondiente.

Esto es el patrón estándar de agencias multi-agente (Anthropic SDK, OpenAI SDK).

---

## Arquitectura
[Orchestrator externo PowerShell]
│
│ 1. Lee archivos (01-plan.md, 03-google.md, git diff)
│ 2. Compone el prompt con el cono embebido
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

```powershell
Invoke-ReviewStep -TaskId "T-0001" -WorkingDir "C:\DEV\piloto-v3-T-0001-int"
Inputs
Input	Tipo	Descripción
TaskId	string	ID de la tarea (ej. T-0001)
WorkingDir	string	Worktree de integración (*-T-0001-int)
SkipPreflight	switch	Salta los pre-flight checks (solo para tests)
Pre-flight checks (obligatorios)
Working tree clean. git status --porcelain debe estar vacío.

Rama correcta. git branch --show-current debe ser task/T-XXXX-int.

Evidencias previas existen.

.agency-local/audit/T-XXXX/01-plan.md

.agency-local/audit/T-XXXX/03-google.md

.agency-local/audit/T-XXXX/02-codex.md (si aplica; NOT_APPLICABLE si no)

Commit base existe. git rev-parse HEAD devuelve un SHA válido.

Diff disponible. git diff main..HEAD --stat devuelve algo.

Si un pre-flight falla, el orchestrator aborta con exit code 1 y escribe el error en .agency-local/audit/T-XXXX/04-claude-review.ERROR.md.

Flujo
Leer archivos de cono:

01-plan.md (contenido completo)

03-google.md (contenido completo)

git diff main..HEAD (diff completo)

git rev-parse HEAD (SHA del candidate)

PROJECT-SKILLS.md (skills activas)

Componer el prompt (ver sección "Prompt template" abajo).

Invocar Claude:

powershell
claude --print <prompt> `
       --output-format json `
       --json-schema <schema-compact> `
       --model sonnet
Parsear la respuesta:

Extraer .structured_output del JSON

Validar los 7 campos obligatorios

Si falla la validación → exit code 2 + error

Escribir 04-claude-review.md con el formato YAML esperado por standards/qa-handoff.md.

Outputs
Output	Ubicación	Formato
Reporte de review	.agency-local/audit/T-XXXX/04-claude-review.md	YAML con status: REVIEW_PASS/FAIL/BLOCKED
Log de ejecución	.agency-local/audit/T-XXXX/logs/orchestrator-review.log	o plano
Raw response	.agency-local/audit/T-XXXX/logs/claude-review-raw.json	JSON crudo (para auditoría)
Exit codes
Code	Significado
0	REVIEW_PASS
1	Pre-flight falló
2	Claude devolvió output inválido (schema mismatch)
3	REVIEW_FAIL (Claude determinó que hay fallos)
4	REVIEW_BLOCKED (Claude no pudo completar el review)
5	Error de invocación de Claude (timeout, red, auth)
Schema de structured output para el paso 4
json
{
    "type": "object",
    "additionalProperties": false,
    "required": ["status", "candidate_commit", "hallazgos", "observaciones"],
    "properties": {
        "status": {
            "type": "string",
            "enum": ["REVIEW_PASS", "REVIEW_FAIL", "REVIEW_BLOCKED"]
        },
        "candidate_commit": {
            "type": "string",
            "pattern": "^[a-f0-9]{40}$"
        },
        "hallazgos": {
            "type": "object",
            "additionalProperties": false,
            "required": [
                "archivos_fuera_de_alcance",
                "sin_urls_externas",
                "html_semantico",
                "responsive_implementado",
                "accesibilidad_basica",
                "js_sin_errores",
                "contenido_ficticio_marcado"
            ],
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
        "observaciones": {
            "type": "array",
            "items": {"type": "string"},
            "minItems": 1,
            "maxItems": 10
        }
    }
}
Prompt template para el paso 4
El orchestrator compone el prompt embebiendo el cono. Formato:


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
1. archivos_fuera_de_alcance: ¿Hay archivos en el diff que no estén en google_scope del plan?
2. sin_urls_externas: ¿Hay https://, cdn., googleapis en el código?
3. html_semantico: ¿Hay 1 h1, h2 por sección, h3 en tarjetas, lang="es", landmarks header/main/footer?
4. responsive_implementado: ¿Hay media queries para 1440, 768, 390?
5. accesibilidad_basica: ¿Focus visible, contraste suficiente, jerarquía de headings?
6. js_sin_errores: ¿El JS es sintácticamente válido, sin eval, sin requests externos?
7. contenido_ficticio_marcado: ¿Los testimonios están marcados como ficticios con "Ejemplo ficticio" visible?

INSTRUCCIONES:
- Devuelve SOLO el JSON que cumple el schema.
- No uses herramientas, archivos, shell, network, MCP.
- No expliques el razonamiento.
- Marca cada hallazgo como PASS o FAIL con evidencia.
- Si algún hallazgo es FAIL, status debe ser REVIEW_FAIL.
- Si hay un error técnico que impide el review, status debe ser REVIEW_BLOCKED.
Contrato del paso 6 — Certification
Función
powershell
Invoke-CertificationStep -TaskId "T-0001" -WorkingDir "C:\DEV\piloto-v3-T-0001-int"
Pre-flight checks
Las 5 evidencias existen: 01-plan.md, 02-codex.md (si aplica), 03-google.md, 04-claude-review.md, 05-playwright.md

04-claude-review.md contiene status: REVIEW_PASS

05-playwright.md contiene QA_PASS + VISUAL_PASS + APPROVED

candidate_commit en 04-claude-review.md coincide con git rev-parse HEAD

Working tree clean

Flujo
Leer las 5 evidencias + SHA actual

Componer prompt con el resumen estructurado de las 5 evidencias

Invocar claude --print <prompt> --output-format json --json-schema <certification-schema>

Parsear y validar el JSON

Escribir 06-certification.yaml con el formato esperado

Verificar que el candidate_commit del YAML coincide con git rev-parse HEAD

Outputs
Output	Ubicación	Formato
Certificación	.agency-local/audit/T-XXXX/06-certification.yaml	YAML con status: READY_FOR_MERGE_AUTHORIZATION
Log	.agency-local/audit/T-XXXX/logs/orchestrator-certification.log	o plano
Exit codes
Code	Significado
0	READY_FOR_MERGE_AUTHORIZATION
1	Pre-flight falló (evidencias incompletas o commit no coincide)
2	Claude devolvió output inválido
3	BLOCKED (Claude no pudo certificar)
Reglas duras del orchestrator
El orchestrator NO escribe código de producción. Solo escribe evidencia en .agency-local/audit/.

El orchestrator NO modifica adapters/, standards/, AGENTS.md ni ningún archivo tracked. Solo .agency-local/ que es untracked.

El orchestrator NO invoca Claude con --dangerously-skip-permissions. Jamás.

El orchestrator NO invoca Claude con tools habilitadas. --permission-prompts none es obligatorio.

Toda invocación de Claude queda registrada en .agency-local/audit/T-XXXX/logs/ con:

Prompt completo (hash + contenido)

Response completa

Timestamp

Costo estimado (si disponible en el JSON de respuesta)

Si el schema no valida, el orchestrator ABORTA. No intenta "arreglar" el output. Escribe el error y sale con código 2.

Nunca se promueve 06-certification.yaml con READY_FOR_MERGE_AUTHORIZATION si alguna evidencia falta o el SHA no coincide. El orchestrator es el guardián del gate.

Scripts a construir
Script	Función	Estado
tools/run-review-step.ps1	Ejecuta el paso 4 (review)	Pendiente D4.2b
tools/run-certification-step.ps1	Ejecuta el paso 6 (certification)	Pendiente D4.2e
Referencias
adapters/claude/adapter.json — capabilities del adapter (sin file I/O)

standards/pre-flight-checks.md — pre-flight Fase D (cierre)

standards/qa-handoff.md — formato de 04-claude-review.md y 06-certification.yaml

docs/architecture-v3.md sección 2 — ciclo de 5 pasos

docs/lessons/pilot-day4-5.md — fricciones del piloto (F2: Claude escribe archivos con Write en Windows — el orchestrator lo implementa)
'@

Crear directorio si no existe
if (-not (Test-Path "tools")) { New-Item -ItemType Directory -Force -Path "tools" | Out-Null }

Escribir el archivo (UTF-8 sin BOM)
Set-Content -LiteralPath "tools\orchestrator-contract.md" -Value $content -Encoding UTF8 -NoNewline

Write-Host ""
Write-Host "=== ARCHIVO CREADO ===" -ForegroundColor Green
Write-Host "Lineas: ((Get-Content 'tools\orchestrator-contract.md').Count)" Write-Host "Bytes: ((Get-Item 'tools\orchestrator-contract.md').Length)"



**Qué esperas ver:**
=== ARCHIVO CREADO ===
Lineas: 250-300
Bytes: ~12000-15000



---

## Paso 3 — Verificar el archivo

```powershell
cd C:\DEV\PROXTEL-AI-AGENCY
Write-Host "=== PRIMERAS 5 LINEAS ===" -ForegroundColor Cyan
Get-Content "tools\orchestrator-contract.md" | Select-Object -First 5
Write-Host ""
Write-Host "=== ULTIMAS 5 LINEAS ===" -ForegroundColor Cyan
Get-Content "tools\orchestrator-contract.md" | Select-Object -Last 5
Write-Host ""
Write-Host "=== HEADERS ===" -ForegroundColor Cyan
Select-String -Path "tools\orchestrator-contract.md" -Pattern "^## " | Select-Object Line
Esperado:

Primeras 5:


# Orchestrator contract

Define cómo el orchestrator externo (PowerShell) invoca a las CLIs de IA en
modo no-interactivo para ejecutar los pasos del ciclo V3.
Últimas 5:


- `docs/lessons/pilot-day4-5.md` — fricciones del piloto (F2: Claude escribe archivos con Write en Windows — el orchestrator lo implementa)
Headers (7):


## Arquitectura
## Contrato del paso 4 — Review
## Schema de structured output para el paso 4
## Prompt template para el paso 4
## Contrato del paso 6 — Certification
## Reglas duras del orchestrator
## Scripts a construir
## Referencias
