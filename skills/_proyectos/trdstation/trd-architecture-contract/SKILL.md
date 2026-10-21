---
name: trd-architecture-contract
description: Identifica los 10 contratos canonicos de arquitectura de TRDStation, la tabla de contratos obligatorios por repositorio y dominio, y el criterio para determinar el estado de cada contrato (pendiente, definido, aprobado). Los agentes la consultan antes de planificar tareas de Etapa 1+.
---

# TRDStation Architecture Contract

## Proposito

Esta skill permite a los agentes (Claude Code, Codex, Antigravity) saber:

1. Cuales son los 10 contratos canonicos de arquitectura de TRDStation.
2. Cuales son obligatorios segun el repositorio y dominio de la tarea.
3. Como determinar si un contrato esta pendiente, definido o aprobado.
4. Cuando deben bloquear la planificacion por falta de contrato obligatorio.

**No duplica los contratos.** Apunta a la fuente normativa con hash de integridad.

---

## Regla de oro

Esta skill NO sustituye los contratos. Es un indice operativo:

- **Lo que la skill contiene:** nombres, obligatoriedad, criterio de estado, reglas de bloqueo.
- **Lo que la skill NO contiene:** el texto completo de cada contrato (vive en `docs/architecture/` del repositorio correspondiente).
- **Cuando un agente necesita el contenido de un contrato:** lo lee de su archivo real, no de esta skill.

El esqueleto de referencia esta congelado en `references/source-snapshot.md` con hash `112C80F93FF572DD42A54FEE5F9721316533F800AD4E883F62C0629109E7D06B` para trazabilidad.

---

## Los 10 contratos canonicos

| # | Contrato | Fase de definicion | Consumidores |
|---|---|---|---|
| 1 | PRODUCT-CONTRACT.md | Etapa 1 | Todos |
| 2 | CORE-CONTRACT.md | Etapa 1 | Core, Broker, Deploy |
| 3 | BROKER-CONTRACT.md | Etapa 1 | Broker, Core |
| 4 | DEPLOY-CONTRACT.md | Etapa 1 | Deploy, Core, Broker |
| 5 | MARKET-DATA-CONTRACT.md | Etapa 1 | Core, Broker, Deploy |
| 6 | TRADING-DOMAIN-CONTRACT.md | Etapa 1 | Core, Broker |
| 7 | REALTIME-CONTRACT.md | Etapa 1 | Core, Broker, Deploy |
| 8 | WHITE-LABEL-CONTRACT.md | Etapa 1 | Core, Broker, Deploy |
| 9 | TELEPHONY-CONTRACT.md | Etapa 1 | Core, Broker, Deploy |
| 10 | SECURITY-CONTRACT.md | Etapa 1 | Todos |

Propósito de cada contrato y reglas duras: ver `references/source-snapshot.md`.

---

## Contratos obligatorios por repositorio

Antes de escribir **codigo funcional** en un repositorio, los contratos listados deben estar en estado **aprobado**.

| Repositorio | Contratos obligatorios |
|---|---|
| `trdstation-core` | PRODUCT, CORE, TRADING-DOMAIN, MARKET-DATA, REALTIME, SECURITY |
| `trdstation-broker` | PRODUCT, BROKER, MARKET-DATA, REALTIME, WHITE-LABEL, SECURITY |
| `trdstation-deploy` | PRODUCT, DEPLOY, SECURITY |

**Excepción por repositorio:** si un contrato ya está listado como obligatorio en la tabla del repositorio (líneas 56-60), esa obligatoriedad **prevalece** sobre la excepción de dominio. En particular, WHITE-LABEL es obligatorio en `trdstation-broker` porque el broker es white-label por naturaleza.

**Excepción por dominio:** DEPLOY, TELEPHONY y WHITE-LABEL **no** son obligatorios por defecto en Etapa 2-6 para repositorios donde no figuran como obligatorios (core y deploy). Solo aplican cuando la tarea toca ese dominio específico y el repositorio lo requiere.

---

## Contratos obligatorios por dominio

Cuando el Task Contract menciona un dominio, aplican los contratos de esa fila **ademas** de los del repositorio.

| Dominio | Contratos obligatorios adicionales |
|---|---|
| Market Data | MARKET-DATA |
| Trading Engine | TRADING-DOMAIN |
| Realtime | REALTIME |
| White Label | WHITE-LABEL |
| Telephony | TELEPHONY |
| Manager / CRM | CORE, SECURITY |
| Auth / Identity | CORE, SECURITY |

Si una tarea cruza 2 dominios (ej. Market Data + Realtime), aplican los contratos de ambos.

---

## Criterio para determinar el estado de un contrato

Un contrato solo puede estar en uno de tres estados:

| Estado | Definicion | Evidencia requerida |
|---|---|---|
| **pendiente** | El contrato no existe como archivo | No hay `docs/architecture/<CONTRATO>.md` |
| **definido** | El archivo existe pero no esta aprobado formalmente | Existe `docs/architecture/<CONTRATO>.md` sin ADR asociado o sin firma de Vic |
| **aprobado** | El contrato esta vigente y aprobado | Existe `docs/architecture/<CONTRATO>.md` + ADR asociado en `docs/adr/` + firma de Vic en el ADR o en un gate documentado |

**Como verificar:** el agente debe:
1. Verificar que existe el archivo en `docs/architecture/`.
2. Verificar que existe el ADR correspondiente en `docs/adr/`.
3. Verificar que el ADR tiene `status: approved` y firma de Vic.

**Si alguno de los tres falta**, el contrato esta en estado `definido` o `pendiente`, no `aprobado`.

---

## Qué cuenta como código funcional

Una tarea se considera **código funcional** si modifica o crea:

- Archivos de aplicación (`.php`, `.ts`, `.tsx`, `.vue`, `.js`).
- Migraciones de base de datos.
- Seeders o factories.
- Configuración de aplicación en código (no en YAML).
- Dockerfiles, docker-compose, entrypoints.
- Workflows de CI/CD que ejecutan código.
- Tests automatizados (Pest, Vitest, Playwright).

Una tarea **NO** se considera código funcional si es:

- Documentación (README, ADR, contratos).
- Configuración de infraestructura sin código (Terraform, Ansible sin código PHP).
- Setup de repositorios (git init, estructura de carpetas).
- Instalación de skills, MCPs o plugins.
- Cambios en `.env.example`, `.gitignore`, `.editorconfig`.

**Regla:** si la tarea produce archivos ejecutables o migraciones, es código funcional.

---


## Reglas de bloqueo

### Cuando NO se bloquea

| Tarea | Se bloquea? | Razon |
|---|---|---|
| Tareas de Etapa 0 (setup de repos, skills, MCPs) | **NO** | No escriben codigo funcional |
| Tareas de Etapa 1 (escribir los contratos) | **NO** | Es la etapa en la que se definen los contratos |
| Tareas de documentacion o infraestructura sin codigo | **NO** | No violan contratos |

### Cuando SI se bloquea

Una tarea de **codigo funcional** en **Etapa 2 o superior** se bloquea si:

1. El repositorio tiene contratos obligatorios en estado `pendiente` o `definido`.
2. El dominio de la tarea tiene contratos obligatorios en estado `pendiente` o `definido`.
3. El Task Contract referencia un contrato que no existe en `docs/architecture/`.

**El agente debe bloquear la planificacion** y devolver al humano con la lista de contratos faltantes.

---

## Regla transversal

Esta skill debe permitir que los agentes:

1. Identifiquen los contratos aplicables segun repositorio, dominio y alcance del Task Contract.
2. Distingan contratos pendientes, definidos y aprobados, sin interpretar esta skill como un contrato definitivo.
3. Declaren dependencias y contradicciones arquitectonicas antes de planificar una implementacion.
4. Bloqueen la planificacion de codigo funcional cuando falte un contrato obligatorio aprobado.
5. No modifiquen contratos canonicos automaticamente: cualquier cambio arquitectonico requiere revision y gate humano (Vic).

**Distincion fundamental:** Etapa 0 crea la skill que identifica y consulta contratos. Etapa 1 produce y aprueba su contenido normativo. Las etapas posteriores implementan respetando esos contratos.

---

## Cuando usar esta skill

- Antes de planificar cualquier tarea de Etapa 1 o superior.
- Cuando el Task Contract mencione un contrato especifico.
- Cuando haya duda sobre que contratos aplican a una tarea segun su repositorio y dominio.
- Antes de bloquear una tarea por falta de contrato.

## Cuando NO usar esta skill

- Para tareas de Etapa 0 (setup de repos, skills, MCPs).
- Para ejecutar codigo (esta skill no ejecuta).
- Para modificar contratos (esta skill no modifica).
- Para sustituir los contratos completos (solo apunta a la fuente).
- Para tareas de documentacion sin codigo funcional.

---

## Prohibiciones

- **No modificar** los contratos canonicos automaticamente.
- **No inventar** contenido de contratos no definidos todavia.
- **No asumir** que un contrato existe si solo esta listado aqui sin archivo real en `docs/architecture/`.
- **No duplicar** el texto completo de los contratos en esta skill.
- **Excepción: el snapshot histórico.** `references/source-snapshot.md` es una copia congelada del esqueleto con hash, fecha y commit. No es una copia operativa; es evidencia de trazabilidad para verificar que la skill no fue modificada después de la aprobación. Cuando el esqueleto cambie en origen, el snapshot se regenera y se re-audita.
- **No promover** un contrato a `aprobado` sin ADR + firma de Vic.
- **No saltarse** el gate de bloqueo por presion de tiempo o conveniencia.

---

## Referencias

- **Fuente normativa:** `trdstation-core/docs/architecture/`
- **Snapshot del esqueleto:** `references/source-snapshot.md` (hash `112C80F93FF572DD42A54FEE5F9721316533F800AD4E883F62C0629109E7D06B`)
- **Commit fuente del esqueleto:** `9031326` en `trdstation-core`
- **Blueprint V2:** `C:\DEV\TRDSTATION\trdstation-core\docs\architecture\` (fuente del esqueleto)
- **ADRs:** `trdstation-core/docs/adr/`
- **Skill relacionada:** `trd-task-contract` (definicion del Task Contract)
- **Skill relacionada:** `trd-contract-first` (flujo contrato antes que codigo)
