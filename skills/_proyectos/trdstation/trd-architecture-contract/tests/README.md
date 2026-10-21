# Tests — trd-architecture-contract

Evidencia de testing de la skill. Cumple con `testing.trigger_tests: true` y `testing.task_evals: true` del `skill.json`.

## Archivos

| Archivo | Proposito |
|---|---|
| `trigger-tests.json` | 6 positivos + 4 negativos. Verifica cuando la skill debe activarse. |
| `task-evals.json` | 5 escenarios con precondiciones de estado de contratos y comportamiento esperado (ALLOW / BLOCK). |

## Como se ejecutan

Estos tests son **documentales y evaluables manualmente** por un auditor humano o por un agente en modo evaluacion.

Un auditor valida que:
1. Los 6 positivos activan la skill (o describen un caso donde deberia activarse).
2. Los 4 negativos NO activan la skill.
3. Los 5 evals producen el comportamiento esperado segun la precondicion de contratos.

## Integracion con audit

El `proxtel-skill-auditor` gate "Evaluation" revisa:
- Existencia de los archivos (trigger-tests.json + task-evals.json).
- Alineacion entre `testing.trigger_tests: true` en `skill.json` y la existencia real de tests.
- Cobertura: al menos 3 positivos + 2 negativos + 2 evals.

Con este paquete: 6 + 4 + 5 = 15 casos, cumple y excede el minimo.

## Cuando regenerar

Regenerar los evals cuando:
- Cambia la tabla de contratos obligatorios por repositorio o dominio.
- Cambia el criterio de estado (pendiente / definido / aprobado).
- Se anaden contratos nuevos al esqueleto.
- Se modifica la regla de bloqueo.

En esos casos:
1. Actualizar `trigger-tests.json` si el cambio afecta la activacion.
2. Actualizar `task-evals.json` si el cambio afecta el comportamiento ALLOW/BLOCK.
3. Actualizar el hash del `source-snapshot.md`.
4. Re-auditar.
