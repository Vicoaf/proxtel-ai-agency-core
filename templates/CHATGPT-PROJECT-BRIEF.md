cd C:\DEV\PROXTEL-AI-AGENCY

$briefContent = @'
# ChatGPT Project Brief — Template

Llenar y pegar en ChatGPT al iniciar cada proyecto nuevo.

---

═══════════════════════════════════════════════════════════════
BRIEF DE PROYECTO NUEVO — [NOMBRE DEL PROYECTO]
═══════════════════════════════════════════════════════════════

FECHA: [YYYY-MM-DD]
CLIENTE: [nombre o "interno"]
TIPO: [landing | web corporativa | CRM | trading | PBX | SaaS | otro]
PRESUPUESTO ESTIMADO: [USD / MXN / "por definir"]
PLAZO DESEADO: [fecha]

═══════════════════════════════════════════════════════════════
NECESIDAD DEL CLIENTE
═══════════════════════════════════════════════════════════════

[3-5 lineas describiendo que necesita el cliente. No como hacerlo — solo que problema resolver.]

═══════════════════════════════════════════════════════════════
CONTEXTO TECNICO
═══════════════════════════════════════════════════════════════

Stack existente del cliente (si lo hay): [nada | Laravel | Node | WordPress | ...]
Base de datos actual: [nada | MySQL | Postgres | ...]
Integraciones requeridas: [ninguna | Stripe | Google Ads | PBX | ...]

═══════════════════════════════════════════════════════════════
LO QUE NECESITO DE TI (ChatGPT)
═══════════════════════════════════════════════════════════════

Disena la arquitectura del proyecto considerando:

1. Alcance funcional (que incluye, que NO incluye)
2. Stack recomendado (basado en los adapters certificados que tengo)
3. Modelo de datos conceptual (tablas/entidades principales)
4. Estructura de PROJECT-SKILLS.md (que skills de mi catalogo activar)
5. Criterios de aceptacion tecnicos
6. Estimacion de tiempo por fase del ciclo V3
7. Riesgos identificados

Recuerda:
- Solo tengo 3 adapters certificados (Claude, Codex, Antigravity)
- Solo tengo 10 skills registradas (2 core + 3 development + 5 crm)
- El ciclo V3 tiene 6 pasos (2 automatizados, 4 asistidos)
- Tu no ejecutas, solo disenas

Entregame un documento de arquitectura listo para pegar en el repo del proyecto.
'@

Set-Content -LiteralPath "templates\CHATGPT-PROJECT-BRIEF.md" -Value $briefContent -Encoding UTF8
Write-Host "Creado: templates\CHATGPT-PROJECT-BRIEF.md ($((Get-Item 'templates\CHATGPT-PROJECT-BRIEF.md').Length) bytes)"
