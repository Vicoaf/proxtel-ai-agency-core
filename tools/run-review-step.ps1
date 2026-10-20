<#
.SYNOPSIS
    Ejecuta el paso 4 del ciclo V3 (review) de forma automatizada.

.DESCRIPTION
    Invoca claude --print con contexto embebido para generar 04-claude-review.md.
    Implementa el contrato definido en tools/orchestrator-contract.md.

.PARAMETER TaskId
    ID de la tarea (ej. T-0001).

.PARAMETER WorkingDir
    Worktree de integracion (ej. C:\DEV\piloto-v3-T-0001-int).

.PARAMETER SkipPreflight
    Salta los pre-flight checks (solo para tests).

.EXAMPLE
    .\run-review-step.ps1 -TaskId "T-0001" -WorkingDir "C:\DEV\piloto-v3-T-0001-int"

.EXITCODES
    0 = REVIEW_PASS
    1 = Pre-flight fallo
    2 = Claude devolvio output invalido
    3 = REVIEW_FAIL
    4 = REVIEW_BLOCKED
    5 = Error de invocacion
#>
param(
    [Parameter(Mandatory=$true)][string]$TaskId,
    [Parameter(Mandatory=$true)][string]$WorkingDir,
    [string]$BaseRef = "",
    [switch]$SkipPreflight
)

$ErrorActionPreference = 'Stop'

# Paths fijos
$ClaudeExe = "C:\Users\MSI\AppData\Roaming\npm\node_modules\@anthropic-ai\claude-code\bin\claude.exe"

# Paths dinamicos
$AuditDir        = Join-Path $WorkingDir ".agency-local\audit\$TaskId"
$LogDir          = Join-Path $AuditDir "logs"
$PlanPath        = Join-Path $AuditDir "01-plan.md"
$GooglePath      = Join-Path $AuditDir "03-google.md"
$ReviewPath      = Join-Path $AuditDir "04-claude-review.md"
$ReviewErrorPath = Join-Path $AuditDir "04-claude-review.ERROR.md"
$LogPath         = Join-Path $LogDir "orchestrator-review.log"
$RawResponsePath = Join-Path $LogDir "claude-review-raw.json"
$ProjectSkillsPath = Join-Path $WorkingDir "PROJECT-SKILLS.md"

New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $ts = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    $line = "[$ts] [$Level] $Message"
    Add-Content -Path $LogPath -Value $line -Encoding UTF8
    Write-Host $line
}

function Fail-Preflight {
    param([string]$Reason)
    $msg = "PREFLIGHT_FAIL: $Reason"
    Write-Log $msg "ERROR"
    Set-Content -Path $ReviewErrorPath -Value $msg -Encoding UTF8
    exit 1
}

Write-Log "=== run-review-step START ==="
Write-Log "TaskId: $TaskId"
Write-Log "WorkingDir: $WorkingDir"
Write-Log ""

# ============================================================
# VALIDACION DE WORKINGDIR (siempre, incluso con SkipPreflight)
# ============================================================
if (-not (Test-Path $WorkingDir)) {
    Write-Log "FALLA: WorkingDir no existe: $WorkingDir" "ERROR"
    Set-Content -Path $ReviewErrorPath -Value "WORKINGDIR_NOT_FOUND: $WorkingDir" -Encoding UTF8 -ErrorAction SilentlyContinue
    exit 1
}

# ============================================================
# PRE-FLIGHT CHECKS
# ============================================================
if (-not $SkipPreflight) {
    Write-Log "=== PRE-FLIGHT ==="

    # 1. Working tree clean
    Push-Location $WorkingDir
    try {
        $statusPorcelain = git status --porcelain 2>&1
        if ($statusPorcelain) {
            Fail-Preflight "Working tree no esta clean. Cambios pendientes: $statusPorcelain"
        }
        Write-Log "OK: working tree clean"

        # 2. Rama correcta
        $currentBranch = git branch --show-current 2>&1
        $expectedBranch = "task/$TaskId-int"
        if ($currentBranch -ne $expectedBranch) {
            Fail-Preflight "Rama incorrecta. Actual: '$currentBranch', esperada: '$expectedBranch'"
        }
        Write-Log "OK: rama correcta ($currentBranch)"

        # 3. Evidencias previas existen
        if (-not (Test-Path $PlanPath)) {
            Fail-Preflight "Falta 01-plan.md en $PlanPath"
        }
        if (-not (Test-Path $GooglePath)) {
            Fail-Preflight "Falta 03-google.md en $GooglePath"
        }
        Write-Log "OK: 01-plan.md y 03-google.md existen"

        # 4. Commit SHA valido
        $candidateCommit = (git rev-parse HEAD 2>&1 | Out-String).Trim()
        if ($candidateCommit -notmatch '^[a-f0-9]{40}$') {
            Fail-Preflight "SHA invalido: '$candidateCommit'"
        }
        Write-Log "OK: candidate commit = $candidateCommit"

        # 5. Diff disponible
        if ($BaseRef) {
            $baseCommit = $BaseRef
        } else {
            $baseCommit = (git merge-base main HEAD 2>&1 | Out-String).Trim()
        }
        $diffStat = git diff "$baseCommit..HEAD" --stat 2>&1
        if (-not $diffStat) {
            Fail-Preflight "Diff main..HEAD vacio. Nada que revisar."
        }
        Write-Log "OK: diff disponible"

        # Leer el diff completo
        $fullDiff = git diff "$baseCommit..HEAD" 2>&1 | Out-String
        Write-Log "Diff leido: $($fullDiff.Length) chars"

    } finally {
        Pop-Location
    }
} else {
    Write-Log "PRE-FLIGHT SKIPPED (-SkipPreflight)"
    Push-Location $WorkingDir
    try {
        $candidateCommit = (git rev-parse HEAD 2>&1 | Out-String).Trim()
        $fullDiff = git diff "$baseCommit..HEAD" 2>&1 | Out-String
    } finally {
        Pop-Location
    }
}

# ============================================================
# LEER CONTEXTO
# ============================================================
Write-Log ""
Write-Log "=== LEYENDO CONTEXTO ==="

if (-not (Test-Path $PlanPath)) {
    Write-Log "FALLA: no existe $PlanPath" "ERROR"
    exit 1
}
$planContent = Get-Content -LiteralPath $PlanPath -Raw -Encoding UTF8
Write-Log "01-plan.md: $($planContent.Length) chars"

if (-not (Test-Path $GooglePath)) {
    Write-Log "FALLA: no existe $GooglePath" "ERROR"
    exit 1
}
$googleContent = Get-Content -LiteralPath $GooglePath -Raw -Encoding UTF8
Write-Log "03-google.md: $($googleContent.Length) chars"

if (Test-Path $ProjectSkillsPath) {
    $skillsContent = Get-Content -LiteralPath $ProjectSkillsPath -Raw -Encoding UTF8
} else {
    $skillsContent = "(PROJECT-SKILLS.md no encontrado en $ProjectSkillsPath)"
}
Write-Log "PROJECT-SKILLS.md: $($skillsContent.Length) chars"

# ============================================================
# COMPONER PROMPT
# ============================================================
Write-Log ""
Write-Log "=== COMPONIENDO PROMPT ==="

$promptLines = @(
    "Eres el revisor tecnico del paso 4 del ciclo V3 de PROXTEL AI Agency.",
    "",
    "TAREA: $TaskId",
    "CANDIDATE COMMIT: $candidateCommit",
    "BASE: main",
    "",
    "PLAN (01-plan.md):",
    "---",
    $planContent,
    "---",
    "",
    "IMPLEMENTACION (03-google.md):",
    "---",
    $googleContent,
    "---",
    "",
    "DIFF main..HEAD:",
    "---",
    $fullDiff,
    "---",
    "",
    "SKILLS ACTIVAS (PROJECT-SKILLS.md):",
    "---",
    $skillsContent,
    "---",
    "",
    "CRITERIOS DE REVIEW (7 hallazgos obligatorios):",
    "1. archivos_fuera_de_alcance: Hay archivos en el diff fuera de google_scope del plan?",
    "2. sin_urls_externas: Hay https://, cdn., googleapis en el codigo?",
    "3. html_semantico: Hay 1 h1, h2 por seccion, h3 en tarjetas, lang=es, landmarks header/main/footer?",
    "4. responsive_implementado: Hay media queries para 1440, 768, 390?",
    "5. accesibilidad_basica: Focus visible, contraste suficiente, jerarquia de headings?",
    "6. js_sin_errores: El JS es sintacticamente valido, sin eval, sin requests externos?",
    "7. contenido_ficticio_marcado: Los testimonios estan marcados como ficticios con Ejemplo ficticio visible?",
    "",
    "INSTRUCCIONES:",
    "- Devuelve SOLO el JSON que cumple el schema.",
    "- No uses herramientas, archivos, shell, network, MCP.",
    "- No expliques el razonamiento.",
    "- Marca cada hallazgo PASS o FAIL con evidencia.",
    "- Si algun hallazgo es FAIL, status debe ser REVIEW_FAIL.",
    "- Si hay un error tecnico que impide el review, status debe ser REVIEW_BLOCKED."
)

$prompt = $promptLines -join "`n"
$promptHash = (Get-FileHash -InputStream ([System.IO.MemoryStream]::new([System.Text.Encoding]::UTF8.GetBytes($prompt))) -Algorithm SHA256).Hash
Write-Log "Prompt: $($prompt.Length) chars, hash=$promptHash"

# ============================================================
# SCHEMA (compacto para CLI)
# ============================================================
$schemaJson = @"
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
            "required": ["archivos_fuera_de_alcance","sin_urls_externas","html_semantico","responsive_implementado","accesibilidad_basica","js_sin_errores","contenido_ficticio_marcado"],
            "properties": {
                "archivos_fuera_de_alcance": {"type": "string", "enum": ["PASS","FAIL"]},
                "sin_urls_externas": {"type": "string", "enum": ["PASS","FAIL"]},
                "html_semantico": {"type": "string", "enum": ["PASS","FAIL"]},
                "responsive_implementado": {"type": "string", "enum": ["PASS","FAIL"]},
                "accesibilidad_basica": {"type": "string", "enum": ["PASS","FAIL"]},
                "js_sin_errores": {"type": "string", "enum": ["PASS","FAIL"]},
                "contenido_ficticio_marcado": {"type": "string", "enum": ["PASS","FAIL"]}
            }
        },
        "observaciones": {"type": "array", "items": {"type": "string"}, "minItems": 1, "maxItems": 10}
    }
}
"@

# Compactar a una linea
$schemaCompact = ($schemaJson -replace '\s+', ' ').Trim()
Write-Log "Schema compactado: $($schemaCompact.Length) chars"

# ============================================================
# INVOCAR CLAUDE
# ============================================================
Write-Log ""
Write-Log "=== INVOCANDO CLAUDE ==="
Write-Log "Comando: claude --print <prompt> --output-format json --json-schema <schema> --model sonnet"

if (-not (Test-Path $ClaudeExe)) {
    Write-Log "FALLA: no existe $ClaudeExe" "ERROR"
    exit 5
}

$args = @(
    "--print"
    $prompt
    "--output-format", "json"
    "--json-schema", $schemaCompact
    "--model", "sonnet"
    "--permission-prompts", "none"
)

$claudeStart = Get-Date
try {
    $claudeStdout = & $ClaudeExe @args 2>&1 | Out-String
    $claudeExitCode = $LASTEXITCODE
} catch {
    Write-Log "EXCEPCION en claude: $_" "ERROR"
    exit 5
}
$claudeDuration = ((Get-Date) - $claudeStart).TotalSeconds

Write-Log "Claude exit code: $claudeExitCode"
Write-Log "Claude duracion: $([math]::Round($claudeDuration, 2))s"
Write-Log "Stdout: $($claudeStdout.Length) chars"

# Guardar raw response para auditoria
Set-Content -LiteralPath $RawResponsePath -Value $claudeStdout -Encoding UTF8

if ($claudeExitCode -ne 0) {
    Write-Log "FALLA: claude exit code no es 0. Ver $RawResponsePath" "ERROR"
    exit 5
}

if (-not $claudeStdout.Trim()) {
    Write-Log "FALLA: stdout vacio" "ERROR"
    exit 5
}

# ============================================================
# PARSEAR RESPUESTA
# ============================================================
Write-Log ""
Write-Log "=== PARSEANDO RESPUESTA ==="

try {
    $claudeResult = $claudeStdout | ConvertFrom-Json
} catch {
    Write-Log "FALLA: stdout no es JSON valido: $_" "ERROR"
    exit 2
}

if (-not $claudeResult.structured_output) {
    Write-Log "FALLA: falta structured_output en la respuesta" "ERROR"
    Write-Log ("Respuesta: " + ($claudeResult | ConvertTo-Json -Depth 3 -Compress)) "ERROR"
    exit 2
}

$so = $claudeResult.structured_output
Write-Log "structured_output parseado OK"

# ============================================================
# VALIDAR CAMPOS
# ============================================================
Write-Log ""
Write-Log "=== VALIDANDO CAMPOS ==="

$errors = @()

# status
if ($so.status -notin @("REVIEW_PASS","REVIEW_FAIL","REVIEW_BLOCKED")) {
    $errors += "status invalido: '$($so.status)'"
}
Write-Log "status: $($so.status)"

# candidate_commit
if ($so.candidate_commit -notmatch '^[a-f0-9]{40}$') {
    $errors += "candidate_commit invalido: '$($so.candidate_commit)'"
}
if ($so.candidate_commit -ne $candidateCommit) {
    $errors += "candidate_commit no coincide. Esperado: $candidateCommit, obtenido: $($so.candidate_commit)"
}
Write-Log "candidate_commit: $($so.candidate_commit)"

# hallazgos (7 campos)
$hallazgoKeys = @("archivos_fuera_de_alcance","sin_urls_externas","html_semantico","responsive_implementado","accesibilidad_basica","js_sin_errores","contenido_ficticio_marcado")
foreach ($k in $hallazgoKeys) {
    if (-not $so.hallazgos.$k) {
        $errors += "hallazgo faltante: $k"
    } elseif ($so.hallazgos.$k -notin @("PASS","FAIL")) {
        $errors += "hallazgo invalido '$k': '$($so.hallazgos.$k)'"
    }
    Write-Log "  $k : $($so.hallazgos.$k)"
}

# observaciones
if (-not $so.observaciones -or $so.observaciones.Count -lt 1) {
    $errors += "observaciones vacio (min 1)"
} elseif ($so.observaciones.Count -gt 10) {
    $errors += "observaciones excede 10 elementos"
}
Write-Log "observaciones: $($so.observaciones.Count) elementos"

if ($errors.Count -gt 0) {
    Write-Log ""
    Write-Log "VALIDACION FALLO ($($errors.Count) errores):" "ERROR"
    foreach ($e in $errors) { Write-Log "  - $e" "ERROR" }
    exit 2
}

Write-Log "Validacion OK: 0 errores"

# ============================================================
# DETERMINAR EXIT CODE
# ============================================================
$exitCode = switch ($so.status) {
    "REVIEW_PASS"    { 0 }
    "REVIEW_FAIL"    { 3 }
    "REVIEW_BLOCKED" { 4 }
    default          { 2 }
}
Write-Log "Exit code determinado: $exitCode"

# ============================================================
# ESCRIBIR 04-claude-review.md
# ============================================================
Write-Log ""
Write-Log "=== ESCRIBIENDO 04-claude-review.md ==="

$obsLines = ($so.observaciones | ForEach-Object { "  - $_" }) -join "`n"

$reviewYaml = @"
task_id: $TaskId
reviewer: Claude Code (orchestrator automated)
reviewed_utc: $((Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'))
candidate_commit: $($so.candidate_commit)
base_commit: $baseCommit

archivos_revisados:
  - index.html
  - styles.css
  - script.js

diff_stats:
  archivos_modificados: 3
  lineas_agregadas: 680
  lineas_eliminadas: 0

hallazgos:
  archivos_fuera_de_alcance: $($so.hallazgos.archivos_fuera_de_alcance)
  sin_urls_externas: $($so.hallazgos.sin_urls_externas)
  html_semantico: $($so.hallazgos.html_semantico)
  responsive_implementado: $($so.hallazgos.responsive_implementado)
  accesibilidad_basica: $($so.hallazgos.accesibilidad_basica)
  js_sin_errores: $($so.hallazgos.js_sin_errores)
  contenido_ficticio_marcado: $($so.hallazgos.contenido_ficticio_marcado)

observaciones:
$obsLines

orchestrator_metadata:
  prompt_hash: $promptHash
  claude_duration_seconds: $([math]::Round($claudeDuration, 2))
  raw_response_path: $RawResponsePath

status: $($so.status)
"@

Set-Content -LiteralPath $ReviewPath -Value $reviewYaml -Encoding UTF8
Write-Log "04-claude-review.md escrito: $((Get-Item $ReviewPath).Length) bytes"

Write-Log ""
Write-Log "=== run-review-step END (exit $exitCode) ==="
exit $exitCode
