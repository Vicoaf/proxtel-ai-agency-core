<#
.SYNOPSIS
    Valida la integridad estructural de PROJECT-SKILLS.md en un proyecto.

.DESCRIPTION
    Verifica que el archivo tenga contenido mínimo viable, los headers
    obligatorios y las secciones requeridas por la arquitectura V3.

    Implementa la verificación F1 del piloto T-0001: Length > 0 no es suficiente,
    porque un archivo puede quedar truncado a 18 bytes sin ser detectado por
    chequeos superficiales.

.PARAMETER Path
    Ruta al archivo PROJECT-SKILLS.md. Por defecto busca en el directorio actual.

.PARAMETER Detailed
    Muestra el detalle de cada check individual.

.EXAMPLE
    .\check-project-skills.ps1
    .\check-project-skills.ps1 -Path "C:\DEV\piloto-v3\PROJECT-SKILLS.md"
    .\check-project-skills.ps1 -Detailed

.EXITCODES
    0 - El archivo es válido.
    1 - El archivo existe pero no cumple algún check.
    2 - El archivo no existe.
    3 - Error interno del script.
#>

param(
    [string]$Path = "PROJECT-SKILLS.md",
    [switch]$Detailed
)

$ErrorActionPreference = 'Stop'

function Write-Result {
    param(
        [string]$Name,
        [bool]$Passed,
        [string]$Detail = ""
    )
    if ($Passed) {
        Write-Host ("OK    {0}" -f $Name) -ForegroundColor Green
    } else {
        Write-Host ("FALLA {0}" -f $Name) -ForegroundColor Red
        if ($Detail) {
            Write-Host ("      {0}" -f $Detail) -ForegroundColor Yellow
        }
    }
}

try {
    # ---------- Check 0: el archivo existe ----------
    if (-not (Test-Path $Path)) {
        Write-Host "FALLA archivo no existe: $Path" -ForegroundColor Red
        exit 2
    }

    $item = Get-Item $Path
    $content = Get-Content $Path -Raw -Encoding UTF8

    if (-not $content) {
        Write-Host "FALLA archivo vacío: $Path" -ForegroundColor Red
        exit 1
    }

    Write-Host ""
    Write-Host "Validando: $($item.FullName)" -ForegroundColor Cyan
    Write-Host "Tamaño: $($item.Length) bytes" -ForegroundColor Cyan
    Write-Host ""

    # ---------- Checks estructurales ----------
    $checks = @(
        @{
            Name   = "Tamaño > 500 bytes"
            Passed = $item.Length -gt 500
            Detail = "Tamaño actual: $($item.Length) bytes. Un archivo < 500 bytes probablemente está truncado."
        }
        @{
            Name   = "Contiene '# PROYECTO:'"
            Passed = $content -match '(?m)^#\s+PROYECTO:'
            Detail = "Falta el header '# PROYECTO: <nombre>' al inicio del archivo."
        }
        @{
            Name   = "Contiene 'Stack declarado:'"
            Passed = $content -match 'Stack declarado:'
            Detail = "Falta la línea 'Stack declarado: <stack>' en la sección del proyecto."
        }
        @{
            Name   = "Contiene 'Rama base:'"
            Passed = $content -match 'Rama base:'
            Detail = "Falta la línea 'Rama base: main' (o la rama correspondiente)."
        }
        @{
            Name   = "Contiene sección 'Skills activas en este proyecto'"
            Passed = $content -match '(?m)^##\s+Skills activas en este proyecto'
            Detail = "Falta la sección '## Skills activas en este proyecto'."
        }
        @{
            Name   = "Contiene sección 'Reglas locales del proyecto'"
            Passed = $content -match '(?m)^##\s+Reglas locales del proyecto'
            Detail = "Falta la sección '## Reglas locales del proyecto'."
        }
        @{
            Name   = "Contiene sección 'Contexto adicional del cliente'"
            Passed = $content -match '(?m)^##\s+Contexto adicional del cliente'
            Detail = "Falta la sección '## Contexto adicional del cliente'."
        }
        @{
            Name   = "Contiene sección 'Notas de adopción V3'"
            Passed = $content -match '(?m)^##\s+Notas de adopción V3'
            Detail = "Falta la sección '## Notas de adopción V3'."
        }
    )

    # ---------- Evaluación y salida ----------
    $failedCount = 0
    foreach ($check in $checks) {
        Write-Result -Name $check.Name -Passed $check.Passed -Detail $check.Detail
        if (-not $check.Passed) { $failedCount++ }
    }

    Write-Host ""

    if ($failedCount -eq 0) {
        Write-Host "RESULTADO: PASS — PROJECT-SKILLS.md es válido." -ForegroundColor Green
        exit 0
    } else {
        Write-Host "RESULTADO: FAIL — $failedCount check(s) fallaron." -ForegroundColor Red
        Write-Host ""
        Write-Host "Accion sugerida:" -ForegroundColor Yellow
        Write-Host "  1. Restaurar el archivo desde una copia o template." -ForegroundColor Yellow
        Write-Host "  2. Si se truncó, re-copiar el contenido completo." -ForegroundColor Yellow
        Write-Host "  3. Nunca asumir que el archivo está bien solo porque existe." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Ver standards/pre-flight-checks.md sección B.1 para más detalle." -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "FALLA error interno: $_" -ForegroundColor Red
    exit 3
}
