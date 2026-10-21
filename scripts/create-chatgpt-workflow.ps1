# scripts/create-chatgpt-workflow.ps1
# Genera standards/project-workflow-chatgpt.md desde el template embebido.
# Uso: .\scripts\create-chatgpt-workflow.ps1
# Requiere ejecutarse desde la raíz del Core (C:\DEV\PROXTEL-AI-AGENCY).

cd $PSScriptRoot\..
$workflowContent = Get-Content -LiteralPath ".\templates\project-workflow-chatgpt.md" -Raw -Encoding UTF8
Set-Content -LiteralPath "standards\project-workflow-chatgpt.md" -Value $workflowContent -Encoding UTF8
Write-Host "Creado: standards\project-workflow-chatgpt.md ($((Get-Item 'standards\project-workflow-chatgpt.md').Length) bytes)"
