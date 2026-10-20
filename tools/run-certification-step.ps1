<#
.SYNOPSIS
    Ejecuta el paso 6 del ciclo V3 (certification) de forma automatizada.

.DESCRIPTION
    Invoca claude --print con resumen de las 5 evidencias para generar
    06-certification.yaml. Implementa el contrato en tools/orchestrator-contract.md.

.PARAMETER TaskId
    ID de la tarea (ej. T-0001).

.PARAMETER WorkingDir
    Worktree de integracion (ej. C:\DEV\piloto-v3-T-0001-int).

.EXAMPLE
    .\run-certification-step.ps1 -TaskId "T-0001" -WorkingDir "C:\DEV\piloto-v3-T-0001-int"

.EXITCODES
    0 = READY_FOR_MERGE_AUTHORIZATION
    1 = Pre-flight fallo
    2 = Claude devolvio output invalido
    3 = BLOCKED
    5 = Error de invocacion
#>
param(
    [Parameter(Mandatory=$true)][string]$TaskId,
    [Parameter(Mandatory=$true)][string]$WorkingDir
)

$ErrorActionPreference = 'Stop'

# F13: Forzar UTF-8 en el output de PowerShell (arregla mojibake en git diff)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

$ClaudeExe = "C:\Users\MSI\AppData\Roaming\npm\node_modules\@anthropic-ai\claude-code\bin\claude.exe"

$AuditDir            = Join-Path $WorkingDir ".agency-local\audit\$TaskId"
$LogDir              = Join-Path $AuditDir "logs"
$PlanPath            = Join-Path $AuditDir "01-plan.md"
$GooglePath          = Join-Path $AuditDir "03-google.md"
$ReviewPath          = Join-Path $AuditDir "04-claude-review.md"
$PlaywrightPath      = Join-Path $AuditDir "05-playwright.md"
$CertPath            = Join-Path $AuditDir "06-certification.yaml"
$CertErrorPath       = Join-Path $AuditDir "06-certification.ERROR.md"
$LogPath             = Join-Path $LogDir "orchestrator-certification.log"
$RawResponsePath     = Join-Path $LogDir "claude-certification-raw.json"

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
    Set-Content -Path $CertErrorPath -Value $msg -Encoding UTF8
    exit 1
}

# ============================================================
# VALIDACION DE WORKINGDIR (primero, antes de crear nada)
# ============================================================
if (-not (Test-Path $WorkingDir)) {
    Write-Host "FALLA: WorkingDir no existe: $WorkingDir" -ForegroundColor Red
    exit 1
}

# Solo despues de validar, crear LogDir
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

Write-Log "=== run-certification-step START ==="
Write-Log "TaskId: $TaskId"
Write-Log "WorkingDir: $WorkingDir"
Write-Log ""

# ============================================================
# PRE-FLIGHT CHECKS
# ============================================================
Write-Log "=== PRE-FLIGHT ==="

Push-Location $WorkingDir
try {
    $statusPorcelain = git status --porcelain 2>&1 | Out-String
    if ($statusPorcelain.Trim()) {
        Fail-Preflight "Working tree no esta clean. Cambios pendientes: $statusPorcelain"
    }
    Write-Log "OK: working tree clean"

    $currentBranch = (git branch --show-current 2>&1 | Out-String).Trim()
    $expectedBranch = "task/$TaskId-int"
    if ($currentBranch -ne $expectedBranch) {
        Fail-Preflight "Rama incorrecta. Actual: '$currentBranch', esperada: '$expectedBranch'"
    }
    Write-Log "OK: rama correcta ($currentBranch)"

    $candidateCommit = (git rev-parse HEAD 2>&1 | Out-String).Trim()
    if ($candidateCommit -notmatch '^[a-f0-9]{40}$') {
        Fail-Preflight "SHA invalido: '$candidateCommit'"
    }
    Write-Log "OK: candidate commit = $candidateCommit"

} finally {
    Pop-Location
}

# Evidencias existen
$requiredFiles = @(
    @{Path=$PlanPath; Name="01-plan.md"},
    @{Path=$GooglePath; Name="03-google.md"},
    @{Path=$ReviewPath; Name="04-claude-review.md"},
    @{Path=$PlaywrightPath; Name="05-playwright.md"}
)
foreach ($f in $requiredFiles) {
    if (-not (Test-Path $f.Path)) {
        Fail-Preflight "Falta evidencia: $($f.Name) en $($f.Path)"
    }
}
Write-Log "OK: 4 evidencias presentes"

# Review PASS
$reviewContent = Get-Content -LiteralPath $ReviewPath -Raw -Encoding UTF8
if ($reviewContent -notmatch '(?m)^status:\s*REVIEW_PASS') {
    Fail-Preflight "04-claude-review.md no tiene status: REVIEW_PASS"
}
Write-Log "OK: review tiene REVIEW_PASS"

# Playwright + Vic PASS
$playwrightContent = Get-Content -LiteralPath $PlaywrightPath -Raw -Encoding UTF8
if ($playwrightContent -notmatch 'QA_PASS') {
    Fail-Preflight "05-playwright.md no tiene QA_PASS"
}
if ($playwrightContent -notmatch 'VISUAL_PASS') {
    Fail-Preflight "05-playwright.md no tiene VISUAL_PASS"
}
if ($playwrightContent -notmatch 'APPROVED') {
    Fail-Preflight "05-playwright.md no tiene APPROVED"
}
Write-Log "OK: playwright QA_PASS + VISUAL_PASS + APPROVED"

# candidate_commit coincide
$reviewCandidateMatch = [regex]::Match($reviewContent, '(?m)^candidate_commit:\s*([a-f0-9]{40})')
if (-not $reviewCandidateMatch.Success) {
    Fail-Preflight "No se pudo extraer candidate_commit de 04-claude-review.md"
}
$reviewCandidate = $reviewCandidateMatch.Groups[1].Value
if ($reviewCandidate -ne $candidateCommit) {
    Fail-Preflight "candidate_commit no coincide. Review: $reviewCandidate, HEAD: $candidateCommit"
}
Write-Log "OK: candidate_commit coincide ($candidateCommit)"

Write-Log ""
Write-Log "=== LEYENDO CONTEXTO ==="

$planContent       = Get-Content -LiteralPath $PlanPath -Raw -Encoding UTF8
$googleContent     = Get-Content -LiteralPath $GooglePath -Raw -Encoding UTF8
$playwrightContent = Get-Content -LiteralPath $PlaywrightPath -Raw -Encoding UTF8
Write-Log "01-plan.md: $($planContent.Length) chars"
Write-Log "03-google.md: $($googleContent.Length) chars"
Write-Log "04-claude-review.md: $($reviewContent.Length) chars"
Write-Log "05-playwright.md: $($playwrightContent.Length) chars"

# ============================================================
# COMPONER PROMPT
# ============================================================
Write-Log ""
Write-Log "=== COMPONIENDO PROMPT ==="

$promptLines = @(
    "Eres el certificador del paso 6 del ciclo V3 de PROXTEL AI Agency.",
    "",
    "TAREA: $TaskId",
    "CANDIDATE COMMIT: $candidateCommit",
    "",
    "EVIDENCIAS:",
    "",
    "01-plan.md:",
    "---",
    $planContent,
    "---",
    "",
    "03-google.md:",
    "---",
    $googleContent,
    "---",
    "",
    "04-claude-review.md:",
    "---",
    $reviewContent,
    "---",
    "",
    "05-playwright.md:",
    "---",
    $playwrightContent,
    "---",
    "",
    "INSTRUCCIONES:",
    "- Devuelve SOLO el JSON que cumple el schema.",
    "- No uses herramientas, archivos, shell, network, MCP.",
    "- No expliques el razonamiento.",
    "- task_id debe ser exactamente: $TaskId",
    "- candidate_commit debe ser exactamente: $candidateCommit",
    "- candidate_branch debe ser exactamente: task/$TaskId-int",
    "- implementation_backend.status debe ser NOT_APPLICABLE si no hubo backend (ver codex_scope en 01-plan.md)",
    "- implementation_frontend.status debe ser PASS si 03-google.md tiene FRONTEND_PASS",
    "- claude_review.status debe ser PASS si 04-claude-review.md tiene REVIEW_PASS",
    "- playwright_qa.status debe ser PASS si 05-playwright.md tiene QA_PASS",
    "- visual_review_vic.status debe ser PASS si 05-playwright.md tiene VISUAL_PASS, reviewer=Vic",
    "- acceptance_vic.status debe ser APPROVED si 05-playwright.md tiene APPROVED",
    "- main_merge_machine debe ser WINDOWS_PC",
    "- audit_versioned debe ser false",
    "- worktrees_synced debe ser false",
    "- status final READY_FOR_MERGE_AUTHORIZATION si TODOS los checks son PASS/APPROVED/NOT_APPLICABLE",
    "- Si algun check critico no es PASS, status debe ser BLOCKED",
    "- notes debe incluir al menos 3 lineas explicando el contexto"
)

$prompt = $promptLines -join "`n"
$promptHash = (Get-FileHash -InputStream ([System.IO.MemoryStream]::new([System.Text.Encoding]::UTF8.GetBytes($prompt))) -Algorithm SHA256).Hash
Write-Log "Prompt: $($prompt.Length) chars, hash=$promptHash"

# Schema compacto
$schemaJson = @"
{
    "type": "object",
    "additionalProperties": false,
    "required": ["task_id","candidate_branch","candidate_commit","implementation_backend","implementation_frontend","claude_review","playwright_qa","visual_review_vic","acceptance_vic","main_merge_machine","audit_versioned","worktrees_synced","status","notes"],
    "properties": {
        "task_id": {"type": "string"},
        "candidate_branch": {"type": "string"},
        "candidate_commit": {"type": "string", "pattern": "^[a-f0-9]{40}$"},
        "implementation_backend": {"type": "object", "required": ["status","evidence"], "properties": {"status": {"type": "string", "enum": ["PASS","NOT_APPLICABLE","FAIL"]}, "evidence": {"type": "string"}, "note": {"type": "string"}}},
        "implementation_frontend": {"type": "object", "required": ["status","evidence"], "properties": {"status": {"type": "string", "enum": ["PASS","NOT_APPLICABLE","FAIL"]}, "evidence": {"type": "string"}}},
        "claude_review": {"type": "object", "required": ["status","evidence"], "properties": {"status": {"type": "string", "enum": ["PASS","FAIL"]}, "evidence": {"type": "string"}}},
        "playwright_qa": {"type": "object", "required": ["status","evidence"], "properties": {"status": {"type": "string", "enum": ["PASS","FAIL"]}, "evidence": {"type": "string"}}},
        "visual_review_vic": {"type": "object", "required": ["status","reviewer","evidence"], "properties": {"status": {"type": "string", "enum": ["PASS","FAIL"]}, "reviewer": {"type": "string", "enum": ["Vic"]}, "evidence": {"type": "string"}}},
        "acceptance_vic": {"type": "object", "required": ["status","evidence"], "properties": {"status": {"type": "string", "enum": ["APPROVED","REJECTED"]}, "evidence": {"type": "string"}}},
        "main_merge_machine": {"type": "string", "enum": ["WINDOWS_PC"]},
        "audit_versioned": {"type": "boolean"},
        "worktrees_synced": {"type": "boolean"},
        "status": {"type": "string", "enum": ["READY_FOR_MERGE_AUTHORIZATION","BLOCKED"]},
        "notes": {"type": "array", "items": {"type": "string"}, "minItems": 3, "maxItems": 10}
    }
}
"@

$schemaCompact = ($schemaJson -replace '\s+', ' ').Trim()
Write-Log "Schema compactado: $($schemaCompact.Length) chars"

# ============================================================
# INVOCAR CLAUDE
# ============================================================
Write-Log ""
Write-Log "=== INVOCANDO CLAUDE ==="

if (-not (Test-Path $ClaudeExe)) {
    Write-Log "FALLA: no existe $ClaudeExe" "ERROR"
    exit 5
}

$claudeArgs = @(
    "--print"
    $prompt
    "--output-format", "json"
    "--json-schema", $schemaCompact
    "--model", "sonnet"
    "--permission-prompts", "none"
)

$claudeStart = Get-Date
try {
    $claudeStdout = & $ClaudeExe @claudeArgs 2>&1 | Out-String
    $claudeExitCode = $LASTEXITCODE
} catch {
    Write-Log "EXCEPCION en claude: $_" "ERROR"
    exit 5
}
$claudeDuration = ((Get-Date) - $claudeStart).TotalSeconds

Write-Log "Claude exit code: $claudeExitCode"
Write-Log "Claude duracion: $([math]::Round($claudeDuration, 2))s"
Write-Log "Stdout: $($claudeStdout.Length) chars"

Set-Content -LiteralPath $RawResponsePath -Value $claudeStdout -Encoding UTF8

if ($claudeExitCode -ne 0) {
    Write-Log "FALLA: claude exit code no es 0" "ERROR"
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
    Write-Log "FALLA: falta structured_output" "ERROR"
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

# task_id
if ($so.task_id -ne $TaskId) {
    $errors += "task_id '$($so.task_id)' != '$TaskId'"
}

# candidate_commit
if ($so.candidate_commit -ne $candidateCommit) {
    $errors += "candidate_commit '$($so.candidate_commit)' != '$candidateCommit'"
}

# candidate_branch
$expectedBranchName = "task/$TaskId-int"
if ($so.candidate_branch -ne $expectedBranchName) {
    $errors += "candidate_branch '$($so.candidate_branch)' != '$expectedBranchName'"
}

# sub-estados
$checks = @(
    @{Path="implementation_backend";  Prop="status"; Valid=@("PASS","NOT_APPLICABLE")},
    @{Path="implementation_frontend"; Prop="status"; Valid=@("PASS")},
    @{Path="claude_review";           Prop="status"; Valid=@("PASS")},
    @{Path="playwright_qa";           Prop="status"; Valid=@("PASS")},
    @{Path="visual_review_vic";       Prop="status"; Valid=@("PASS")},
    @{Path="acceptance_vic";          Prop="status"; Valid=@("APPROVED")}
)

foreach ($c in $checks) {
    $obj = $so.($c.Path)
    if (-not $obj -or -not $obj.status) {
        $errors += "$($c.Path).status faltante"
        continue
    }
    if ($obj.status -notin $c.Valid) {
        $errors += "$($c.Path).status '$($obj.status)' no esta en ($($c.Valid -join ','))"
    }
    Write-Log "  $($c.Path).status : $($obj.status)"
}

# visual_review_vic.reviewer
if ($so.visual_review_vic.reviewer -ne "Vic") {
    $errors += "visual_review_vic.reviewer debe ser Vic"
}

# main_merge_machine
if ($so.main_merge_machine -ne "WINDOWS_PC") {
    $errors += "main_merge_machine debe ser WINDOWS_PC"
}

# booleans
if ($so.audit_versioned -ne $false) {
    $errors += "audit_versioned debe ser false"
}
if ($so.worktrees_synced -ne $false) {
    $errors += "worktrees_synced debe ser false"
}

# status global
if ($so.status -notin @("READY_FOR_MERGE_AUTHORIZATION","BLOCKED")) {
    $errors += "status '$($so.status)' invalido"
}

# notes
if (-not $so.notes -or $so.notes.Count -lt 3) {
    $errors += "notes debe tener al menos 3 elementos (actual: $($so.notes.Count))"
}

Write-Log "status: $($so.status)"
Write-Log "notes: $($so.notes.Count) elementos"

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
$exitCode = if ($so.status -eq "READY_FOR_MERGE_AUTHORIZATION") { 0 } else { 3 }
Write-Log "Exit code determinado: $exitCode"

# ============================================================
# ESCRIBIR 06-certification.yaml
# ============================================================
Write-Log ""
Write-Log "=== ESCRIBIENDO 06-certification.yaml ==="

$notesYaml = ($so.notes | ForEach-Object { "  - `"$_`"" }) -join "`n"
$backendNote = if ($so.implementation_backend.note) { "`n  note: `"$($so.implementation_backend.note)`"" } else { "" }

$certYaml = @"
task_id: $($so.task_id)

candidate_branch: $($so.candidate_branch)
candidate_commit: "$($so.candidate_commit)"

implementation_backend:
  status: $($so.implementation_backend.status)
  evidence: "$($so.implementation_backend.evidence)"$backendNote

implementation_frontend:
  status: $($so.implementation_frontend.status)
  evidence: $($so.implementation_frontend.evidence)

claude_review:
  status: $($so.claude_review.status)
  evidence: $($so.claude_review.evidence)

playwright_qa:
  status: $($so.playwright_qa.status)
  evidence: $($so.playwright_qa.evidence)

visual_review_vic:
  status: $($so.visual_review_vic.status)
  reviewer: $($so.visual_review_vic.reviewer)
  evidence: $($so.visual_review_vic.evidence)

acceptance_vic:
  status: $($so.acceptance_vic.status)
  evidence: $($so.acceptance_vic.evidence)

main_merge_machine: $($so.main_merge_machine)
audit_versioned: $($so.audit_versioned.ToString().ToLower())
worktrees_synced: $($so.worktrees_synced.ToString().ToLower())

verification:
  evidence_files_present: true
  frontend_pass: true
  review_pass: true
  qa_pass: true
  visual_pass: true
  acceptance_approved: true
  candidate_commit_matches: true

status: $($so.status)

notes:
$notesYaml

orchestrator_metadata:
  prompt_hash: $promptHash
  claude_duration_seconds: $([math]::Round($claudeDuration, 2))
  raw_response_path: $RawResponsePath
  generated_utc: $((Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'))
"@

Set-Content -LiteralPath $CertPath -Value $certYaml -Encoding UTF8
Write-Log "06-certification.yaml escrito: $((Get-Item $CertPath).Length) bytes"

Write-Log ""
Write-Log "=== run-certification-step END (exit $exitCode) ==="
exit $exitCode
