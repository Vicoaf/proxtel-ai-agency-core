@AGENTS.md

# Notas específicas de Claude Code

- Modelo por defecto: Sonnet. Usar Opus solo para arquitectura, revisión de
  seguridad o diseño de solución inicial. Para el resto, Sonnet o Haiku.
- Claude es el orquestador: planifica, delega, revisa y consolida. No implementa
  código de producción salvo tareas pequeñas de documentación.
- /review es obligatorio sobre el diff de las ramas de implementación antes de
  pasar a Playwright.
- Al cerrar cada tarea, escribir 06-certification.yaml en .agency-local/audit/T-XXXX/
  solo si todas las evidencias (01 a 05) respaldan los PASS.
- Al iniciar sesión, leer AGENTS.md + PROJECT-SKILLS.md del repo en curso.
- Nunca mergear a main sin evidencia de los 5 pasos del ciclo operativo.
- Si detectas ambigüedad de nivel de permiso, asumir Nivel B y pedir aprobación a Vic.
