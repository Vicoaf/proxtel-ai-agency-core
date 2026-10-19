# Pre-flight checks

Documento de verificaciones obligatorias antes de iniciar tareas, generar
evidencia o cerrar un ciclo. Consolida las fricciones F1, F3, F5, F6 y F8 del
piloto T-0001 (`docs/lessons/pilot-day4-5.md`) en comandos ejecutables.

Regla: ninguna tarea avanza a la fase siguiente si su pre-flight falla.

Documento relacionado: `docs/architecture-v3.md` sección 2 (ciclo de 5 pasos)

---

## Fase A — Pre-flight al iniciar tarea (F5)

Antes de tocar código o generar evidencia, confirmar el contexto.

### A.1 — Verificar directorio de trabajo

    pwd

**Esperado:** el worktree correcto para la fase actual.

| Fase del ciclo | Directorio esperado |
|---|---|
| Planificación (Claude) | `C:\DEV\<proyecto>\` (worktree principal) |
| Implementación backend (Codex) | `C:\DEV\<proyecto>-T-XXXX-api\` |
| Implementación frontend (Antigravity) | `C:\DEV\<proyecto>-T-XXXX-ui\` |
| Review e integración (Claude) | `C:\DEV\<proyecto>-T-XXXX-int\` |
| QA (Playwright) | `C:\DEV\<proyecto>-T-XXXX-int\` |

**Si no coincide:** detener la tarea y cambiar de worktree. No generar evidencia
desde el directorio equivocado (fricción F5 del piloto).

### A.2 — Verificar rama activa

    git branch --show-current

**Esperado:**

| Fase | Rama esperada |
|---|---|
| Planificación | `main` o rama de trabajo |
| Implementación backend | `task/T-XXXX-api` |
| Implementación frontend | `task/T-XXXX-ui` |
| Review / integración / QA | `task/T-XXXX-int` |

**Si no coincide:** abortar. Un commit en la rama incorrecta contamina la
historia y requiere cirugía posterior.

### A.3 — Verificar árbol limpio (o cambios esperados)

    git status

**Esperado:** `working tree clean` o solo los cambios autorizados para la
tarea en curso.

**Si hay archivos modificados no esperados:** investigar antes de continuar.
Puede ser residuo de una tarea previa mal cerrada.

### A.4 — Verificar que el worktree está registrado

    git worktree list

**Esperado:** el worktree actual aparece en la lista.

**Si no aparece:** el directorio no es un worktree válido. Detener y recrear
con `git worktree add`.

---

## Fase B — Pre-flight de archivos de evidencia (F1)

Antes de escribir o leer evidencia en `.agency-local/audit/T-XXXX/`, verificar
que los archivos previos son válidos.

### B.1 — Verificar integridad estructural de `PROJECT-SKILLS.md` (F1)

El piloto reveló que `Length > 0` no es suficiente: `PROJECT-SKILLS.md` puede
quedar en 18 bytes tras un guardado fallido. Se requiere verificación
estructural completa.

**Ejecutable:** `tools/check-project-skills.ps1` (creado en D2.4).

Uso manual equivalente:

    $content = Get-Content "PROJECT-SKILLS.md" -Raw -Encoding UTF8
    $checks = @{
        "Length > 500 bytes"          = $content.Length -gt 500
        "Contiene '# PROYECTO:'"      = $content -match "# PROYECTO:"
        "Contiene 'Stack declarado:'" = $content -match "Stack declarado:"
        "Contiene 'Reglas locales'"   = $content -match "Reglas locales del proyecto"
    }
    $checks.GetEnumerator() | ForEach-Object {
        if ($_.Value) { Write-Host "OK    $($_.Key)" -ForegroundColor Green }
        else { Write-Host "FALLA $($_.Key)" -ForegroundColor Red }
    }

**Esperado:** 4 OK verdes.

**Si algún check falla:** el archivo está truncado o corrupto. Restaurar antes
de continuar. Nunca asumir que el archivo se guardó bien solo porque existe.

### B.2 — Verificar que los archivos de evidencia previos existen

Antes de un paso N del ciclo, verificar que los pasos 1 a N-1 tienen evidencia:

    $base = ".agency-local\audit\T-XXXX"
    @("01-plan.md", "03-google.md", "04-claude-review.md") | ForEach-Object {
        $path = Join-Path $base $_
        if (Test-Path $path) { Write-Host "OK    $_" -ForegroundColor Green }
        else { Write-Host "FALTA $_" -ForegroundColor Red }
    }

**Esperado:** todos los archivos previos al paso actual están presentes.

**Nota sobre `02-codex.md`:** si la tarea tiene `codex_scope: NOT_APPLICABLE`
en el plan, su ausencia es correcta. Documentarlo en `notes:` del
`06-certification.yaml`.

---

## Fase C — Pre-flight para QA con Playwright (F6)

Antes de ejecutar Playwright, verificar que el servidor responde.

### C.1 — Levantar el servidor (si no está activo)

En una terminal separada, desde el worktree de integración:

    npx serve -l 8000

**Dejar esa terminal abierta.** No cerrar durante todo el paso 5.

### C.2 — Health check del servidor (F6)

    $response = Invoke-WebRequest http://localhost:8000 -UseBasicParsing -ErrorAction SilentlyContinue
    if ($response.StatusCode -eq 200) {
        Write-Host "OK    servidor responde 200" -ForegroundColor Green
    } else {
        Write-Host "FALLA servidor no responde" -ForegroundColor Red
        Write-Host "Accion: verificar que 'npx serve -l 8000' esta corriendo" -ForegroundColor Yellow
    }

**Esperado:** `OK servidor responde 200`.

**Si falla:** NO ejecutar Playwright. El error del piloto fue
`net::ERR_CONNECTION_REFUSED` porque el servidor se cerró entre pasos.
Relanzar el servidor y repetir el health check.

### C.3 — Verificar directorio antes de Playwright

Repetir A.1 y A.2. La evidencia del piloto se generó en el worktree equivocado
(`C:\DEV\piloto-v3\` en lugar de `C:\DEV\piloto-v3-T-0001-int\`). Nunca
ejecutar Playwright sin confirmar directorio y rama.

---

## Fase D — Pre-flight de cierre (F1, F5)

Antes de escribir el `06-certification.yaml`.

### D.1 — Verificar las 5 evidencias

    $base = ".agency-local\audit\T-XXXX"
    $required = @("01-plan.md", "03-google.md", "04-claude-review.md", "05-playwright.md")
    foreach ($f in $required) {
        if (Test-Path (Join-Path $base $f)) {
            Write-Host "OK    $f" -ForegroundColor Green
        } else {
            Write-Host "FALTA $f" -ForegroundColor Red
        }
    }

**Esperado:** 4 OK verdes (más `02-codex.md` si aplica).

### D.2 — Verificar `candidate_commit` coincide

    $reviewSha = (Select-String -Path ".agency-local\audit\T-XXXX\04-claude-review.md" -Pattern "^candidate_commit:\s*(\S+)" | ForEach-Object { $_.Matches.Groups[1].Value }) -replace '"',''
    $headSha = git rev-parse HEAD
    if ($reviewSha -eq $headSha) {
        Write-Host "OK    candidate_commit coincide: $headSha" -ForegroundColor Green
    } else {
        Write-Host "FALLA candidate_commit no coincide" -ForegroundColor Red
        Write-Host "  review: $reviewSha" -ForegroundColor Yellow
        Write-Host "  HEAD:   $headSha" -ForegroundColor Yellow
        Write-Host "  Accion: repetir /review sobre el commit actual" -ForegroundColor Yellow
    }

**Esperado:** los hashes coinciden.

**Si difieren:** el código cambió después del review. Volver al paso 4.

### D.3 — Verificar que no hay cambios posteriores

    git status --porcelain

**Esperado:** vacío (working tree clean).

**Si hay cambios:** no se puede certificar. Cualquier cambio posterior invalida
las pruebas de Playwright.

---

## Pitfalls de PowerShell (F3, F8)

### P.1 — Nunca usar `-SimpleMatch -AllMatches` para contar (F3)

El piloto reveló que este comando da falsos negativos en algunas versiones:

    # MAL (puede dar 0 aunque existan coincidencias)
    (Select-String -Path index.html -Pattern "<figure" -SimpleMatch -AllMatches).Matches.Count

**Correcto:**

    # BIEN (conteo fiable)
    (Select-String -Path index.html -Pattern "<figure").Count

    # BIEN (con -AllMatches, sin -SimpleMatch)
    (Select-String -Path index.html -Pattern "<figure" -AllMatches).Matches.Count

**Regla:** si vas a contar ocurrencias, usa `.Count` sobre el resultado de
`Select-String` sin `-SimpleMatch`. Si necesitas regex, usa `-AllMatches` sin
`-SimpleMatch`.

### P.2 — Leer archivos siempre con `-Encoding UTF8` (F8)

PowerShell 7 en Windows usa code page 850/1252 por defecto para `Get-Content`.
Los archivos con acentos se ven como `estÃ¡tica` (mojibake). El archivo está
bien en disco, solo se ve mal.

    # MAL (muestra mojibake)
    Get-Content "archivo.md"

    # BIEN (respeta UTF-8)
    Get-Content "archivo.md" -Encoding UTF8

**Regla:** en cualquier comando de lectura de archivos con posible contenido
UTF-8 (markdown, JSON, HTML), añadir `-Encoding UTF8`. Es cosmético para el
usuario, pero crítico si el output se va a procesar con regex o pasar a otra
herramienta.

---

## Tabla resumen

| Fase | Checks | Fricciones cubiertas |
|---|---|---|
| A. Inicio de tarea | A.1 directorio, A.2 rama, A.3 git status, A.4 worktree | F5 |
| B. Evidencia | B.1 PROJECT-SKILLS.md, B.2 evidencias previas | F1 |
| C. QA | C.1 servidor, C.2 health check, C.3 directorio | F5, F6 |
| D. Cierre | D.1 evidencias, D.2 candidate_commit, D.3 sin cambios | F1, F5 |
| PowerShell | P.1 conteo, P.2 UTF-8 | F3, F8 |

---

## Cuándo ejecutar cada fase

| Momento | Fases a ejecutar |
|---|---|
| Al iniciar cualquier tarea | A |
| Antes de escribir 01-plan.md | A + B.1 |
| Antes de escribir 02-codex.md, 03-google.md | A + B.1 + B.2 |
| Antes de Playwright | A + C (C.1 + C.2 + C.3) |
| Antes de 06-certification.yaml | D |
| Al commitear cualquier cosa | A.3 (git status) |

---

## Relación con otros documentos

- `docs/lessons/pilot-day4-5.md` — las 8 fricciones originales del piloto
- `standards/qa-handoff.md` — convención `.agency-local/audit/` y estructura de reportes
- `standards/concurrency.md` — worktrees y ramas
- `standards/permissions.md` — niveles A/B
- `docs/architecture-v3.md` sección 2 — ciclo de 5 pasos

Este documento es la traducción operativa de las fricciones. Se actualiza
cuando el piloto de una nueva tarea revela un pitfall nuevo.
