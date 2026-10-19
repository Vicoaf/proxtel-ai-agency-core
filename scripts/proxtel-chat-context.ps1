param(
    [Parameter(Mandatory=$true)]
    [string]$Project
)

$ErrorActionPreference = 'Stop'

function Read-JsonSafe {

    param(
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return $null
    }

    return Get-Content `
        -LiteralPath $Path `
        -Raw `
        -Encoding UTF8 |
        ConvertFrom-Json `
            -ErrorAction Stop
}


function Invoke-GitSafe {

    param(
        [string]$Repository,
        [string[]]$Arguments
    )

    try {

        $Output = @(
            & git `
                -C $Repository `
                @Arguments `
                2>$null
        )

        if ($LASTEXITCODE -ne 0) {
            return $null
        }

        return (
            (
                @($Output) |
                ForEach-Object {
                    [string]$_
                }
            ) -join "`n"
        ).Trim()
    }
    catch {

        return $null
    }
}


function Escape-Md {

    param(
        $Value
    )

    if ($null -eq $Value) {
        return 'N/A'
    }

    $Text = [string]$Value

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return 'N/A'
    }

    return $Text
}


$ProjectRoot = (
    Resolve-Path `
        -LiteralPath $Project
).Path


$ProxtelRoot =
    Join-Path `
        $ProjectRoot `
        '.proxtel'


$ProjectManifestPath =
    Join-Path `
        $ProxtelRoot `
        'project.json'


if (
    -not (
        Test-Path `
            -LiteralPath $ProjectManifestPath `
            -PathType Leaf
    )
) {

    throw (
        "No es un proyecto PROXTEL válido: " +
        "$ProjectRoot"
    )
}


$ProjectManifest =
    Read-JsonSafe `
        $ProjectManifestPath


$State =
    Read-JsonSafe `
        (
            Join-Path `
                $ProxtelRoot `
                'state.json'
        )


$Queue =
    Read-JsonSafe `
        (
            Join-Path `
                $ProxtelRoot `
                'task-queue.json'
        )


$Approvals =
    Read-JsonSafe `
        (
            Join-Path `
                $ProxtelRoot `
                'approvals.json'
        )


$Evidence =
    Read-JsonSafe `
        (
            Join-Path `
                $ProxtelRoot `
                'evidence\index.json'
        )


$MemoryPath =
    Join-Path `
        $ProxtelRoot `
        'memory\PROJECT_CONTEXT.md'


$ProjectMemory = ''

if (
    Test-Path `
        -LiteralPath $MemoryPath `
        -PathType Leaf
) {

    $ProjectMemory =
        Get-Content `
            -LiteralPath $MemoryPath `
            -Raw `
            -Encoding UTF8
}


$CurrentTask =
    $null


if (
    $null -ne $State -and
    -not [string]::IsNullOrWhiteSpace(
        [string]$State.current_task
    )
) {

    $CurrentTaskPath =
        Join-Path `
            $ProxtelRoot `
            (
                'tasks\' +
                [string]$State.current_task +
                '.json'
            )


    $CurrentTask =
        Read-JsonSafe `
            $CurrentTaskPath
}


$TaskIds = @()

if ($null -ne $Queue) {

    $TaskIds =
        @($Queue.tasks)
}


$ApprovalItems = @()

if ($null -ne $Approvals) {

    $ApprovalItems =
        @($Approvals.approvals)
}


$EvidenceItems = @()

if ($null -ne $Evidence) {

    $EvidenceItems =
        @($Evidence.evidence)
}


$GitBranch =
    Invoke-GitSafe `
        -Repository $ProjectRoot `
        -Arguments @(
            'branch',
            '--show-current'
        )


$GitHead =
    Invoke-GitSafe `
        -Repository $ProjectRoot `
        -Arguments @(
            'rev-parse',
            'HEAD'
        )


$GitStatus =
    Invoke-GitSafe `
        -Repository $ProjectRoot `
        -Arguments @(
            'status',
            '--porcelain'
        )


$GitChanges =
    0


if (
    -not [string]::IsNullOrWhiteSpace(
        $GitStatus
    )
) {

    $GitChanges =
        @(
            $GitStatus -split "`n" |
            Where-Object {
                -not [string]::IsNullOrWhiteSpace($_)
            }
        ).Count
}


$Areas =
    @(
        $ProjectManifest.selected_areas
    ) -join ', '


$CurrentTaskSection =
    'No current task.'


if ($null -ne $CurrentTask) {

    $TaskAreas =
        @(
            $CurrentTask.routed_areas
        ) -join ', '


    $CurrentTaskSection = @"
Task ID: $(Escape-Md $CurrentTask.id)

Title: $(Escape-Md $CurrentTask.title)

Status: $(Escape-Md $CurrentTask.status)

Routed areas: $(Escape-Md $TaskAreas)

Request:

$(Escape-Md $CurrentTask.request)
"@
}


$GeneratedUtc =
    [DateTime]::UtcNow.ToString('o')


$Markdown = @"
# PROXTEL AI AGENCY — Chat Context Pack

Generated UTC: $GeneratedUtc

> This file contains the durable operating context for this project.
> It intentionally excludes `.env`, credentials, API keys, passwords and secrets.

---

## Instructions for a new AI chat

Continue this project using **PROXTEL AI AGENCY**.

Use this Context Pack as the current project baseline.

Preserve the project's existing architecture, decisions and constraints.

Do not invent project state that is not contained here or in files subsequently inspected.

Use the PROXTEL workflow:

Architecture → Implementation → QA → Security → Independent Review → Approval.

Do not perform Git commit, Git push, dependency installation, deployment, destructive database operations, production mutation or live PBX changes without explicit human authorization.

When implementation depends on current external library/framework documentation, prefer **Context7** when available.

---

# Project

Name: $(Escape-Md $ProjectManifest.name)

ID: $(Escape-Md $ProjectManifest.id)

Type: $(Escape-Md $ProjectManifest.type)

Root: $(Escape-Md $ProjectManifest.root)

Stack: $(Escape-Md $ProjectManifest.stack)

Status: $(Escape-Md $ProjectManifest.status)

Selected Agency areas:

$Areas

---

# Agency Runtime

Production Runtime: $(Escape-Md $ProjectManifest.agency.production_runtime)

Gold Master baseline: $(Escape-Md $ProjectManifest.agency.gold_master_commit)

Provider execution: $(Escape-Md $ProjectManifest.execution.provider_mode)

Automatic commit: $(Escape-Md $ProjectManifest.execution.automatic_commit)

Automatic push: $(Escape-Md $ProjectManifest.execution.automatic_push)

Automatic deploy: $(Escape-Md $ProjectManifest.execution.automatic_deploy)

QA required: $(Escape-Md $ProjectManifest.execution.qa_required)

Evidence required: $(Escape-Md $ProjectManifest.execution.evidence_required)

---

# Project State

State: $(Escape-Md $State.status)

Current task: $(Escape-Md $State.current_task)

Last state update UTC: $(Escape-Md $State.updated_utc)

Tasks in queue: $($TaskIds.Count)

Approvals recorded: $($ApprovalItems.Count)

Evidence records: $($EvidenceItems.Count)

---

# Current Task

$CurrentTaskSection

---

# Git State

Branch: $(Escape-Md $GitBranch)

HEAD: $(Escape-Md $GitHead)

Working-tree changes: $GitChanges

---

# Persistent Project Memory

$ProjectMemory

---

# Chat Operating Rules

1. Treat this Context Pack as project state, not as a replacement for inspecting source files.
2. Never assume a file exists simply because the architecture mentions it.
3. Before modifying existing code, inspect the actual file.
4. Prefer complete files when delivering code changes.
5. Preserve project-local `.proxtel` state.
6. Use Context7 for current framework/library/API documentation when useful.
7. Keep sensitive credentials out of this Context Pack.
8. Run QA before declaring implementation complete.
9. Independent review must not be performed by the same role that authored critical implementation.
10. Production-sensitive actions remain human-gated.

---

# Recommended first message in a new chat

Continue this project using PROXTEL AI AGENCY.

Use the attached `chat-context.md` as the authoritative starting context.

First validate the current task and project state. Then continue from the existing PROXTEL workflow without rebuilding completed work.
"@


$Destination =
    Join-Path `
        $ProxtelRoot `
        'chat-context.md'


$Encoding =
    New-Object `
        System.Text.UTF8Encoding($false)


[System.IO.File]::WriteAllText(
    $Destination,
    (
        $Markdown.TrimEnd(
            "`r",
            "`n"
        ) +
        "`n"
    ),
    $Encoding
)


$Hash = (
    Get-FileHash `
        -LiteralPath $Destination `
        -Algorithm SHA256
).Hash.ToUpperInvariant()


Write-Host ''
Write-Host '============================================================'
Write-Host ' PROXTEL CHAT CONTEXT PACK'
Write-Host '============================================================'

Write-Host 'CHAT_CONTEXT_STATUS=SUCCESS'
Write-Host "PROJECT=$($ProjectManifest.name)"
Write-Host "CONTEXT_FILE=$Destination"
Write-Host "CONTEXT_SHA256=$Hash"
Write-Host "TASKS=$($TaskIds.Count)"
Write-Host "CURRENT_TASK=$($State.current_task)"
Write-Host "AREAS=$Areas"
Write-Host 'SECRETS_INCLUDED=NO'
Write-Host 'NEXT_ACTION=ATTACH-CONTEXT-FILE-TO-CHAT'
