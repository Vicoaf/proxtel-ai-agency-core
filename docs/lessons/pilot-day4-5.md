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
