# D5 — Decisión de migración al ciclo V3

**Fecha:** 2026-10-20
**Autoridad:** Vic (CEO, PROXTEL AI Agency)
**Fase:** Semana 2, Día 5
**Estado de la agencia:** Core V3 completo, 2/6 pasos automatizados
**Decisión:** NO-GO para migrar proyectos al ciclo V3

---

## Contexto

El D5 tenía como objetivo decidir si migrar `i-Tkt` o `TRDStation` al ciclo V3 automatizado. Antes de decidir, se ejecutó diagnóstico de readiness (D5.1).

## Diagnóstico de readiness

### Proyectos con repositorio Git en `C:\DEV\`

| Repositorio | Tipo | Estado |
|---|---|---|
| `PROXTEL-AI-AGENCY` | Core de la agencia | Activo, es el Core mismo |
| `piloto-v3` | Piloto descartable T-0001 | Certificado, descartable |
| `piloto-v3-T-0001-int` | Worktree de integración | Parte del piloto |
| `piloto-v3-T-0001-ui` | Worktree de implementación | Parte del piloto |

### Proyectos sin repositorio Git

| Carpeta | Estado |
|---|---|
| `WEBS` | Sin `.git`, sin versionado |
| `TOOLS` | Sin `.git`, sin versionado |
| `BACKUPS` | Sin `.git`, sin versionado |
| `AUDITS` | Sin `.git`, sin versionado |
| `PROXTEL` | Sin `.git`, sin versionado |

### Proyectos mencionados en la visión pero no existentes en disco

- `i-Tkt` — no existe como repositorio
- `TRDStation` — no existe como repositorio
- `PROXTEL-PBX` — no existe como repositorio

## Decisión

**NO-GO.** No hay proyectos reales que cumplan las condiciones de incorporación del ciclo V3 (definidas en `docs/architecture-v3.md` sección 7.8).

Migrar "nada" no es migrar. Documentar un NO-GO es más honesto que forzar un GO artificial.

## Estado de la agencia al cierre del D5

| Capacidad | Estado |
|---|---|
| Core V3 completo | ✅ |
| Ciclo V3 (6 pasos) | ✅ Diseñado y documentado |
| Adapter Claude | ✅ `approved / live-tested` |
| Adapters Codex + Antigravity | ⏳ `candidate / not-executed` |
| Pasos automatizados | 2 de 6 (`review` + `certification`) |
| Piloto T-0001 certificado | ✅ (descartable) |
| Proyectos reales activos | 0 |
| Clientes activos | 0 |

**La agencia está lista. No tiene clientes todavía.**

## Criterios para futuro GO

El GO se ejecutará cuando aparezca el primer proyecto que cumpla **TODOS** estos criterios:

### C1 — Repositorio Git real
- Existe `C:\DEV\<proyecto>\` con `.git/` inicializado
- Tiene al menos 1 commit en `main`
- Tiene historial de trabajo real (no solo un init vacío)

### C2 — `PROJECT-SKILLS.md` creado y validado
- Existe `C:\DEV\<proyecto>\PROJECT-SKILLS.md`
- Pasa `tools\check-project-skills.ps1 -Path <ruta>` con PASS
- Declara al menos 1 skill `approved` del catálogo

### C3 — Tarea en curso estabilizada
- No hay trabajo activo sin commit
- No hay cambios sin commitear (working tree clean)
- El cliente acepta cerrar el trabajo actual antes de adoptar el ciclo V3

### C4 — Primera tarea V3 identificada
- Hay una tarea concreta (ej. "T-0001: integrar cotizaciones al CRM")
- La tarea cabe en el ciclo de 6 pasos (no requiere 3 meses de arquitectura previa)
- El cliente aprueba el ciclo con sus 6 gates

### C5 — Adapters certificados según el tipo de tarea
- Si la tarea es solo frontend: Claude + Antigravity certificados (Antigravity aún en candidate)
- Si la tarea es backend: Claude + Codex certificados (Codex aún en candidate)
- Si la tarea es full-stack: los 3 certificados

**Regla:** si los adapters necesarios no están certificados, la tarea se ejecuta en **modo asistido** (manual) hasta certificarlos.

## Acciones de la agencia antes del primer proyecto real

| Acción | Prioridad | Esfuerzo estimado |
|---|---|---|
| Certificar adapter Codex (promoción a `approved`) | Alta | 2-3 h |
| Certificar adapter Antigravity (promoción a `approved`) | Alta | 2-3 h |
| Añadir validación de orden temporal (F12) al orchestrator | Media | 1 h |
| Arreglar mojibake UTF-8 en `git diff` (F13) | Baja | 30 min |
| Arreglar `tools/quota-log.md` (mezcla 2 políticas) | Baja | 30 min |

**Ninguna de estas acciones es obligatoria para que la agencia funcione.** Son mejoras incrementales. La agencia puede recibir un cliente hoy y ejecutar su primer proyecto en **modo asistido + automatización parcial** sin problemas.

## Veredicto

**La agencia está operativa al 80%** (Core completo, piloto certificado, 2/6 pasos automatizados). El 20% restante (certificar Codex y Antigravity) se ejecuta cuando aparezca el primer cliente real que lo justifique.

Forzar la certificación de los otros 2 adapters sin proyecto real que los valide sería **trabajo especulativo**. La política de la agencia es: **certificar lo que se usa, no lo que podría usarse**.

---

**Firmado:** Vic — CEO, PROXTEL AI Agency
**Fecha:** 2026-10-20
**Válido hasta:** que aparezca el primer proyecto real que cumpla C1-C5
