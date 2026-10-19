# Concurrencia y worktrees

Define cómo varios agentes trabajan sobre el mismo repositorio sin pisarse.
Es la regla que evita que Claude, Codex y Antigravity escriban el mismo archivo
al mismo tiempo.

Documento relacionado: docs/architecture-v3.md sección 3

---

## Regla base

Ningún agente escribe directamente en main. Todo pasa por rama + worktree,
con merge autorizado por Vic.

---

## Estructura de worktrees

    <repo>/
    ├── .git/                          (no tocar)
    └── (working tree principal)

    ../<repo>-T-XXXX-api/              (worktree Codex, rama task/T-XXXX-api)
    ../<repo>-T-XXXX-ui/               (worktree Antigravity, rama task/T-XXXX-ui)
    ../<repo>-T-XXXX-int/              (worktree Claude, rama task/T-XXXX-int)

Los worktrees viven FUERA del directorio del repo principal, no dentro de
worktrees/. Esto es porque git worktree crea directorios hermanos, no
subdirectorios. Si prefieres tenerlos centralizados, el directorio debe
estar fuera del árbol de Git y añadido a .gitignore del Core.

---

## Quién puede escribir dónde

| Agente | worktree Codex | worktree UI | worktree int | main |
|---|---|---|---|---|
| Claude | No (solo lectura) | No (solo lectura) | Sí | Sí, merge autorizado |
| Codex | Sí | No | No | No |
| Antigravity | No | Sí | No | No |
| Playwright | No | No | Sí (solo lectura + escribe audit) | No |
| Vic | Sí | Sí | Sí | Sí |

---

## Crear un worktree para una tarea

Desde PowerShell, en la raíz del repo:

    git fetch --prune origin

    $repoName = Split-Path -Leaf (git rev-parse --show-toplevel)

    git worktree add -b task/T-0001-api "../${repoName}-T-0001-api" origin/main
    git worktree add -b task/T-0001-ui  "../${repoName}-T-0001-ui"  origin/main
    git worktree add -b task/T-0001-int "../${repoName}-T-0001-int" origin/main

    git worktree list

Al terminar la tarea y mergear, eliminar:

    git worktree remove ../<repo>-T-0001-api
    git branch -d task/T-0001-api

---

## Convención de ramas

| Rama | Propietario | Uso |
|---|---|---|
| main | Vic desde PC | Versión aprobada |
| task/T-XXXX-api | Codex | Backend e integraciones |
| task/T-XXXX-ui | Antigravity | Frontend y estilos |
| task/T-XXXX-int | Claude | Integración y revisión |
| mac/task-T-XXXX | Mac (cuando Vic viaja) | Trabajo en Mac, push, merge en PC |

No todas las tareas requieren dos ramas de implementación. Si no hay frontend,
se omite task/T-XXXX-ui. Si no hay backend, se omite task/T-XXXX-api.

---

## Reglas de bloqueo

- Nunca dos agentes editando simultáneamente el mismo worktree.
- Nunca dos ramas editando el mismo contrato compartido sin coordinación.
- Migraciones, archivos de dependencias, configuraciones globales y contratos
  API tienen un propietario único por tarea.
- Un conflicto de merge detiene la integración hasta que Claude lo resuelve.
- No se permite git push --force sobre ramas compartidas ni main.
- Los cambios fuera de alcance requieren nueva asignación de tarea.

---

## Regla de la Mac

La Mac nunca commitea a main. Trabaja en ramas mac/task-T-XXXX, hace push, y
el merge lo autoriza Claude en el PC (máquina maestra).

Detalle completo en standards/dual-machine.md.

---

## Regla de .agency-local/ y worktrees

.agency-local/ está en .gitignore del Core y de cada proyecto. Nunca se
sincroniza por Git. Es local por máquina.

Los worktrees viven fuera del árbol del repo, por lo que no necesitan
.gitignore (Git los gestiona por su cuenta con git worktree list).
