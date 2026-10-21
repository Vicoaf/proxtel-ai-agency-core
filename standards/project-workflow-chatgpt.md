# Project Workflow con ChatGPT

Protocolo de uso de ChatGPT en el ciclo de vida de proyectos.
ChatGPT es ARQUITECTO ESTRATEGICO. No ejecuta, no revisa, no aprueba.

---

## Fase A — Antes de tocar codigo (ChatGPT)

### A.1 — Disenar el proyecto

1. Abrir chat nuevo en ChatGPT
2. Pegar el contenido de templates/CHATGPT-PROJECT-BRIEF.md lleno
3. ChatGPT devuelve: arquitectura + stack + modelo de datos + PROJECT-SKILLS.md + criterios + estimacion
4. Guardar como C:\DEV\<proyecto>\docs\architecture.md

### A.2 — Evaluar viabilidad

Pegar en ChatGPT:

    Con la arquitectura que disenaste, evalua viabilidad:
    1. Algun componente requiere capacidades que no tengo? (adapters, skills)
    2. Algun riesgo bloquea la ejecucion con el ciclo V3 actual?
    3. Que parte del proyecto podria requerir activar un area no registrada (PBX, sales, etc.)?
    Si algo requiere activar un area nueva, dimelo explicitamente.

Esperado: confirmacion de viabilidad o alerta de que hay que activar algo.

### A.3 — Propuesta comercial (si aplica)

    Con la arquitectura aprobada, redacta una propuesta comercial:
    - Resumen ejecutivo (1 parrafo)
    - Alcance funcional (que incluye, que NO incluye)
    - Entregables
    - Fases con fechas estimadas
    - Inversion (3 escenarios: basico, estandar, completo)
    - Condiciones de pago
    - Fuera de alcance
    Tono profesional, maximo 2 paginas.

---

## Fase B — Ejecucion (local, SIN ChatGPT)

1. Crear C:\DEV\<proyecto>\ con git init
2. Copiar templates/PROJECT-SKILLS.md y llenarlo
3. Ejecutar ciclo V3 completo:
   - Paso 1: Claude Code (planificacion) -> 01-plan.md
   - Paso 2: Codex (backend) -> 02-codex.md
   - Paso 3: Antigravity (frontend) -> 03-google.md
   - Paso 4: tools/run-review-step.ps1 -> 04-claude-review.md
   - Paso 5: Playwright + Vic -> 05-playwright.md
   - Paso 6: tools/run-certification-step.ps1 -> 06-certification.yaml
4. Documentar fricciones en docs/lessons/<proyecto>.md

ChatGPT NO interviene en esta fase.

---

## Fase C — Retrospectiva (ChatGPT)

Pegar en ChatGPT:

    Proyecto [nombre] completado. Retrospectiva.

    DATOS REALES:
    - Duracion total: [X dias]
    - Coste de cuota: [~$Y]
    - Skills usadas: [lista]
    - Skills NO usadas: [lista]
    - Pasos automatizados que funcionaron: [review, certification]
    - Pasos asistidos que fueron friccion: [cuales]
    - Fricciones nuevas: [F19, F20, ...]

    ANALISIS:
    1. Que del diseno original se cumplio?
    2. Que cambio durante la ejecucion y por que?
    3. Que skills NO se usaron aunque estaban declaradas?
    4. Que skill nueva deberia promoverse (3 usos en 2 proyectos)?
    5. Que area nueva se justifica activar tras este proyecto?
    6. Que mejora al Core V3 se justifica (solo basada en este proyecto)?
    7. Cual es el proximo proyecto ideal?

    Se honesto. No infles logros. Senala lo que fallo.

---

## Lo que NO pedir a ChatGPT

| No pidas | Por que | Alternativa |
|---|---|---|
| Revisa mi codigo | No tiene acceso al repo | run-review-step.ps1 |
| Funciona mi proyecto? | No puede verificar | Playwright + Vic |
| Cambia la arquitectura en curso | Sin State Brief no puede decidir | Claude Code /review |
| Aprueba el merge | No tiene autoridad | Vic decide |
| Registra una skill nueva | No puede tocar el Core | proxtel-skill-creator local |
| Anade un agente nuevo | No puede tocar el Core | Editas agents/ en el Core |
| Disena el area trading completa | No esta en el Core | Crear area nueva primero |

---

## Protocolo de State Brief (obligatorio)

Cada vez que ChatGPT vaya a opinar sobre un proyecto en curso, se le pega:

    STATE_BRIEF:
      proyecto: nombre
      tarea_actual: T-XXXX
      maquina: PC_o_Mac
      ultimo_resultado: PASS_FAIL_BLOCKED
      fase_actual: 1_2_3_4_5_6
      problema_observado: descripcion
      decision_requerida: pregunta

Si ChatGPT opina sin State Brief, se le responde:
"No te pedi opinion sin State Brief. Pega el brief y vuelve a preguntar."

---

## Regla final

- ChatGPT disena.
- Core V3 ejecuta.
- Vic aprueba.

Nunca cruzar los roles.
