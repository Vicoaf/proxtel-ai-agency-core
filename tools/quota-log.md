# Control de cuotas semanales

Registro del uso de las tres suscripciones de IA. Se actualiza cada viernes.
Umbral de reruteo: cuota RESTANTE (R) segun tabla. Ver AGENTS.md seccion
"Cuotas y reruteo" y docs/architecture-v3.md seccion 5.

**Importante:** la politica de reruteo se basa en la cuota RESTANTE (R), no en
el porcentaje consumido. R = menor porcentaje restante entre las ventanas que
limitan al recurso. Ejemplo: si quedan 60% en una ventana y 12% en otra, R=12%.

---

## Semana actual (2026-W43: 2026-10-19 a 2026-10-25)

Anotar el viernes al cierre de jornada:

| Proveedor | R restante | Estado | Accion tomada |
|---|---|---|---|
| Claude (Anthropic) | [ ] >30%  [ ] 15-30%  [ ] 5-15%  [ ] <=5% | | |
| Codex (OpenAI) | [ ] >30%  [ ] 15-30%  [ ] 5-15%  [ ] <=5% | | |
| Antigravity (Google) | [ ] >30%  [ ] 15-30%  [ ] 5-15%  [ ] <=5% | | |

---

## Reglas de reruteo (por cuota restante R)

- Frontend, prototipos, auditoria visual: siempre Antigravity (cuota Google separada).
- Revision de codigo, arquitectura, orquestacion: Claude Sonnet, nunca Opus por defecto.
- Implementacion backend, refactors: Codex.

### Reruteo por proveedor segun R

**Claude (Anthropic):**
- R > 30%: uso normal (Sonnet por defecto).
- R 15-30%: no iniciar tareas grandes. Priorizar /review y planificacion.
- R 5-15%: solo trabajo critico. Suspender Opus preventivamente.
- R <= 5%: detener. Reservar capacidad minima para /review.

**Codex (OpenAI):**
- R > 30%: uso normal.
- R 15-30%: no iniciar tareas tecnicas nuevas de gran alcance.
- R 5-15%: solo correccion de bugs y cierre.
- R <= 5%: detener. Cualquier frontend pendiente se asigna a Antigravity.

**Antigravity (Google):**
- R > 30%: uso normal, prioridad para frontend y auditorias visuales.
- R 15-30%: priorizar correcciones visuales de tareas ya implementadas.
- R 5-15%: pausar prototipos no criticos.
- R <= 5%: detener. Codex puede absorber un cambio frontend imprescindible con autorizacion de Claude.

---

## Comandos de medicion

Consultar al inicio de jornada y antes de asignar trabajo considerable:

- Claude Code: `/usage` (dentro de sesion interactiva)
- Codex CLI: `/status` (cuando presente informacion de limites)
- Antigravity CLI: `/usage` o `/quota`

Definicion operativa: R = menor porcentaje de cuota restante entre las ventanas
que limitan al recurso.

---

## Umbrales de reruteo

| Cuota restante R | Estado operativo | Accion |
|---|---|---|
| Mayor de 30% | Normal | Asignaciones habituales |
| 15-30% | Reserva | No iniciar tareas grandes; priorizar pendientes |
| 5-15% | Critico | Solo trabajo indispensable y cierre |
| 5% o menos | Proteccion | Detener nuevas asignaciones |
| Limite alcanzado | Bloqueo | Reasignar o esperar restablecimiento |

---

## Historial

| Semana | Periodo | Claude (R fin de semana) | Codex (R) | Antigravity (R) | Notas |
|---|---|---|---|---|---|
| 2026-W42 | 2026-10-12 a 10-18 | N/A | N/A | N/A | Semana 1 (pre-Core V3). Sin registro previo. |
| 2026-W43 | 2026-10-19 a 10-25 | [pendiente] | [pendiente] | [pendiente] | Dia 7 + Semana 2 completa. Coste estimado: Claude ~$0.20 (3 adapter runs + smokes). Codex $0. Antigravity $0. |
| 2026-W44 | 2026-10-26 a 11-01 | [pendiente] | [pendiente] | [pendiente] | Post-cierre Semana 2. Primer cliente real esperado. |

---

## Reglas de registro

1. Anotar el viernes al cierre de jornada. No el sabado, no el domingo.
2. R es el dato que importa. No el porcentaje consumido.
3. Si R <= 5% en algun proveedor: anotar la accion tomada (reruteo aplicado o espera).
4. Si hubo reruteo: anotar que tarea se movio de proveedor y por que.
5. Si hubo excepcion (Vic autorizo bypass de la politica): documentar en Notas.

---

## Historial de inconsistencias corregidas

- **2026-10-20 (D6.2):** Claude detecto durante D3 que la cabecera decia "70%
  semanal" mientras la tabla usaba R. Reescrito para alinear todo con politica
  R. Historial inicializado con W42-W44. Reglas de reruteo por proveedor
  expandidas con umbrales R especificos.
