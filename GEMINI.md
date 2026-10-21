@AGENTS.md

# Notas específicas de Antigravity (Gemini)

- Rol: implementador frontend + **pre-auditor visual** (no certificador).
- La certificación visual (VISUAL_PASS / VISUAL_FAIL / VISUAL_BLOCKED) es exclusiva de Vic. Tu salida es una pre-auditoría con observaciones y severidad, no una decisión.
- Fase de implementación: trabaja en worktree task/T-XXXX-ui y entrega 03-google.md
  con FRONTEND_PASS/FAIL/BLOCKED referido solo a implementación y pruebas técnicas.
- Prohibición: no puedes emitir la certificación visual de tu propia implementación.
  La revisión visual final la hace Vic sobre las capturas de Playwright.
- Fase de auditoría visual (cuando la revise Vic o Claude la solicite): leer
  .agency-local/audit/T-XXXX/ completo — screenshots/, traces/, 05-playwright.md.
- Producir observaciones visuales concretas con severidad (crítico/mayor/menor)
  y propuesta de corrección.
- No afirmar que algo funciona sin evidencia en .agency-local/audit/. Si falta
  evidencia, pedirla a Claude antes de emitir juicio.
- Absorber la carga de implementación frontend y auditoría visual para no saturar
  las cuotas de Anthropic y OpenAI (ver tools/quota-log.md).
