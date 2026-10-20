# Autorizacion de promocion - Adapter Codex

**Fecha:** 2026-10-20
**Hora UTC:** 2026-10-20T23:00:00Z
**Autorizado por:** Vic (CEO, PROXTEL AI Agency)
**Adapter:** codex
**Cambio:** candidate / not-executed -> approved / live-tested

---

## Requisitos cumplidos (R1-R5)

| Requisito | Estado | Evidencia |
|---|---|---|
| R1 - Smoke test PASS | OK | `codex-adapter-promotion-certification-v1.json` (packet C32) |
| R2 - Gobernanza | OK | C32 PASS + limpieza de deuda de C9-fix2 |
| R3 - Verificacion version actual | OK | Re-verificacion C32 7/7 con codex-cli 0.154.0 (hash 0C149DB8...) |
| R4 - Autorizacion Vic | OK | Este documento |
| R5 - Certificacion de promocion | OK | `codex-adapter-promotion-certification-v1.json` |

---

## Historial de intentos

| Intento | Fecha | Resultado | Causa |
|---|---|---|---|
| C9-fix2 | 2026-09 | FAIL_BEHAVIOR | benchmark_expectation_too_strict + prompt_semantic_contamination |
| C32 | 2026-10-20 | PASS (7/7) | Prompt de transporte puro, 549 bytes |

**Nota:** C9-fix2 fallo por diseno del benchmark, no del adapter. El prompt de 16568 bytes embebia Skill + metodologia + caso, creando ambiguedad. C32 corrige esto: prompt de 549 bytes, transporte puro, sin instrucciones de razonamiento.

---

## Version drift documentado

| Momento | Version | SHA256 del .ps1 | Resultado |
|---|---|---|---|
| Preparacion adapter (2026) | codex-cli 0.154.0 | (no registrado) | candidate |
| Smoke C32 (2026-10-20) | codex-cli 0.154.0 | 0C149DB80ED0BF442C810146B0AD0163B74982FE4542D673F56C354D7B8229CB | PASS |

**Sin drift detectado.** La version se mantuvo estable durante la preparacion y promocion.

---

## Cambio autorizado

Editar `adapters/codex/adapter.json` con exactamente estos 6 cambios:

1. `lifecycle.state`: "candidate" -> "approved"
2. `lifecycle.execution_status`: "not-executed" -> "live-tested"
3. `lifecycle.approved_utc`: "2026-10-20T23:00:00Z"
4. `lifecycle.certification_ref`: "tests/integration/.../codex-adapter-promotion-certification-v1.json"
5. `cli.observed_version`: "codex-cli 0.154.0" (confirmado, sin cambio)
6. `safety.permission_control`: corregir para reflejar que `codex exec` NO expone `--ask-for-approval`

**No se tocan** los campos prompt_transport, structured_output, execution_context, evidence.

## Rollback disponible

- `adapters/codex/adapter.json.backup-candidate` (hash F1A820C8...)
- Restaurar con `Copy-Item ...backup-candidate ... -Force`

## Firma

**Vic** - CEO, PROXTEL AI Agency
Fecha: 2026-10-20
UTC: 2026-10-20T23:00:00Z
