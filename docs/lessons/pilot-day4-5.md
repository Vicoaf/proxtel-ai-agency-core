# Lecciones del piloto T-0001 — Día 4+5

Documentación de fricciones reales encontradas al ejecutar el ciclo operativo
V3 completo (5 pasos) sobre el proyecto piloto descartable `piloto-v3`.

Fecha: 19 de octubre de 2026
Autor: Vic + Claude Code
Estado del piloto: CERTIFIED — READY_FOR_MERGE_AUTHORIZATION
Ubicación del piloto: C:\DEV\piloto-v3-T-0001-int
Rama: task/T-0001-int
Commit del merge: a41a2e7af2644455ef211b9c068ac014987258f2

---

## Resumen ejecutivo

El ciclo V3 completo se ejecutó end-to-end en modo asistido (no automatizado).
Los 5 gates funcionaron: plan, implementación, review, QA y aceptación humana.
El `06-certification.yaml` se produjo con todas las evidencias verificadas.

Modo de ejecución: **asistido** (Vic lanzó cada CLI manualmente). Esto fue
necesario porque el adapter de Claude está en estado `candidate / not-executed`,
lo que impide la ejecución programática automatizada del ciclo completo.

---

## Fricciones reales encontradas

### F1 — PROJECT-SKILLS.md se sobrescribió a 18 bytes

**Síntoma:** Después de crear `PROJECT-SKILLS.md` con 60+ líneas en el sub-paso A,
al inicio del sub-paso B Claude lo leyó con 18 bytes / 1 línea. No hubo
modificación manual entre ambos pasos.

**Causa probable:** Contenido previo en el archivo o escritura parcial que quedó
del paso A (el `Ctrl+A` + `Supr` + pegar + guardar no completó la sincronización
del archivo en disco).

**Mitigación aplicada:** Se restauró el contenido completo (81 líneas, 2223 bytes)
en el sub-paso B. Commit `7355b22`.

**Acción recomendada para la agencia:** Añadir verificación de `Length > 0` en
los scripts de creación de `PROJECT-SKILLS.md`. Nunca asumir que el archivo se
guardó correctamente sin verificar bytes.

---

### F2 — Claude Code stdout corrupto en Windows

**Síntoma:** Al pedirle a Claude que produjera el `01-plan.md` por stdout, el
output se renderizó en la terminal con saltos de línea corruptos y texto
entrecortado. Copiar de la terminal produjo archivos inválidos.

**Causa:** Bug conocido de Claude Code en Windows al renderizar output largo
con líneas largas.

**Mitigación aplicada:** Se le pidió a Claude que escribiera el archivo
directamente con su herramienta `Write` en lugar de devolverlo por stdout.
Funcionó perfectamente.

**Acción recomendada para la agencia:** Añadir al `AGENTS.md` una regla:
"En Windows, Claude Code escribe archivos con Write, nunca devuelve contenido
largo por stdout." Ya está parcialmente cubierto por la convención de
`.agency-local/audit/`, pero conviene explicitarlo.

---

### F3 — PowerShell `-SimpleMatch -AllMatches` produce falsos negativos

**Síntoma:** El comando
`(Select-String -Path index.html -Pattern "<figure" -SimpleMatch -AllMatches).Matches.Count`
devolvió `0` aunque el archivo tenía 2 `<figure>`. Un comando posterior sin
`-SimpleMatch -AllMatches` devolvió `2` correctamente.

**Causa:** Comportamiento específico de PowerShell en algunas versiones al
combinar los flags `-SimpleMatch` y `-AllMatches` con `.Matches.Count`.

**Mitigación aplicada:** Se usaron verificaciones alternativas con `-Pattern`
sin flags (`(Select-String -Path index.html -Pattern "<figure class=").Count`)
que devolvieron los valores correctos.

**Acción recomendada para la agencia:** Documentar en `docs/lessons/` que los
scripts de verificación de la agencia deben evitar `-SimpleMatch -AllMatches`
en PowerShell. Preferir `(Select-String -Path X -Pattern Y).Count` o
`Select-String -Path X -Pattern Y -AllMatches | Measure-Object`.

---

### F4 — Playwright no accesible vía require()

**Síntoma:** `node .agency-local\audit\T-0001\capture.js` falló con
`Cannot find module 'playwright'` aunque `npx playwright --version` respondía
`1.64.1`.

**Causa:** Playwright estaba solo en la caché de npx (`%LOCALAPPDATA%\npm-cache\_npx`),
no en `node_modules` del proyecto ni en global. `require()` no resuelve desde
la caché de npx.

**Mitigación aplicada:** Se instaló Playwright en un directorio separado
`C:\DEV\_piloto-tools\` y se ejecutó con `NODE_PATH` apuntando a
`C:\DEV\_piloto-tools\node_modules`. Funcionó sin contaminar el piloto vanilla.

**Acción recomendada para la agencia:** Añadir `C:\DEV\_piloto-tools\` como
directorio oficial de herramientas de agencia. Documentar el patrón:
"Herramientas de agencia (Playwright, scripts auxiliares) viven en `_piloto-tools/`,
no en los proyectos. Los proyectos son vanilla, las herramientas no."

---

### F5 — Screenshots capturados en el worktree incorrecto

**Síntoma:** Los 3 screenshots (`home-1440.png`, `home-768.png`, `home-390.png`)
y `dom-home.html` se generaron en `C:\DEV\piloto-v3\.agency-local\` (worktree
principal) en lugar de `C:\DEV\piloto-v3-T-0001-int\.agency-local\` (worktree
de integración).

**Causa:** El `pwd` de la terminal cambió entre pasos y el comando de Playwright
se ejecutó desde el worktree principal sin verificar.

**Mitigación aplicada:** Se movieron manualmente los 4 archivos al worktree
correcto con `Copy-Item`.

**Acción recomendada para la agencia:** Todo comando que produzca evidencia
de auditoría debe empezar con `pwd` y `git branch --show-current`. Si la rama
no es la esperada, detener y no ejecutar. Añadir a `standards/qa-handoff.md`:
"Toda evidencia se genera desde el worktree de integración (`task/T-XXXX-int`),
nunca desde el principal."

---

### F6 — Servidor npx serve no activo al ejecutar capture.js

**Síntoma:** `node capture.js` falló con `net::ERR_CONNECTION_REFUSED` en
`http://localhost:8000/` porque el servidor `npx serve -l 8000` se había cerrado
entre pasos.

**Causa:** El servidor se lanzó en una terminal anterior y esa terminal se cerró
(o el proceso terminó) antes de ejecutar `capture.js`.

**Mitigación aplicada:** Se reabrió el servidor en una terminal nueva y se
verificó con `Invoke-WebRequest http://localhost:8000 -UseBasicParsing | Select-Object StatusCode`
antes de ejecutar `capture.js`.

**Acción recomendada para la agencia:** El paso 5 del ciclo debe empezar siempre
con `Invoke-WebRequest ... | Select-Object StatusCode`. Si no es `200`, detener
y relanzar el servidor. Nunca ejecutar Playwright sin verificar que el servidor
responde.

---

### F7 — Adapter de Claude en estado candidate

**Síntoma:** No fue posible automatizar el ciclo completo. Cada CLI se lanzó
manualmente por Vic.

**Causa:** El adapter de Claude está en estado `candidate / not-executed`
(`adapters/claude/adapter.json`). Los adapters de Codex y Antigravity están
certificados (Área 1.2), pero el de Claude no.

**Mitigación aplicada:** Se aceptó el modo asistido para el piloto. El
`06-certification.yaml` lo documenta explícitamente en `notes:`.

**Acción recomendada para la agencia:** Certificar el adapter de Claude en
semana 2. Esto requiere:
1. Crear harness de test (ej. `tests/integration/provider-adapters/claude/`)
2. Ejecutar smoke tests del adapter en modo no-interactivo
3. Producir un certificado formal (`area-X.X-claude-adapter-certification.json`)
4. Actualizar `adapters/claude/adapter.json` de `candidate` a `approved`

Estimación: 4-6 horas de trabajo técnico.

---

### F8 — Encoding UTF-8 mal mostrado en PowerShell

**Síntoma:** `estática` aparece como `estÃ¡tica` en la salida de `Get-Content`.
Los archivos en disco están correctos en UTF-8.

**Causa:** PowerShell 7 en Windows usa code page 850/1252 por defecto para
`Get-Content` en lugar de UTF-8.

**Mitigación aplicada:** Ninguna necesaria. Es cosmético. Los archivos están
bien y las CLIs los leen correctamente.

**Acción recomendada para la agencia:** Documentar el uso de
`Get-Content -Encoding UTF8` cuando se necesita ver el contenido correctamente.
No es un problema real, solo molesta al debuggear.

---

## Lo que funcionó bien (para preservar)

1. **El ciclo de 5 pasos es coherente.** Plan → implementación → review → QA →
   aceptación humana produce evidencia verificable y el `06-certification.yaml`
   refleja la realidad.

2. **La separación de responsabilidades funciona.** Claude no implementó,
   Antigravity no revisó su propio trabajo, Vic aprobó visualmente.
   Los gates se respetaron.

3. **La convención `.agency-local/audit/T-XXXX/` es sólida.** Los 6 archivos
   se generaron en el lugar correcto con la estructura correcta.

4. **El `01-plan.md` es un contrato ejecutable.** Antigravity lo siguió al pie
   de la letra. Cero archivos fuera de alcance.

5. **El `/review` de Claude detectó que la implementación era correcta** y
   produjo un reporte de 5358 bytes con los 7 hallazgos en PASS. No fue un
   "resumen bonito", fue una revisión real.

6. **Vic como gate humano visual es indispensable.** La decisión `VISUAL_PASS`
   no puede delegarse a un LLM que implementó el código.

---

## Métricas del piloto

| Métrica | Valor |
|---|---|
| Duración del ciclo completo (asistido) | ~4 horas |
| Comandos ejecutados por Vic | ~45 |
| Errores de consola de la landing | 0 |
| Requests fallidos | 0 |
| Archivos fuera de alcance | 0 |
| Dependencias externas | 0 |
| Fricciones encontradas | 8 |
| Fricciones bloqueantes | 0 |
| Estado final | READY_FOR_MERGE_AUTHORIZATION |

---

## Siguientes pasos (semana 2)

1. **Certificar el adapter de Claude** (F7). Sin esto, el ciclo no es automatizable.
2. **Añadir verificaciones pre-vuelo** en los scripts de agencia (F1, F5, F6).
3. **Documentar el patrón `_piloto-tools/`** en `README.md` del Core (F4).
4. **Migrar `i-Tkt` y `TRDStation`** al ciclo V3 (solo después de certificar
   el adapter).
5. **Ejecutar el Bloque C de ChatGPT** para producir el plan de certificación
   y la hoja de ruta semana 2.

---

**Fin del documento.**

---

## Fricciones del D4 (orchestrator)

### F10 - `git diff main..HEAD` invalido post-merge

**Sintoma:** el orchestrator paso 4 leyo 1848 chars de diff cuando deberia leer ~7000-9000. Claude reporto `REVIEW_FAIL` con los 7 hallazgos en FAIL porque el diff no contenia el codigo real.

**Causa:** despues del merge del piloto a `main` (Dia 7), `main` avanzo a un commit descendiente de `HEAD`. `git merge-base main HEAD` = `HEAD`, entonces `git diff main..HEAD` = vacio. El script leyo un diff sin el codigo bajo revision.

**Mitigacion aplicada:** anadido parametro `-BaseRef <SHA>` al script. Vic pasa el SHA base explicito (ej. `7355b22`) cuando `main` ya avanzo. Si `-BaseRef` no se provee, el script cae a `merge-base` (que falla silenciosamente en este caso).

**Accion futura:** el `01-plan.md` debe capturar `base_commit: <SHA>` inmutable en el momento de planificacion. El orchestrator lee ese campo en lugar de inferirlo de `main`.

---

### F11 - `New-Item -Force` crea el WorkingDir antes del check

**Sintoma:** `run-certification-step.ps1` con `-WorkingDir C:\DEV\_test-nonexistent` no fallaba en el check de WorkingDir. Fallaba despues en `git status` con "not a git repository".

**Causa:** `New-Item -ItemType Directory -Force -Path $LogDir` crea toda la cadena de directorios, incluyendo `$WorkingDir` si no existe. Cuando el check `Test-Path $WorkingDir` corre, ya existe (recien creado), y el check pasa. Despues `git status` falla porque el directorio recien creado no tiene `.git`.

**Mitigacion aplicada:** el check de `Test-Path $WorkingDir` va ANTES de cualquier `New-Item`. Se crea `$LogDir` solo despues de validar el `WorkingDir`.

**Regla:** nunca `New-Item -Force` antes de validar el directorio padre.

---

### F12 - Anomalia temporal detectada por Claude (nueva capability)

**Sintoma:** el certification automatizado detecto que `05-playwright.md` (2026-10-19) es anterior al `04-claude-review.md` (2026-10-20T22:07:42Z). En el ciclo V3 el orden es review -> QA. Aqui el QA precedio al review.

**Causa:** artefacto del D4. El piloto se hizo completo el Dia 4-5 (asistido). En el D4 re-ejecutamos SOLO review + certification con el orchestrator. El `05-playwright.md` sigue siendo el del Dia 4-5.

**Impacto:** cero. `candidate_commit` es identico en ambas evidencias. El codigo auditado por Playwright es el mismo que el revisado por Claude. No hubo cambios en `index.html`, `styles.css`, `script.js` entre fechas.

**Mitigacion aplicada:** Vic confirmo la anomalia en `CONFIRMACION-ANOMALIA-TEMPORAL.md`. Documentada en el `06-certification.yaml` (nota 5).

**Accion futura:** el orchestrator debe validar el orden temporal de las evidencias:
- `05-playwright.md` fecha >= `04-claude-review.md` fecha
- Si la fecha de QA es anterior al review: `BLOCKED` en lugar de `READY_FOR_MERGE_AUTHORIZATION`

**Hallazgo meta:** el orchestrator automatizado detecto una inconsistencia que el ciclo asistido original no vio. Esto valida que los orchestrators con validacion estricta son superiores al modo asistido para deteccion de anomalias.

---

### F13 (menor) - Mojibake UTF-8 en Windows

**Sintoma:** `git diff | Out-String` en PowerShell pierde UTF-8. Los acentos se ven como `est├ítica` en lugar de `estática`.

**Causa:** PowerShell en Windows usa code page 850/1252 por defecto para pipes, no UTF-8. `Get-Content -Raw -Encoding UTF8` funciona, pero `git diff | Out-String` no.

**Impacto:** cosmetico. Los archivos en disco estan bien. Claude lee el mojibake en el prompt pero puede inferir el contenido.

**Accion futura:** anadir `[Console]::OutputEncoding = [System.Text.Encoding]::UTF8` al inicio del orchestrator. O usar `git -c core.quotepath=false diff` con `chcp 65001`.

---

## Resultado del D4

- 2 de 5 pasos del ciclo V3 automatizados (`review` + `certification`)
- 3 bugs reales detectados y corregidos (F10, F11, F12)
- 1 anomalia detectada por Claude que el asistido no vio (F12)
- Coste total: ~$0.08 de cuota Claude
- Duracion total automatizada: 17.66s + 10.61s = 28.27s (vs ~15 min del ciclo asistido original)

---

## Fricciones del D6 (mejoras de calidad)

### F14 - `.Replace()` falla silenciosamente en Windows por CRLF vs LF

**Sintoma:** el patch a `run-certification-step.ps1` con `.Replace($oldParam, $newParam)` retorno `0` reemplazos. El script sintacticamente OK pero sin los cambios aplicados.

**Causa:** el archivo tiene line endings LF (Unix), pero los here-strings en PowerShell usan CRLF (Windows). El match literal `\r\n` en el archivo contra `\n` en el script falla silenciosamente. `$content.Replace()` retorna el string original sin cambios.

**Mitigacion aplicada:** operar sobre `Get-Content` como **array de lineas** en lugar de string multi-linea. Los arrays preservan los line endings por linea, y el match funciona linea por linea. Despues `Set-Content -Value $lines` escribe correctamente.

**Regla:** cualquier patch a un archivo de texto en Windows que use `.Replace()` con strings multi-linea debe:
1. Leer como array: `$lines = Get-Content -Path $file -Encoding UTF8`
2. Buscar el indice de la linea que coincide con regex: `for ($i=0; $i -lt $lines.Count; $i++) { if ($lines[$i] -match '...') { ... } }`
3. Insertar/modificar en el array
4. Escribir con `Set-Content -Value $lines -Encoding UTF8`

Alternativa: normalizar antes `$content = $content -replace "`r`n", "`n"`. Pero el array es mas robusto.

**Impacto:** ~10 minutos perdidos en D6.3 y un rollback (`git checkout --`) que descarto el primer intento.

**Hallazgo meta:** los patches con `.Replace()` son frágiles. El patron array-linea es el estandar para automatizacion en PowerShell.

---

## Resultado del D6

- F13 aplicado: `[Console]::OutputEncoding = UTF8` en ambos scripts (fix de mojibake)
- D6.2 aplicado: `quota-log.md` alineado con politica R (elimina inconsistencia 70% semanal)
- F12 aplicado: validacion temporal en `run-certification-step.ps1` (`-AllowTemporalAnomaly` para excepciones)
- F14 documentada: `.Replace()` falla con CRLF vs LF en Windows
- 4 commits: F13 (2 scripts), quota-log, F12 (1 script), lessons+STATUS

**Estado de la agencia: operativa al 85%.**

---

## Fricciones del D7.1 (Antigravity)

### F16 - Google auto-update silencioso de `agy`

**Sintoma:** entre D7.1.2 (verificacion PASS con 1.4.2) y D7.1.3 (promocion), el binario `agy.exe` cambio de 1.4.2 a 1.4.3 sin intervencion explicita. Hash `4F6C7A80...` -> `B9EBBC8A...`. El proceso agy interactivo (PID 31224, iniciado 10:44 a.m.) seguia activo en la sesion, pero el disco ya tenia la version nueva.

**Causa:** Google AI Pro auto-actualiza el binario `agy.exe` silenciosamente. Probablemente el proceso interactivo descarga la nueva version en background y la escribe en disco cuando detecta "inactividad" o al terminar una sesion.

**Evidencia:**
- `agy.exe LastWriteTime`: 20/10/2026 4:30:45 p.m. (justo antes de la promocion)
- `agy.exe CreationTime`: 28/05/2026 (instalacion original)
- `agy --version` D7.1.2: `1.4.2`; D7.1.3: `1.4.3`
- Hash cambio entre las 2 consultas

**Mitigacion aplicada:**
1. Matar proceso `agy` interactivo (`Stop-Process -Force`)
2. Verificar estabilidad de hash por 2 minutos (3 mediciones separadas 60s)
3. Re-verificar con el binario actual (7/7 PASS)
4. Promover con el hash verificado

**Accion para futuras promociones de Antigravity:**
- Antes de cada verificacion: `Get-Process agy | Stop-Process -Force` (matar sesiones interactivas)
- Verificar estabilidad de hash por >=2 min (evitar updates sorpresa)
- Verificar el hash INMEDIATAMENTE antes de escribir el adapter (no confiar en hash de hace 10 min)

**Hallazgo meta:** cualquier CLI que auto-actualice requiere guardas de estabilidad. Claude Code (npm) y Codex (npm) requieren `npm install -g` explicito, lo cual es mas controlable. Antigravity (Google) no.

---

### F17 - `if` y `else` en lineas separadas fallan en PowerShell

**Sintoma:** 
    if ($x -eq 0) { Write-Host "ok" }
    else { Write-Host "fail" }

Error: "else: El termino 'else' no se reconoce como nombre de un cmdlet".

**Causa:** PowerShell parsea cada statement separadamente si estan en lineas distintas. El `if` cierra como statement completo en la primera linea. El `else` en la siguiente linea es un statement nuevo, no vinculado.

**Mitigacion:** `if` y `else` deben estar en el mismo statement:

    if ($x -eq 0) { Write-Host "ok" } else { Write-Host "fail" }

O con llaves multilinea bien anidadas (con el `else` pegado al `}` del `if`):

    if ($x -eq 0) {
        Write-Host "ok"
    } else {
        Write-Host "fail"
    }

**Impacto:** cosmetico. El `if` si se ejecuta; solo el `else` falla. En D7.1.3 el `if` imprimio "5/5 cambios verificados" correctamente, el `else` fallo (sin consecuencias).

**Regla:** nunca poner `else` en linea nueva separado del `}` del `if`. Siempre pegarlos (mismo statement).

---

## Resultado del D7.1

- Antigravity promovido a `approved / live-tested`
- Verificacion triple documentada (1.2.6 / 1.4.2 / 1.4.3)
- 2 fricciones nuevas (F16 auto-update, F17 if/else)
- Politica nueva en adapter-promotion.md: verificar hash INMEDIATAMENTE antes de promover
- Coste total: ~$0.06 (2 verificaciones)
- Duracion: ~1.5h (incluye rollback y re-verificacion)

**Estado: agencia al 92%.**

---

## Fricciones del D7.2 (Codex)

### F18 - Benchmark demasiado estricto + contaminacion semantica del prompt

**Sintoma:** el intento C9-fix2 del adapter Codex fallo con `FAIL_BEHAVIOR`. El error reportado: `primary_action expected=AUDIT actual=REQUEST-EVIDENCE` y `decision not allowed: ADAPT`.

**Causa raiz (confirmada por root-cause-analysis.json del intento original):**

1. **benchmark_expectation_too_strict:** el test esperaba que el modelo respondiera `AUDIT/PENDING`, pero el prompt embebia una Skill con metodologia que define 4 decisiones finales (APPROVED, ADAPT, REFERENCE-ONLY, REJECTED). El modelo respondio `REQUEST-EVIDENCE/ADAPT` — una respuesta **defendible** segun los materiales.

2. **prompt_semantic_contamination:** el prompt de C9-fix2 tenia **16568 bytes** porque embebia el `PROXTEL Skill Auditor` completo + contrato + metodologia + caso. Esto convirtio un smoke test de transporte en un test de comportamiento complejo.

**Comparacion con otros adapters:**
- Claude C18: prompt de 570 bytes. PASS.
- Antigravity C31: prompt de 639 bytes. PASS.
- Codex C9-fix2: prompt de 16568 bytes (29x mas grande). FAIL_BEHAVIOR.

**Mitigacion aplicada en C32:**

1. **Smoke de transporte puro:** prompt de 549 bytes, mismo formato que Claude y Antigravity. Sin embeber Skill, metodologia ni candidato.
2. **Schema con enum fijos:** los 7 campos tienen valores exactos forzados (`result=PASS`, `nonce=...`). No hay decision que tomar.
3. **Resultado:** 7/7 PASS en 8.37s.

**Leccion:** los smoke tests deben validar **transporte**, no comportamiento. El comportamiento se testea en packets separados (C33+), fuera del scope de certificacion de adapter.

**Regla para futuros smokes:**
- Prompt < 1000 bytes.
- Schema con enums fijos (no decisiones).
- Sin embebido de Skills, metodologias, casos complejos.
- Si el adapter necesita validar comportamiento: crear packet de "behavioral" separado con su propio root-cause-analysis.

---

## Resultado del D7 completo

- 3 adapters promovidos a approved (Claude + Antigravity + Codex)
- 2 bugs de configuracion detectados: F16 (Google auto-update), F17 (if/else PowerShell)
- 1 error de diseno de benchmark analizado: F18 (C9-fix2 vs C32)
- 5 tags nuevos en GitHub: antigravity-adapter-approved-v1, v3-antigravity-approved, codex-adapter-approved-v1, v3-fully-certified (proximo)
- Coste total del D7: ~$0.15 (2 verificaciones + 1 smoke)
- Duracion total: ~4h (D7.1 + D7.2)

**Estado: agencia al 100%. Los 3 adapters operativos.**
