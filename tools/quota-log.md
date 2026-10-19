# Control de cuotas semanales

Registro del uso de las tres suscripciones de IA. Se actualiza cada viernes.
Umbral de reruteo: 70% semanal. Ver docs/architecture-v3.md sección 5.

---

## Semana actual

Anotar el viernes al cierre de jornada:

| Proveedor | Uso estimado | Estado | Acción tomada |
|---|---|---|---|
| Claude (Anthropic) | [ ] <50%  [ ] 50-70%  [ ] >70% | | |
| Codex (OpenAI) | [ ] <50%  [ ] 50-70%  [ ] >70% | | |
| Antigravity (Google) | [ ] <50%  [ ] 50-70%  [ ] >70% | | |

---

## Reglas de reruteo

- Frontend, prototipos, auditoría visual → siempre Antigravity (cuota Google separada).
- Revisión de código, arquitectura, orquestación → Claude Sonnet, nunca Opus por defecto.
- Implementación backend, refactors → Codex.
- Si Claude supera 70% → derivar auditorías visuales y documentación a Antigravity; reservar Claude solo para /review y planificación.
- Si Codex supera 70% → bajar nivel de razonamiento a medio; reservar alto solo para bugs difíciles.
- Si Antigravity supera 70% → pausar prototipos no críticos; priorizar auditorías del piloto en curso.

---

## Comandos de medición

Consultar al inicio de jornada y antes de asignar trabajo considerable:

- Claude Code: /usage
- Codex CLI: /status (cuando presente información de límites)
- Antigravity CLI: /usage o /quota

Definición operativa: R = menor porcentaje de cuota restante entre las ventanas
que limitan al recurso. Si quedan 60% en una ventana y 12% en otra, se usa R=12%.

---

## Umbrales de reruteo

| Cuota restante R | Estado operativo | Acción |
|---|---|---|
| Mayor de 30% | Normal | Asignaciones habituales |
| 15-30% | Reserva | No iniciar tareas grandes; priorizar pendientes |
| 5-15% | Crítico | Solo trabajo indispensable y cierre |
| 5% o menos | Protección | Detener nuevas asignaciones |
| Límite alcanzado | Bloqueo | Reasignar o esperar restablecimiento |

---

## Historial

| Semana | Claude | Codex | Antigravity | Notas |
|---|---|---|---|---|
| 2026-W42 | | | | Semana 1 de certificación |
| 2026-W43 | | | | |
| 2026-W44 | | | | |
