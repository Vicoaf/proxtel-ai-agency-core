# PROXTEL AI Agency — STATUS del Core V3

Documento de estado consolidado. Se actualiza al cierre de cada hito.
Última actualización: 2026-10-19
Estado del Core: OPERATIVO (piloto certificado)

---

## Estado general

| Dimensión | Estado | Nota |
|---|---|---|
| Política V3 (CAPA 4) | COMPLETA | AGENTS.md + 5 standards + tools/quota-log.md |
| Orquestación V2 (CAPA 3) | CERTIFICADA | Orchestrator + 6 subagentes + 3 adapters (Claude en candidate) |
| Skills V2 (CAPA 2) | CERTIFICADAS | 7 skills: 5 approved + 2 baseline |
| Ciclo operativo de 5 pasos | PROBADO EN PILOTO | T-0001 ejecutado en modo asistido |
| Adapter de Claude | CANDIDATE | Bloquea automatización end-to-end |
| Certificación del ciclo V3 | PARCIAL | Asistido certificado, programático pendiente |
| Merge a main del Core | PENDIENTE | core-v2 → main en sub-paso 4 del Día 7 |

---

## Hitos completados

### Día 1-2 — Base de política y dual-machine
- `docs/architecture-v3.md` (700+ líneas, con correcciones H1.3 a H4.9)
- 10 archivos de configuración: `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `standards/*.md`, `tools/quota-log.md`, `skills/registry.md`, `.gitignore`
- Bootstrap dual PC ↔ Mac: `bootstrap/windows-setup.ps1`, `bootstrap/mac-setup.sh`
- `.gitattributes` con reglas EOL para `.sh/.bash/.zsh` (sin tocar las 345 rutas byte-exact)

### Día 3 — Reconciliación V2 ↔ V3
- `README.md` reconciliado con estado real V1+V2+V3
- `AGENTS.md` con orden de autoridad de 4 niveles
- `skills/registry.md` con las 7 skills V2 mapeadas
- `templates/PROJECT-SKILLS.md` para nuevos proyectos
- 25 hallazgos del Bloque B resueltos y commiteados

### Día 4-5 — Piloto T-0001 (certificado)
- Proyecto `piloto-v3` (landing HTML/CSS/JS vanilla descartable)
- Ciclo V3 completo ejecutado en modo asistido
- 5 gates: plan → frontend → review → QA → aceptación Vic
- `06-certification.yaml` con `READY_FOR_MERGE_AUTHORIZATION`
- 8 fricciones documentadas en `docs/lessons/pilot-day4-5.md`
- 0 errores, 0 requests fallidos, 0 archivos fuera de alcance

### Día 6 — Plan de certificación y hoja de ruta
- `docs/certification-plan.md` (381 líneas, Bloque C de ChatGPT)
- 10 controles de certificación C01-C10
- Plan de semana 2: D1-D5 con Fases A-E
- 8 fricciones con severidad y acción de cierre

### Día 7 — Cierre del Core (en curso)
- ✅ Sub-paso 1: merge `task/T-0001-int` → `main` del piloto (commit `44066bb`, tag `t-0001-certified`)
- 🔜 Sub-paso 2: STATUS.md (este documento)
- 🔜 Sub-paso 3: README.md con gaps pendientes
- 🔜 Sub-paso 4: merge `core-v2` → `main` del Core
- 🔜 Sub-paso 5: acta de cierre y tag `v3-piloto-certificado`


### Semana 2 — D1: Verificación documental del piloto (completado)

- ✅ Integridad del piloto T-0001 verificada (6 evidencias + artefactos QA)
- ✅ Consistencia del `candidate_commit` en 3 archivos (`04-claude-review.md`, `06-certification.yaml`, `git rev-parse HEAD`): los 3 coinciden en `a41a2e7`
- ✅ 7 hallazgos de Claude en PASS
- ✅ 7 criterios de Vic en PASS
- ✅ 5 pruebas técnicas de Antigravity en PASS
- ✅ Referencias internas del certificado verificadas (`#revision-visual-vic`, `#aceptacion-vic`)
- ✅ Sin evidencia huérfana ni referencias rotas
- ✅ Backup del piloto en `C:\DEV\_backups\piloto-t-0001-2026-10-19.zip` (opción C)
- Veredicto: **el piloto T-0001 está formalmente verificado y conciliado**

### Semana 2 — D2: Correcciones de fricciones F1-F6 + documentación F8 (completado)

- ✅ `standards/pre-flight-checks.md` (278 líneas): consolida F1, F3, F5, F6, F8 en 4 fases ejecutables (A, B, C, D) + 2 pitfalls de PowerShell
- ✅ `AGENTS.md` +2 reglas duras: F2 (Write en Windows) y F3 (pitfall PowerShell)
- ✅ `README.md` + `standards/concurrency.md`: formalizado `_piloto-tools/` como directorio externo de QA (F4)
- ✅ `tools/check-project-skills.ps1` (144 líneas): valida integridad estructural de `PROJECT-SKILLS.md`. Probado con PASS (2223 bytes) y FAIL (18 bytes, simula el bug del piloto)
- ✅ `templates/START-TASK.md` (209 líneas): checklist de inicio de tarea que referencia todas las herramientas nuevas
- Veredicto: **las 8 fricciones del piloto T-0001 tienen mitigación documentada y herramienta ejecutable**

Commit del D2: `<SHA del commit del START-TASK>`

---

## Lo que está operativo ahora

### Comandos que funcionan
- `cd C:\DEV\PROXTEL-AI-AGENCY` → trabajar en el Core
- `cd C:\DEV\piloto-v3` → revisar el piloto certificado
- `git tag -l` → ver hitos (`t-0001-certified`)
- `Get-Content docs\STATUS.md` → releer este estado
- `claude` / `codex` / `agy` → lanzar cada CLI (modo asistido)
- `Get-Content docs\certification-plan.md` → plan semana 2

### Flujos certificados
- **Ciclo V3 asistido:** probado end-to-end en `piloto-v3`. Ejecutable en cualquier proyecto nuevo copiando `templates/PROJECT-SKILLS.md` y siguiendo el ciclo de 5 pasos manualmente.
- **Worktree aislado:** probado con `task/T-0001-ui` y `task/T-0001-int`. Patrón replicable.
- **Convención `.agency-local/audit/T-XXXX/`:** probada con 6 archivos de evidencia + screenshots + dom + logs.

### Flujos NO certificados
- **Ciclo V3 automatizado:** bloqueado por `adapters/claude/adapter.json` en `candidate / not-executed`.
- **Ejecución no-interactiva de Claude:** pendiente de certificar en semana 2, D3.
- **Migración de i-Tkt o TRDStation:** condicionada a certificar el adapter.

---

## Pendientes críticos (semana 2)

Del `docs/certification-plan.md`, sección 6 (Plan operativo):

| Día | Actividad | Bloqueante |
|---|---|---|
| D1 | Verificación del piloto y conciliación del merge | No (parcialmente hecho en Día 7) |
| D2 | Corrección de fricciones F1-F6, documentación F8 | No |
| D3 | Harness y smoke tests del adapter Claude | **SÍ** (bloquea automatización) |
| D4 | Regresión integral V3 con ruta aprobada | **SÍ** (depende de D3) |
| D5 | Go/No-Go e incorporación progresiva de proyectos | **SÍ** (depende de D4) |

Si D3 falla, la agencia continúa operando en modo asistido. No se degrada, no se bloquea.

---

## Gaps conocidos (documentados, no bloqueantes)

### Gap 1 — Los 9 departamentos originales no están implementados
La visión original mencionaba CORE, DEVELOPMENT, DOCUMENTATION, CRM, SALES,
CUSTOMER SERVICE, FINANCE, MARKETING y PBX. Solo CORE y DEVELOPMENT están
parcialmente operativos. Los demás se posponen a semana 3+ según necesidad
real de proyectos.

### Gap 2 — Skills baseline sin plan de promoción
`creador-skills` e `inicializador-proyectos` están en estado `baseline-existing`.
No se activan en proyectos sin autorización expresa de Vic. La regla de 3 usos
en 2 proyectos sigue vigente pero no se ha ejercitado aún.

Ambos gaps se resolverán cuando aparezcan proyectos reales que los justifiquen.
No son deuda técnica, son decisiones de alcance.

---

## Métricas del piloto T-0001

| Métrica | Valor |
|---|---|
| Duración del ciclo asistido | ~4 horas |
| Comandos manuales por Vic | ~45 |
| Gates del ciclo | 5/5 PASS |
| Errores de consola | 0 |
| Requests fallidos | 0 |
| Archivos fuera de alcance | 0 |
| Dependencias externas | 0 |
| Fricciones encontradas | 8 |
| Fricciones bloqueantes | 0 |
| Estado final | READY_FOR_MERGE_AUTHORIZATION → MERGED |

---

## Referencias

- `docs/architecture-v3.md` — arquitectura aprobada de las 3 generaciones
- `docs/certification-plan.md` — plan de certificación semana 2
- `docs/lessons/pilot-day4-5.md` — 8 fricciones documentadas
- `README.md` — overview del sistema completo
- `AGENTS.md` — reglas maestras para agentes
- `skills/registry.md` — catálogo documental de skills
- `skills/_registry/skills-registry.json` — estado máquina-legible V2
- `standards/permissions.md` — niveles A/B
- `standards/qa-handoff.md` — convención `.agency-local/audit/`
- `standards/concurrency.md` — worktrees y ramas
- `standards/dual-machine.md` — sync PC ↔ Mac
- `standards/chatgpt-brief.md` — protocolo con ChatGPT
- `C:\DEV\piloto-v3\` — piloto certificado (tag `t-0001-certified`)

---

## Próxima sesión

Al retomar, leer este documento primero. Si el estado no coincide con lo que
dice este STATUS, actualizar este archivo antes de trabajar en cualquier otra
cosa.

Si no hay proyectos nuevos activos: comenzar por la Fase B del plan de
certificación (D2 de la semana 2, correcciones F1-F6). No hace falta esperar
nada para empezar.

**Fin del documento.**

### Semana 2 - D4: Orchestrator + ciclo parcialmente automatizado (completado)

- `tools/orchestrator-contract.md` (246 lineas): contrato formal del invocador externo. Claude no puede hacer file I/O (`--permission-prompts none`); el orchestrator compone el prompt con contexto embebido y escribe la evidencia.
- `tools/run-review-step.ps1` (446 lineas): automatiza el paso 4 (review). Probado contra T-0001: `REVIEW_PASS` en 17.66s, $0.05.
- `tools/run-certification-step.ps1` (478 lineas): automatiza el paso 6 (certification). Probado contra T-0001: `READY_FOR_MERGE_AUTHORIZATION` en 10.61s, $0.03.
- Comparacion automatizado vs asistido: los 7 hallazgos y el `candidate_commit` son identicos. El automatizado es MAS detallado (5 notas vs 3, evidencia contextual).
- Claude detecto una anomalia temporal en T-0001 (QA anterior al review) que el asistido no vio. Confirmada por Vic como artefacto del D4. Documentada en `CONFIRMACION-ANOMALIA-TEMPORAL.md` y `F12`.
- **Resultado:** 2 de 5 pasos del ciclo V3 automatizados (`review` + `certification`). Los otros 3 (plan, frontend, QA) siguen asistidos.
- Coste total del D4: ~$0.08 de cuota Claude (17.66s + 10.61s).

### Semana 2 - D5: Decision de migracion (completado)

- Diagnostico de readiness: los unicos repos Git con proyectos son el Core y el piloto descartable.
- `i-Tkt`, `TRDStation` y `PROXTEL-PBX` no existen como repos Git en `C:\DEV\`.
- **Decision: NO-GO** documentada en `docs/decisions/D5-migration-decision.md`.
- Criterios C1-C5 definidos para cuando aparezca el primer proyecto real.
- Estado de la agencia: operativa al 80% (Core completo, 2/6 pasos automatizados, piloto certificado).
- Pendientes antes del primer cliente: certificar Codex y Antigravity si la tarea los requiere.

---

## Estado final de la Semana 2

| Dia | Estado |
|---|---|
| D1 - Verificacion del piloto | COMPLETADO |
| D2 - Correcciones F1-F9 + herramientas | COMPLETADO |
| D3 - Adapter Claude promovido a approved | COMPLETADO |
| D4 - Orchestrator + 2/6 pasos automatizados | COMPLETADO |
| D5 - Decision NO-GO justificada | COMPLETADO |

**La agencia esta lista para recibir su primer cliente real.**

Tag de cierre: `v3-semana2-completa`

### D6 - Mejoras opcionales de calidad (completado)

- F13 (UTF-8): `[Console]::OutputEncoding = UTF8` anadido a ambos scripts. Elimina mojibake en `git diff`.
- D6.2 (`quota-log.md`): reescrito para alinear con politica R. Elimina inconsistencia "70% semanal" detectada por Claude en D3.
- F12 (validacion temporal): `run-certification-step.ps1` detecta QA anterior a Review y bloquea por defecto. Flag `-AllowTemporalAnomaly` para excepciones autorizadas.
- F14 documentada: `.Replace()` falla silenciosamente con CRLF vs LF en Windows. Patron array-linea documentado.
- Tests: F12 test 1 (sin flag) falla correctamente, test 2 (con flag) invoca Claude y genera certification valido.

**Estado: agencia operativa al 85%.** Los 3 fixes de calidad (F13, quota-log, F12) resueltos. Deudas menores pendientes (F14 patron aplicado, mojibake no ejercitado en test real). Ninguna bloquea operar.

Tag siguiente cuando termine D6: `v3-d6-calidad`
