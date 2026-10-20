# Adapter promotion

Reglas formales para promover un provider adapter de `candidate` a `approved`.
Sin este documento, la promoción es ad-hoc y no auditable.

Documento relacionado: `config/schemas/proxtel-provider-adapter.schema.json`

---

## Estados del adapter

### `lifecycle.state` (estado de ciclo de vida)

| Valor | Significado | Quién puede cambiarlo |
|---|---|---|
| `candidate` | Adapter en pruebas. No se usa en producción. | Estado inicial por defecto |
| `approved` | Adapter verificado y autorizado. Uso operativo permitido. | Solo Vic, con evidencia |
| `deprecated` | Adapter obsoleto. No usar en tareas nuevas. | Solo Vic, con justificación |

### `lifecycle.execution_status` (estado de ejecución real)

| Valor | Significado |
|---|---|
| `not-executed` | No se ha ejecutado nunca en modo no-interactivo |
| `dry-run-tested` | Se ha validado con dry-run (sin invocación real al modelo) |
| `live-tested` | Se ha ejecutado en vivo contra el proveedor real, con smoke test PASS |

---

## Requisitos para promover `candidate` → `approved`

**Los 5 requisitos deben cumplirse simultáneamente. Si uno falla, no hay promoción.**

### R1 — Smoke test PASS documentado

- Existe un certificado de smoke test (`*certification*.json`) con `status: CERTIFIED`
- El smoke test usó un packet con `one_model_call: true`, `automatic_retry: false`, `dangerous_bypass: false`
- El resultado tiene `structured_output.result: "PASS"` con los 7 campos del schema
- El packet está marcado `consumed: true` (one-shot respetado)

### R2 — Gobernanza SATISFIED

- El smoke test reporta `governance.required_action_3_claude_portion: SATISFIED` (o el equivalente del provider)
- Si hay condiciones cruzadas (ej. requerir smoke de múltiples providers), todas deben estar `SATISFIED`

### R3 — Verificación de versión actual

- Se ejecutó una verificación rápida con la versión **actual** del CLI (no la del smoke test original)
- La verificación usó el mismo prompt y schema del smoke test original
- El resultado coincide en los 7 campos del schema

**Justificación:** el smoke test original puede tener meses. La verificación rápida confirma que la versión actual sigue funcionando sin necesidad de crear un packet nuevo con lock/certificación completa. El version drift se documenta en la certificación de promoción, no se oculta.

### R4 — Autorización formal de Vic

- Existe `AUTHORIZATION-ADAPTER-<provider>.md` firmado
- El documento cita: certificado de smoke test, verificación de versión actual, decisión de promover
- Sin este documento, la promoción no procede

### R5 — Certificación de promoción

- Existe `tests/integration/provider-adapters/behavioral-v2-harness/provider-smokes/<provider>/formal-reports/<provider>-adapter-promotion-certification-v1.json`
- Este JSON documenta:
  - Referencia al smoke test original (R1)
  - Referencia a la gobernanza (R2)
  - Referencia a la verificación de versión (R3)
  - Referencia a la autorización de Vic (R4)
  - Cambio de estado aplicado (`candidate` → `approved`)
  - Versión de CLI observada al promover
  - Fecha y commit SHA de la promoción

---

## Proceso (6 fases)

### Fase 1 — Pre-flight

- Verificar que el adapter existe en `adapters/<provider>/adapter.json`
- Verificar que el estado actual es `candidate` (si ya es `approved`, no hay nada que hacer; si es `deprecated`, requiere decisión explícita)
- Verificar que el schema `config/schemas/proxtel-provider-adapter.schema.json` sigue vigente
- Verificar que el CLI responde (`<cli> --version`)

### Fase 2 — Verificar smoke test y gobernanza

- Localizar el certificado de smoke test más reciente
- Confirmar `status: CERTIFIED`, `structured_output.result: "PASS"`, `governance.required_action_3_*: SATISFIED`
- Si no hay smoke test o la gobernanza no está satisfecha: **detener**. No se puede promover sin smoke test.

### Fase 3 — Verificación de versión actual

- Ejecutar la verificación rápida (mismo prompt + schema del smoke test) con la versión actual
- Verificar 7/7 campos del schema
- Si falla: **detener**. El adapter no se promueve.
- Documentar el resultado en la certificación de promoción

### Fase 4 — Crear `AUTHORIZATION-ADAPTER-<provider>.md`

- Incluye: fecha, firmante (Vic), evidencia citada, decisión, hash del CLI actual
- Se commitea junto con la promoción

### Fase 5 — Aplicar el cambio

Editar `adapters/<provider>/adapter.json`:

```json
{
    "lifecycle": {
        "state": "approved",
        "version": "0.1.0",
        "execution_status": "live-tested",
        "approved_utc": "YYYY-MM-DDTHH:MM:SSZ",
        "certification_ref": "tests/integration/provider-adapters/behavioral-v2-harness/provider-smokes/<provider>/formal-reports/<provider>-adapter-promotion-certification-v1.json"
    },
    "cli": {
        "observed_version": "<versión actual del CLI>"
    }
}

**Cambios exactos:**
- `lifecycle.state`: `"candidate"` → `"approved"`
- `lifecycle.execution_status`: `"not-executed"` → `"live-tested"` (o `"dry-run-tested"` si solo se hizo dry-run)
- `lifecycle.approved_utc`: nuevo campo con timestamp ISO 8601 UTC
- `lifecycle.certification_ref`: nuevo campo con path a la certificación de promoción
- `cli.observed_version`: actualizar a la versión actual del CLI

### Fase 6 — Crear certificación de promoción y commit

- Crear el JSON `<provider>-adapter-promotion-certification-v1.json`
- Commit con mensaje: `feat(adapter): promueve <provider> a approved (cert: CXX + verify YYYY-MM-DD)`
- Push a `origin/main`

---

## Reglas duras

1. **Ningún adapter se promueve sin smoke test PASS.** Si no hay smoke test, hay que crearlo primero (con su packet one-shot y ejecución real).

2. **La verificación de versión actual es obligatoria.** No se acepta "el smoke test decía PASS hace 3 meses". Hay que confirmar que la versión actual sigue funcionando.

3. **El version drift se documenta, no se oculta.** Si el smoke test fue con 2.1.268 y la promoción se hace con 2.1.284, la certificación de promoción lo dice explícitamente.

4. **La promoción no es automática.** Requiere autorización formal de Vic (`AUTHORIZATION-ADAPTER-<provider>.md`).

5. **El cambio es quirúrgico.** Solo se editan los 5 campos listados. No se tocan `prompt_transport`, `structured_output`, `execution_context`, `safety` ni `evidence`.

6. **Rollback disponible.** Si el adapter promovido falla en operación:
   - Editar `lifecycle.state` de vuelta a `"candidate"`
   - Mantener `execution_status: "live-tested"` (no retroceder)
   - Crear documento `ROLLBACK-ADAPTER-<provider>-<fecha>.md` con motivo
   - Commit con mensaje: `revert(adapter): regresa <provider> a candidate por <motivo>`

7. **Deprecación.** Si un adapter se vuelve obsoleto (nueva versión del CLI, cambio de API):
   - `lifecycle.state: "deprecated"`
   - Mantener `execution_status` como estaba
   - Documentar en `AUTHORIZATION-ADAPTER-<provider>-DEPRECATION.md`

---

## Ejemplo aplicado — Claude (2026-10-20)

| Requisito | Evidencia | Estado |
|---|---|---|
| R1 — Smoke test PASS | `claude-native-live-smoke-c18-certification-v1.json` | ✅ CERTIFIED |
| R2 — Gobernanza SATISFIED | C18 + C31 (`required_action_3_overall: SATISFIED`) | ✅ |
| R3 — Verificación versión actual | 7/7 campos PASS con 2.1.284 (2026-10-20) | ✅ |
| R4 — Autorización Vic | `AUTHORIZATION-ADAPTER-CLAUDE.md` | ✅ |
| R5 — Certificación de promoción | `claude-adapter-promotion-certification-v1.json` | ✅ |

**Version drift documentado:** smoke test C18 con 2.1.268; promoción verificada con 2.1.284. Diferencia: 16 versiones patch. Verificación rápida confirma comportamiento idéntico.

**Decisión:** `approved` + `live-tested` a partir del 2026-10-20.

---

## Referencias

- `config/schemas/proxtel-provider-adapter.schema.json` — schema del adapter
- `adapters/<provider>/adapter.json` — archivos de adapter
- `tests/integration/provider-adapters/behavioral-v2-harness/provider-smokes/<provider>/formal-reports/` — certificaciones
- `standards/permissions.md` — niveles A/B (la promoción es Nivel B: requiere aprobación de Vic)
- `AGENTS.md` sección "Adapters de proveedores" — contexto
- `docs/lessons/pilot-day4-5.md` F7 — fricción del adapter en candidate
- `docs/certification-plan.md` Fase C — plan de certificación
