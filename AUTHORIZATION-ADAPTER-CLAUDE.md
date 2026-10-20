# Autorización de promoción — Adapter Claude

**Fecha:** 2026-10-20
**Hora UTC:** 2026-10-20T17:01:51Z
**Autorizado por:** Vic (CEO, PROXTEL AI Agency)
**Adapter:** `claude`
**Cambio:** `candidate / not-executed` → `approved / live-tested`

---

## Requisitos cumplidos (R1-R5 de `standards/adapter-promotion.md`)

| Requisito | Estado | Evidencia |
|---|---|---|
| R1 — Smoke test PASS | ✅ | `claude-native-live-smoke-c18-certification-v1.json` (`status: CERTIFIED`, `result: PASS`) |
| R2 — Gobernanza SATISFIED | ✅ | C18 + C31 (`required_action_3_overall: SATISFIED`) |
| R3 — Verificación versión actual | ✅ | Verificación rápida 7/7 campos con 2.1.284 (2026-10-20) |
| R4 — Autorización Vic | ✅ | Este documento |
| R5 — Certificación de promoción | ✅ | `claude-adapter-promotion-certification-v1.json` |

---

## Version drift documentado

| Dato | Valor |
|---|---|
| Versión del smoke test C18 | `2.1.268 (Claude Code)` |
| SHA256 del .exe en C18 | `1E472BCFD49449E73EF76698C87F6583055AEB88DC41CA190A9C12C6791B5EEA` |
| Versión actual del CLI | `2.1.284 (Claude Code)` |
| SHA256 del .exe actual | `0416631E846F743110DA5282409776FA1313E65F33A588AAE066EAF8DB0FDA7D` |
| Binario cambió | **SÍ** |
| Mitigación | Verificación rápida con el mismo prompt y schema de C18. Resultado: 7/7 campos PASS |

**Conclusión:** el binario cambió entre C18 y hoy. La verificación rápida con la versión actual confirma que el structured-output transport sigue operativo. El drift está documentado, no oculto.

---

## Evidencia citada

- `tests/integration/provider-adapters/behavioral-v2-harness/provider-smokes/claude/formal-reports/claude-native-live-smoke-c18-certification-v1.json`
- `tests/integration/provider-adapters/behavioral-v2-harness/provider-smokes/antigravity/formal-reports/antigravity-1.2.6-live-smoke-c31-certification-v1.json`
- `standards/adapter-promotion.md` (reglas formales)
- `docs/lessons/pilot-day4-5.md` F7 (fricción que motivó la promoción)

---

## Cambio autorizado

Editar `adapters/claude/adapter.json` con exactamente estos 5 cambios:

1. `lifecycle.state`: `"candidate"` → `"approved"`
2. `lifecycle.execution_status`: `"not-executed"` → `"live-tested"`
3. `lifecycle.approved_utc`: nuevo campo `"2026-10-20T17:01:51Z"`
4. `lifecycle.certification_ref`: nuevo campo con path a `claude-adapter-promotion-certification-v1.json`
5. `cli.observed_version`: `"2.1.268 (Claude Code)"` → `"2.1.284 (Claude Code)"`

**No se tocan** los campos `prompt_transport`, `structured_output`, `execution_context`, `safety` ni `evidence`.

---

## Rollback disponible

Si el adapter promovido falla en operación:
- Editar `lifecycle.state` de vuelta a `"candidate"`
- Mantener `execution_status: "live-tested"` (no retroceder)
- Crear `ROLLBACK-ADAPTER-CLAUDE-<fecha>.md` con motivo
- Commit: `revert(adapter): regresa claude a candidate por <motivo>`

---

## Firma

**Vic** — CEO, PROXTEL AI Agency
Fecha: 2026-10-20
UTC: 2026-10-20T17:01:51Z
