# PROXTEL AI Agency — Plan de certificación del piloto V3 y hoja de ruta de la semana 2

**Documento:** V3-PILOT-CERTIFICATION-WEEK2
**Versión:** 1.0 — Plan propuesto
**Fecha:** 19 de octubre de 2026
**Responsable de aceptación:** Vic (CEO)
**Fuente:** `docs/lessons/pilot-day4-5.md`
**Alcance:** Piloto T-0001, controles operativos V3, certificación del adapter Claude y preparación de incorporación de proyectos reales.

---

# PARTE I — PLAN DE CERTIFICACIÓN DEL PILOTO V3

## 1. Objetivo

Certificar documental y operativamente que el ciclo V3 puede ejecutarse de forma repetible, controlada y auditable, preservando la separación de responsabilidades y sin introducir cambios arquitectónicos.

Se distinguen tres decisiones independientes:

1. **Certificación del ciclo asistido:** el piloto T-0001 reporta los cinco gates superados y aceptación humana completada.
2. **Certificación de la ejecución programática:** pendiente mientras el adapter de Claude permanezca en `candidate / not-executed`.
3. **Autorización de merge:** decisión humana independiente, sujeta a la conciliación del commit registrado y las evidencias Git.

La aprobación de una dimensión no equivale a la aprobación automática de las otras.

## 2. Línea base certificable

| Elemento | Estado documentado |
|---|---|
| Proyecto | `piloto-v3` |
| Tipo | Landing HTML/CSS/JS vanilla, descartable |
| Worktree de integración | `C:\DEV\piloto-v3-T-0001-int` |
| Rama | `task/T-0001-int` |
| Ejecución | Asistida, Vic lanzó las CLIs |
| Gates del ciclo | 5/5 aprobados |
| Review de Claude | 7 hallazgos en PASS |
| QA navegador | 0 errores de consola, 0 requests fallidos |
| Archivos fuera de alcance | 0 |
| Dependencias externas del proyecto | 0 |
| Fricciones operativas | 8; ninguna impidió completar el ciclo asistido |
| Duración | Aproximadamente 4 horas |
| Intervenciones de Vic | Aproximadamente 45 comandos |
| Certificado del piloto | `06-certification.yaml` |
| Estado del certificado | `READY_FOR_MERGE_AUTHORIZATION` |
| Adapter Claude | `candidate / not-executed` |

La documentación también declara `CERTIFIED`, pero la aceptación de esa declaración como certificación independiente requiere inspeccionar los artefactos originales. El archivo de lecciones no sustituye los seis documentos de auditoría.

## 3. Matriz de certificación

| ID | Control | Evidencia exigida | Situación |
|---|---|---|---|
| C01 | Plan | `01-plan.md` íntegro, con alcance y criterios verificables | PASS reportado |
| C02 | Implementación | Diferencias Git y archivos dentro del alcance autorizado | PASS reportado |
| C03 | Revisión independiente | Reporte `/review`, siete hallazgos PASS | PASS reportado |
| C04 | QA | Screenshots 1440, 768 y 390 px, DOM, resultados de consola y red | PASS reportado |
| C05 | Aceptación humana | `VISUAL_PASS` de Vic | PASS reportado |
| C06 | Integridad documental | Seis documentos de auditoría, consistentes y verificables | Verificación documental pendiente |
| C07 | Controles de pre-vuelo | Pruebas positivas y negativas de integridad, ubicación y disponibilidad | Pendiente |
| C08 | Adapter Claude | Pruebas no interactivas, trazas y certificado independiente | Pendiente |
| C09 | Estado del merge | Conciliación entre SHA, padres del commit, rama y autorización | Pendiente |
| C10 | Regresión controlada | Nuevo ciclo que confirme que las correcciones no introducen fallos | Pendiente |

**Interpretación:** C01–C05 son resultados reportados del piloto completado. C06–C10 son controles de cierre y de preparación de la semana 2. No se utilizarán para invalidar retrospectivamente el piloto asistido, pero sí para decidir si la agencia puede avanzar a ejecución automatizada y proyectos reales.

## 4. Procedimiento de certificación

### Fase A — Congelar y verificar evidencias

**Responsables:** Claude Code (revisión), Vic (validación).

Acciones:

- Confirmar los seis documentos de `.agency-local/audit/T-0001/`.
- Comprobar que contienen información completa, son legibles y mantienen coherencia entre sí.
- Verificar el alcance autorizado frente al diff de implementación.
- Confirmar que los screenshots y el DOM proceden del worktree de integración.
- Registrar los hashes de los artefactos para fijar una línea base inmutable de referencia.
- Conciliar el estado de `06-certification.yaml` con el historial Git.

**Punto crítico:** `a41a2e7af2644455ef211b9c068ac014987258f2` aparece como commit de merge en el informe. Se debe verificar si existe, si es efectivamente un merge, qué ramas alcanza y si hubo autorización previa.

Si el merge ya ocurrió, no ejecutar otro ni revertirlo automáticamente: documentar el hecho y verificar la autorización correspondiente. Si no ocurrió, mantener `READY_FOR_MERGE_AUTHORIZATION`.

**Criterio de salida:** evidencia íntegra, trazabilidad completa y estado Git sin contradicciones pendientes.

### Fase B — Certificar controles preventivos

**Implementación:** Codex CLI.
**Revisión:** Claude Code.
**Aceptación:** Vic.

Introducir controles únicamente en los scripts y estándares existentes:

- F1: verificar contenido, estructura y tamaño esperado de `PROJECT-SKILLS.md`. `Length > 0` por sí solo no es suficiente para detectar una truncación de 18 bytes.
- F2: establecer que Claude Code escriba archivos largos mediante `Write`, evitando copiar stdout corrupto en Windows.
- F3: adoptar métodos de conteo validados para PowerShell; evitar la combinación problemática observada y probar expresiones con múltiples coincidencias.
- F4: documentar `C:\DEV\_piloto-tools\` como ubicación externa de utilidades de QA, sin incorporarlas como dependencias del proyecto.
- F5: comprobar worktree, directorio y rama antes de generar evidencias; fallar si difieren del contexto autorizado.
- F6: comprobar que `http://localhost:8000/` responde correctamente antes de ejecutar la captura.
- F8: documentar `Get-Content -Encoding UTF8` y tratar el síntoma de codificación como una cuestión de visualización, no como corrupción comprobada de los archivos.

Cada protección deberá probar que **acepta el estado correcto y rechaza el estado incorrecto**. No bastará con añadir una advertencia.

**Criterio de salida:** controles operativos verificados, sin alterar el contrato funcional del ciclo V3.

### Fase C — Certificación del adapter Claude

**Prioridad:** crítica para automatización.
**Estimación de referencia:** 4–6 horas de trabajo técnico, según el informe del piloto.

**Implementación de pruebas:** Codex CLI.
**Revisión:** Claude Code.
**Validación y autorización:** Vic.

Conservar `adapters/claude/adapter.json` en estado `candidate / not-executed` durante las pruebas.

Se utilizará el contrato y el esquema existentes del adapter para construir un harness en una ubicación como:

`tests/integration/provider-adapters/claude/`

La ubicación definitiva y el identificador de certificación se tomarán de las convenciones existentes; no se inventará una nueva área.

**Pruebas mínimas:**

1. Invocación no interactiva satisfactoria bajo el contrato real del adapter.
2. Manejo verificable de salida y código de terminación.
3. Captura de errores y fallos de invocación.
4. Respeto del directorio, contexto y alcance autorizados.
5. Registro de evidencias sin exposición de secretos.
6. Manejo controlado de cancelaciones o tiempos de espera, conforme al contrato existente.
7. Repetición de la ejecución con resultados trazables.
8. Comprobación de que la integración no omite los gates de revisión, QA ni aceptación humana.

**Certificado exigido:** un JSON formal de certificación, con el identificador de área aplicable, resultados, evidencias, versión del adapter y decisión.

Solo con todas las pruebas obligatorias aprobadas y la autorización de Vic podrá actualizarse el estado del adapter a `approved`, si ese es el valor admitido por el registro canónico.

Si falla una prueba obligatoria, el adapter conserva su estado actual y la agencia continúa en modo asistido.

### Fase D — Regresión integral del ciclo V3

Con las protecciones aprobadas y, para probar la ruta programática, el adapter certificado, ejecutar una regresión controlada sobre el piloto descartable o una tarea de prueba equivalente.

Preservar exactamente la separación existente:

- Claude Code: planificación, orquestación y revisión.
- Codex CLI: implementación backend o cambios técnicos asignados.
- Antigravity: implementación frontend.
- Playwright MCP: QA de navegador.
- Vic: evaluación visual, autorización y aceptación final.

El implementador no audita su propio trabajo. La automatización de ejecución no automatiza la aceptación humana.

**Criterio de salida:** cinco gates nuevamente verificables, cero cambios fuera de alcance y evidencia completa. Las métricas de duración e intervenciones manuales se compararán contra las cuatro horas y los aproximadamente 45 comandos del piloto original, sin convertir esos valores aproximados en garantías.

### Fase E — Dictamen y autorización

El cierre debe registrar separadamente:

| Decisión | Posibles resultados |
|---|---|
| Piloto asistido T-0001 | Certificación corroborada / evidencia insuficiente |
| Controles operativos | Aprobados / pendientes |
| Adapter Claude | Aprobado / continúa candidate |
| Regresión programática | PASS / FAIL / no ejecutada |
| Merge | Autorizado / pendiente / previamente ejecutado y conciliado |
| Incorporación de proyectos reales | Autorizada / bloqueada |

El dictamen debe incluir evidencia referenciada, responsable y fecha. Ninguna actualización a `approved`, ejecución de merge o migración se infiere de un PASS en otro apartado.

---

# PARTE II — HOJA DE RUTA DE LA SEMANA 2

## 5. Objetivo de la semana

Pasar de un **piloto V3 exitoso en modo asistido** a una operación verificable y preparada para automatización, sin perder seguridad, independencia de repositorios ni control humano.

El orden obligatorio será:

**Conciliación documental → Controles preventivos → Certificación Claude → Regresión → Decisión de incorporación.**

Los días D1–D5 representan jornadas de trabajo y no fechas de calendario fijadas.

## 6. Plan operativo

| Día | Actividad principal | Responsable operativo | Entregable |
|---|---|---|---|
| D1 | Verificación del piloto y conciliación del merge | Claude + Vic | Línea base y estado Git conciliados |
| D2 | Corrección de fricciones F1–F6 y documentación F8 | Codex; review Claude | Controles, estándares y pruebas |
| D3 | Harness y smoke tests del adapter Claude | Codex; review Claude; aceptación Vic | Resultados y decisión de certificación |
| D4 | Regresión integral V3 con la ruta aprobada | CLIs según rol + Playwright + Vic | Evidencias de regresión y dictamen |
| D5 | Go/No-Go e incorporación progresiva de proyectos | Vic; Claude coordina | Autorización y plan por repositorio |

La estimación de 4–6 horas del adapter es solo una referencia del informe, no una fecha garantizada. Si D3 no logra PASS, no se omiten controles para preservar el calendario.

## 7. Entregables por jornada

### D1 — Cierre documental del piloto

**Prioridad P0**

- Inventario de evidencias y verificación de integridad.
- Revisión de los cinco gates registrados.
- Conciliación del commit `a41a2e7`.
- Identificación explícita de evidencias ausentes, si las hubiera.
- Registro del estado real del piloto y del merge.

**PASS:** no quedan contradicciones documentales sin resolver.

### D2 — Endurecimiento operativo

**Prioridad P0 para F1, F5 y F6; P1 para F2, F3 y F4; P2 para F8.**

Entregables previstos:

- Verificaciones de integridad de archivos.
- Guardas de worktree y rama.
- Health check del servidor de pruebas.
- Actualización de `AGENTS.md` para la escritura segura de Claude en Windows.
- Actualización de `standards/qa-handoff.md`.
- Actualización del `README.md` del Core con la ubicación de herramientas ya utilizadas.
- Registro de los procedimientos PowerShell y UTF-8.

**PASS:** pruebas de rechazo y aceptación correctas, revisión independiente aprobada y ausencia de regresiones.

### D3 — Adapter Claude

**Prioridad P0**

- Harness basado en el adapter existente.
- Pruebas no interactivas y negativas.
- Evidencias de ejecución.
- Review independiente.
- Dictamen formal del adapter.

**PASS:** pruebas obligatorias completas y autorización de Vic para el cambio de estado.

**FAIL:** conservar `candidate / not-executed`, registrar la causa y mantener el procedimiento manual. No promover el adapter por el simple hecho de haber creado el harness.

### D4 — Regresión V3

**Prioridad P0, condicionada a D2 y D3.**

- Validar la ejecución permitida por el adapter.
- Comprobar que planificación, implementación, review, QA y aceptación respetan sus responsables.
- Obtener capturas y evidencia DOM desde el worktree correcto.
- Validar que la generación y conservación de evidencias no dependen del directorio accidental de la terminal.
- Registrar duración, comandos/intervenciones y cualquier nueva fricción.
- Obtener aceptación humana independiente.

**PASS:** ciclo completo verificable sin nuevos errores críticos, sin archivos fuera de alcance y con aceptación real de Vic.

Si D3 no fue aprobado, D4 podrá usarse para validar las correcciones en modo asistido, pero ese resultado **no certificará la ruta programática**.

### D5 — Decisión de incorporación a proyectos reales

**Prioridad condicionada al dictamen.**

Proyectos candidatos:

1. `i-Tkt`: preparar su incorporación como proyecto web real.
2. `TRDStation`: preparar su incorporación independiente, preservando sus controles de mayor criticidad.

Cada cliente conserva repositorio, configuración, tareas, worktrees y evidencias propios. El Core V3 no debe mezclar código o secretos de un cliente con los de otro.

La incorporación será progresiva. Primero se comprobará la preparación del repositorio y el primer ciclo controlado; no se interpretará como autorización de despliegue a producción ni como migración masiva.

**GO:** adapter certificado, controles aprobados, regresión PASS y autorización de Vic.

**NO-GO:** cualquier bloqueo obligatorio pendiente. Se permite inventario y preparación documental, pero no activar el nuevo flujo programático en repositorios reales.

---

## 8. Tratamiento de las ocho fricciones

| ID | Severidad operativa propuesta | Acción de semana 2 | Prueba de cierre |
|---|---|---|---|
| F1 | Alta | Verificación estructural de `PROJECT-SKILLS.md` | Detecta archivo truncado |
| F2 | Media | Regla de escritura directa con `Write` | Archivo largo íntegro en disco |
| F3 | Media | Método PowerShell de conteo validado | Recuento correcto en caso de prueba |
| F4 | Media | Formalizar directorio externo de utilidades | QA ejecutable sin contaminar el proyecto |
| F5 | Alta | Verificación bloqueante de worktree y rama | Rechaza worktree incorrecto |
| F6 | Alta | Health check antes de captura | Rechaza servidor no disponible |
| F7 | Crítica para automatización | Certificación formal del adapter Claude | Pruebas PASS y autorización |
| F8 | Baja | Convención de lectura UTF-8 | Lectura correcta y diagnóstico documentado |

Estas severidades son una priorización para el plan, no clasificaciones originales de la fuente. F7 no impidió terminar el piloto asistido; sí impide certificar la automatización completa.

## 9. Responsabilidades invariables

| Participante | Función durante la semana 2 |
|---|---|
| **Vic** | CEO, decisiones GO/NO-GO, aceptación visual, autorización del adapter y merge |
| **Claude Code** | Orquestación dentro de las capacidades certificadas, planificación y revisión independiente |
| **Codex CLI** | Implementación técnica de controles, scripts y pruebas del adapter |
| **Antigravity** | Implementación frontend cuando corresponda; no audita su propio trabajo |
| **Playwright MCP** | QA de navegador, validación visual técnica y evidencia |
| **ChatGPT** | Arquitectura estratégica, plan de certificación y evaluación documental, sin asumir acceso al repositorio |

No se crean agentes, roles, herramientas ni capas adicionales.

## 10. Indicadores para el cierre semanal

| Indicador | Objetivo |
|---|---|
| Fricciones F1–F8 | Todas cerradas o con excepción explícita y justificada |
| Controles críticos F1/F5/F6 | 100% de pruebas obligatorias PASS |
| Adapter Claude | Certificación formal o bloqueo explícito |
| Gates de regresión | 5/5 PASS si se ejecuta la regresión completa |
| Archivos fuera de alcance | 0 |
| Evidencias en worktree incorrecto | 0 |
| Errores de consola y requests fallidos en QA | 0 |
| Aceptación humana | Obligatoria, no delegada |
| Estado de merge | Conciliado, con autorización trazable |
| Métricas de eficiencia | Comparación documentada con la línea base asistida |

No se fijará un porcentaje arbitrario de ahorro de tiempo antes de medir una regresión comparable.

## 11. Riesgos y decisiones de contingencia

**Adapter no certificado:** mantener la operación manual. No elevar permisos ni cambiar estados para sortear el bloqueo.

**Evidencia documental incompleta:** no declarar corroborada la certificación independiente hasta recuperarla y verificarla.

**Merge previamente ejecutado:** registrar el estado y conciliar la autorización; no ejecutar un segundo merge ni revertir automáticamente.

**Fallo de worktree, servidor o integridad:** detener el paso afectado, corregir la condición y repetir la prueba; no fabricar ni reutilizar evidencias inválidas.

**Regresión fallida:** conservar el piloto asistido como referencia y mantener bloqueada la activación programática en clientes reales.

**Retraso en la semana 2:** priorizar certificación y controles antes que incorporación de proyectos.

---

# PARTE III — CRITERIOS DE CIERRE Y DICTAMEN

## 12. Condiciones de éxito de la semana 2

La semana 2 se considerará **completada con autorización para incorporación progresiva** únicamente cuando:

1. Las evidencias del piloto estén corroboradas y el estado del merge conciliado.
2. Los controles preventivos críticos estén probados.
3. El adapter Claude esté certificado formalmente.
4. La regresión programática correspondiente haya aprobado sus cinco gates.
5. Vic haya autorizado expresamente avanzar con repositorios reales.

En caso contrario, se documentará qué actividades sí quedaron certificadas y cuáles permanecen pendientes. No se utilizará la etiqueta de éxito completo para ocultar condiciones no satisfechas.

## 13. Dictamen inicial al 19 de octubre de 2026

**T-0001 — Piloto asistido:** completado y declarado CERTIFIED por su documentación; corroboración independiente de artefactos originales pendiente.

**Integridad funcional reportada:** cinco gates aprobados, cero errores de consola, cero requests fallidos y cero archivos fuera de alcance.

**Fricciones:** ocho documentadas, con mitigaciones aplicadas durante el piloto y acciones preventivas propuestas para semana 2.

**Adapter Claude:** no certificado; estado `candidate / not-executed`.

**Automatización end-to-end:** no certificada.

**Merge:** estado por conciliar entre el SHA registrado y `READY_FOR_MERGE_AUTHORIZATION`.

**Migración de i-Tkt y TRDStation:** condicionada a los gates de la semana 2; no autorizada por este documento.

## 14. Recomendación de aprobación del plan

Se recomienda **aprobar el presente plan de trabajo de la semana 2**, sin que esa aprobación constituya:

- Certificación anticipada del adapter Claude.
- Autorización automática de merge.
- Autorización de despliegue en producción.
- Declaración de que los controles aún pendientes ya pasaron.
- Permiso para omitir la aceptación humana.

**Decisión reservada a Vic:** aprobación del plan, seguida de autorizaciones individuales sustentadas por evidencia.

---

**Resultado esperado:** PROXTEL AI Agency conserva su arquitectura V3 y transforma las lecciones del piloto T-0001 en controles reproducibles. La prioridad no es añadir complejidad, sino certificar la ruta programática existente y mantener la misma disciplina de revisión, QA y aceptación humana demostrada en el piloto asistido.
