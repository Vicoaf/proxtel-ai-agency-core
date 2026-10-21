# Rollback

Procedimiento para revertir trabajo cuando algo falla durante una tarea.
Sin este documento, la recuperación es improvisada y deja deuda de contexto.

Documento relacionado: `standards/concurrency.md`, `standards/permissions.md`, `docs/architecture-v3.md` sección 2.

---

## Escenarios y procedimiento

### E1 — Codex rompió algo en `task/T-XXXX-api` antes del `/review`

**Nivel:** A (autónomo dentro del worktree).

1. Identificar el commit o commits a revertir con `git log --oneline`.
2. Revertir dentro del worktree:
   ```powershell
   cd ..\repo-T-XXXX-api
   git revert <sha>  # o git reset --hard <sha-anterior> si no hay push
