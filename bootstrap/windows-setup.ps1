# =====================================================================
# PROXTEL AI AGENCY - Bootstrap para Windows
# Preparación y verificación del entorno de la agencia.
# Idempotente: se puede ejecutar múltiples veces sin romper nada.
# Uso: Abrir PowerShell 7 como Administrador, en la raíz del Core:
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
#   .\bootstrap\windows-setup.ps1
# =====================================================================

$ErrorActionPreference = "Stop"

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host " PROXTEL AI AGENCY - Bootstrap Windows" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# ---------- Verificar que estamos en la raíz del Core ----------

$expectedRoot = "C:\DEV\PROXTEL-AI-AGENCY"
$currentRoot = (Get-Location).Path

if ($currentRoot -ne $expectedRoot) {
    Write-Host "AVISO: No estás en $expectedRoot" -ForegroundColor Yellow
    Write-Host "       Estás en: $currentRoot" -ForegroundColor Yellow
    $response = Read-Host "¿Continuar de todos modos? (s/n)"
    if ($response -ne "s") {
        Write-Host "Cancelado por el usuario." -ForegroundColor Red
        exit 1
    }
}

# ---------- Verificar PowerShell 7 ----------

Write-Host "[1/8] Verificando PowerShell 7..." -ForegroundColor Yellow

if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "  ERROR: Se requiere PowerShell 7 o superior." -ForegroundColor Red
    Write-Host "  Instalar desde: https://aka.ms/powershell" -ForegroundColor Red
    exit 1
}
Write-Host "  OK: PowerShell $($PSVersionTable.PSVersion)" -ForegroundColor Green

# ---------- Verificar Git ----------

Write-Host "[2/8] Verificando Git..." -ForegroundColor Yellow

if (Get-Command git -ErrorAction SilentlyContinue) {
    $gitVersion = (git --version) -replace "git version ", ""
    Write-Host "  OK: Git $gitVersion" -ForegroundColor Green
} else {
    Write-Host "  ERROR: Git no instalado." -ForegroundColor Red
    Write-Host "  Instalar desde: https://git-scm.com/download/win" -ForegroundColor Red
    exit 1
}

# ---------- Verificar Node.js ----------

Write-Host "[3/8] Verificando Node.js..." -ForegroundColor Yellow

if (Get-Command node -ErrorAction SilentlyContinue) {
    $nodeVersion = node --version
    Write-Host "  OK: Node $nodeVersion" -ForegroundColor Green
} else {
    Write-Host "  ERROR: Node.js no instalado." -ForegroundColor Red
    Write-Host "  Instalar desde: https://nodejs.org (LTS 20 o superior)" -ForegroundColor Red
    exit 1
}

if (Get-Command npm -ErrorAction SilentlyContinue) {
    $npmVersion = npm --version
    Write-Host "  OK: npm $npmVersion" -ForegroundColor Green
} else {
    Write-Host "  ERROR: npm no encontrado." -ForegroundColor Red
    exit 1
}

# ---------- Verificar PHP y Composer ----------

Write-Host "[4/8] Verificando PHP y Composer..." -ForegroundColor Yellow

if (Get-Command php -ErrorAction SilentlyContinue) {
    $phpVersion = (php -r "echo PHP_VERSION;")
    Write-Host "  OK: PHP $phpVersion" -ForegroundColor Green
} else {
    Write-Host "  AVISO: PHP no instalado (necesario para proyectos Laravel)." -ForegroundColor Yellow
    Write-Host "  Instalar: Laravel Herd desde https://herd.laravel.com" -ForegroundColor Yellow
}

if (Get-Command composer -ErrorAction SilentlyContinue) {
    $composerVersion = (composer --version 2>&1) -replace "Composer version ", ""
    Write-Host "  OK: Composer $composerVersion" -ForegroundColor Green
} else {
    Write-Host "  AVISO: Composer no instalado." -ForegroundColor Yellow
    Write-Host "  Se instala junto con Laravel Herd." -ForegroundColor Yellow
}

# ---------- Verificar las 3 CLIs de IA ----------

Write-Host "[5/8] Verificando CLIs de IA..." -ForegroundColor Yellow

# Claude Code
if (Get-Command claude -ErrorAction SilentlyContinue) {
    Write-Host "  OK: Claude Code instalado" -ForegroundColor Green
} else {
    Write-Host "  AVISO: Claude Code no instalado." -ForegroundColor Yellow
    Write-Host "  Instalar con: npm install -g @anthropic-ai/claude-code" -ForegroundColor Yellow
}

# Codex CLI
if (Get-Command codex -ErrorAction SilentlyContinue) {
    Write-Host "  OK: Codex CLI instalado" -ForegroundColor Green
} else {
    Write-Host "  AVISO: Codex CLI no instalado." -ForegroundColor Yellow
    Write-Host "  Instalar con: npm install -g @openai/codex" -ForegroundColor Yellow
}

# Antigravity
if ((Get-Command agy -ErrorAction SilentlyContinue) -or (Get-Command antigravity -ErrorAction SilentlyContinue)) {
    Write-Host "  OK: Antigravity CLI instalado" -ForegroundColor Green
} else {
    Write-Host "  AVISO: Antigravity no encontrado." -ForegroundColor Yellow
    Write-Host "  Instalar desde su instalador oficial (no vía npm)." -ForegroundColor Yellow
}

# ---------- Crear symlinks / copias de archivos de configuración ----------

Write-Host "[6/8] Configurando archivos globales de CLIs..." -ForegroundColor Yellow

# Claude Code: ~/.claude/CLAUDE.md
$claudeDir = Join-Path $env:USERPROFILE ".claude"
if (-not (Test-Path $claudeDir)) {
    New-Item -ItemType Directory -Force -Path $claudeDir | Out-Null
}

$claudeGlobal = Join-Path $claudeDir "CLAUDE.md"
$claudeSource = Join-Path $currentRoot "CLAUDE.md"

if (Test-Path $claudeGlobal) {
    Write-Host "  AVISO: Ya existe $claudeGlobal" -ForegroundColor Yellow
    $resp = Read-Host "  ¿Sobrescribir con copia del Core? (s/n)"
    if ($resp -eq "s") {
        Copy-Item -Path $claudeSource -Destination $claudeGlobal -Force
        Write-Host "  OK: CLAUDE.md copiado a $claudeGlobal" -ForegroundColor Green
    } else {
        Write-Host "  Saltado: se conserva el existente." -ForegroundColor Yellow
    }
} else {
    # Intentar symlink primero (requiere admin o Developer Mode)
    try {
        New-Item -ItemType SymbolicLink -Path $claudeGlobal -Target $claudeSource -Force | Out-Null
        Write-Host "  OK: symlink CLAUDE.md -> $claudeGlobal" -ForegroundColor Green
    } catch {
        Copy-Item -Path $claudeSource -Destination $claudeGlobal -Force
        Write-Host "  OK: copia CLAUDE.md -> $claudeGlobal (sin symlink)" -ForegroundColor Green
        Write-Host "  NOTA: si modificas CLAUDE.md en el Core, recuerda re-copiar." -ForegroundColor Yellow
    }
}

# Antigravity: ~/.gemini/GEMINI.md
$geminiDir = Join-Path $env:USERPROFILE ".gemini"
if (-not (Test-Path $geminiDir)) {
    New-Item -ItemType Directory -Force -Path $geminiDir | Out-Null
}

$geminiGlobal = Join-Path $geminiDir "GEMINI.md"
$geminiSource = Join-Path $currentRoot "GEMINI.md"

if (Test-Path $geminiGlobal) {
    Write-Host "  AVISO: Ya existe $geminiGlobal" -ForegroundColor Yellow
    $resp = Read-Host "  ¿Sobrescribir con copia del Core? (s/n)"
    if ($resp -eq "s") {
        Copy-Item -Path $geminiSource -Destination $geminiGlobal -Force
        Write-Host "  OK: GEMINI.md copiado a $geminiGlobal" -ForegroundColor Green
    } else {
        Write-Host "  Saltado: se conserva el existente." -ForegroundColor Yellow
    }
} else {
    try {
        New-Item -ItemType SymbolicLink -Path $geminiGlobal -Target $geminiSource -Force | Out-Null
        Write-Host "  OK: symlink GEMINI.md -> $geminiGlobal" -ForegroundColor Green
    } catch {
        Copy-Item -Path $geminiSource -Destination $geminiGlobal -Force
        Write-Host "  OK: copia GEMINI.md -> $geminiGlobal (sin symlink)" -ForegroundColor Green
        Write-Host "  NOTA: si modificas GEMINI.md en el Core, recuerda re-copiar." -ForegroundColor Yellow
    }
}

# ---------- Verificar Playwright MCP ----------

Write-Host "[7/8] Verificando Playwright MCP..." -ForegroundColor Yellow

if (Get-Command npx -ErrorAction SilentlyContinue) {
    try {
        $playwrightVersion = (npx playwright --version 2>&1) -replace "Version ", ""
        Write-Host "  OK: Playwright disponible ($playwrightVersion)" -ForegroundColor Green
    } catch {
        Write-Host "  AVISO: Playwright no instalado globalmente." -ForegroundColor Yellow
        Write-Host "  Se instala por proyecto: npm install --save-dev @playwright/test" -ForegroundColor Yellow
    }
} else {
    Write-Host "  AVISO: npx no encontrado." -ForegroundColor Yellow
}

# ---------- Verificar configuración de Git ----------

Write-Host "[8/8] Verificando configuración de Git..." -ForegroundColor Yellow

$gitUser = (git config --global user.name) 2>$null
$gitEmail = (git config --global user.email) 2>$null

if ($gitUser) {
    Write-Host "  OK: git user.name = $gitUser" -ForegroundColor Green
} else {
    Write-Host "  AVISO: git user.name no configurado." -ForegroundColor Yellow
    Write-Host "  Ejecutar: git config --global user.name ""Tu Nombre""" -ForegroundColor Yellow
}

if ($gitEmail) {
    Write-Host "  OK: git user.email = $gitEmail" -ForegroundColor Green
} else {
    Write-Host "  AVISO: git user.email no configurado." -ForegroundColor Yellow
    Write-Host "  Ejecutar: git config --global user.email ""tu@email.com""" -ForegroundColor Yellow
}

# ---------- Resumen final ----------

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host " Bootstrap Windows completado" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Siguiente paso manual:" -ForegroundColor Yellow
Write-Host "  1. Si alguna CLI no está instalada, seguir las instrucciones arriba." -ForegroundColor White
Write-Host "  2. Autenticar cada CLI por primera vez:" -ForegroundColor White
Write-Host "     - claude  (sigue el flujo de login)" -ForegroundColor Gray
Write-Host "     - codex   (sigue el flujo de login)" -ForegroundColor Gray
Write-Host "     - agy     (sigue el flujo de login)" -ForegroundColor Gray
Write-Host "  3. Verificar que los .env de cada proyecto existan localmente." -ForegroundColor White
Write-Host "  4. Verificar acceso a los repos de clientes con: git ls-remote <repo>" -ForegroundColor White
Write-Host ""
Write-Host "Cuando todo esté verde, ejecutar el State Brief de prueba:" -ForegroundColor Yellow
Write-Host "  cd <repo-de-prueba>" -ForegroundColor Gray
Write-Host "  (seguir el script de docs/architecture-v3.md sección 4.1)" -ForegroundColor Gray
Write-Host ""
