# Protocolo State Brief para ChatGPT

ChatGPT no ve el repo. Para que su arquitectura no se desincronice, cada sesión
estratégica empieza con un State Brief verificable. Ver docs/architecture-v3.md
sección 4.

---

## Qué pegarle a ChatGPT al inicio de cada sesión

Opción A — Ejecutar el script completo:

- Windows: el bloque de PowerShell de docs/architecture-v3.md sección 4.1.
- Mac: el bloque de Bash de docs/architecture-v3.md sección 4.1.

Ambos generan .agency-local/briefs/STATE-BRIEF.txt con los 11 encabezados.
Copiar el contenido completo de ese archivo y pegarlo a ChatGPT.

Opción B — Comandos mínimos si no quieres script:

    git log --oneline -20
    git status
    git worktree list
    cat PROJECT-SKILLS.md 2>/dev/null || echo "(sin PROJECT-SKILLS.md)"
    cat AGENTS.md

Luego pegar además:

    STATE_BRIEF:
      proyecto: nombre
      objetivo: descripcion
      tarea_actual: T-XXXX
      maquina: PC_o_Mac
      ultimo_resultado: PASS_FAIL_BLOCKED
      fase_actual: 1_2_3_4_5
      problema_observado: descripcion
      pruebas_ejecutadas: resultados
      decision_requerida: pregunta
      archivos_relevantes: rutas
      restricciones: condiciones

Y el extracto del error o de la revisión relevante, no todos los logs.

---

## Qué decisiones puede tomar ChatGPT solo

- Propuestas comerciales y SOW.
- Elección de stack inicial de un proyecto nuevo.
- Comparación de alternativas arquitectónicas antes de escribir código.
- Redacción de especificaciones funcionales.
- Análisis de viabilidad técnica o comercial.
- Diseño de modelos de negocio.
- Prioridades y riesgos a nivel estratégico.

---

## Qué decisiones requieren Claude Code (no ChatGPT)

- Cualquier decisión que dependa de leer el código real.
- Cambios arquitectónicos en un proyecto ya en curso.
- Aprobación de merges o de cambios en main.
- Auditoría de seguridad sobre código existente.
- Cualquier operación de Nivel B (ver standards/permissions.md).
- Verificar arquitectura implementada vs. propuesta.
- Confirmar dónde aparecen los riesgos en el código.
- Ejecutar o coordinar validaciones reales.

---

## Regla dura

Si ChatGPT opina sobre el estado del repo sin State Brief, su opinión se
descarta. Se le vuelve a pedir con el brief pegado.

ChatGPT no puede declarar un PASS basándose únicamente en descripciones del
comportamiento esperado. Los PASS los escribe Claude solo con evidencia real
en .agency-local/audit/T-XXXX/.

---

## Frecuencia

- Proyecto nuevo: brief completo antes de la primera sesión.
- Proyecto en curso: brief antes de cada sesión estratégica (no en cada chat
  operativo).
- Cierre de proyecto: brief final para consolidar lecciones.

---

## Privacidad

Antes de pegar el State Brief, revisar y ocultar cualquier información
confidencial: credenciales, datos de clientes reales, claves de Asterisk,
URLs internas.
