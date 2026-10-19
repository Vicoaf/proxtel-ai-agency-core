# Arquitectura dual PC ↔ MacBook

Define cómo trabajar simultáneamente en PC Windows (máquina maestra) y MacBook
Pro (réplica de trabajo) sin perder contexto, sin corromper el repo y sin
duplicar secretos.

Documento relacionado: docs/architecture-v3.md sección 7

---

## Roles

- PC Windows = máquina maestra. C:\DEV\PROXTEL-AI-AGENCY. Autoriza merges a main.
- MacBook Pro = réplica de trabajo. ~/DEV/PROXTEL-AI-AGENCY. Puede trabajar en
  ramas task/T-XXXX-* o mac/task-T-XXXX. Una sola máquina escritora activa por
  rama (ver standards/concurrency.md). El merge a main lo autoriza Claude en el
  PC (máquina maestra).

---

## Sync

- Solo por Git (GitHub, GitLab o Gitea propio). Repo privado.
- Prohibido iCloud, Dropbox, OneDrive, Google Drive para el Core o para cualquier
  repo de cliente. Corrompen .git/, locks y permisos.
- Al abrir la Mac: git pull --rebase antes de tocar nada.
- Al cerrar la Mac: git push de la rama activa (task/* o mac/*).

---

## Secretos (fuera de Git)

- .env.example en el repo, sin valores.
- .env reales solo locales en cada máquina (en .gitignore).
- secrets/PROXTEL-KEYS.kdbx (KeePassXC) o gestor equivalente con:
  - API keys de las 3 CLIs.
  - Tokens de Git.
  - Credenciales de clientes.
  - Claves de Asterisk.
  - Accesos de producción.

- .gitignore raíz del Core debe incluir: .env, secrets/, *.kdbx, .agency-local/,
  node_modules/, vendor/.

---

## Bootstrap reproducible

- PC: bootstrap/windows-setup.ps1
- Mac: bootstrap/mac-setup.sh

Ambos deben dejar la máquina lista para clonar, autenticar las 3 CLIs y añadir
.env locales. Si un paso no se puede automatizar, se documenta en
docs/bootstrap-manual.md.

---

## Protocolo pull-first en Mac

Antes de trabajar en cualquier proyecto:

    git status --short --branch
    git switch main
    git fetch --prune origin
    git pull --ff-only origin main
    git worktree list

Si hay cambios locales pendientes, se resuelven antes de cambiar a main.

Para trabajar en una rama remota ya publicada:

    git fetch origin
    git switch --track origin/task/T-0001-api

---

## Protocolo de escritura entre máquinas

Nunca se trabaja simultáneamente sobre la misma rama desde PC y Mac. Una rama
tiene una sola máquina escritora activa.

Transferencia de control:

1. La máquina actual confirma cambios guardados, commit y push.
2. Se declara libre la rama.
3. La otra máquina hace fetch y actualiza su copia.
4. Comienza a escribir solo cuando el estado remoto coincide con el esperado.

No se usan copias manuales, sincronización de carpetas ni servicios ajenos a Git.

---

## Cuándo la Mac necesita el PC

| Escenario | Qué hacer |
|---|---|
| Misma red / casa | tailscale up en ambos, ssh pc-casa desde Mac. Builds pesados en PC vía SSH. |
| De viaje, PC encendido | Tailscale + Remote SSH. Funciona. |
| De viaje, PC apagado | Mac standalone con lo clonado. Al volver, git pull en PC. |
| Trabajo pesado y PC apagado | Reducir alcance. Solo tareas que la Mac pueda correr local. |

---

## Regla de sincronización

.agency-local/ y los worktrees nunca viajan por Git. Solo main viaja. Si una
tarea empezó en la Mac y se necesita terminar en el PC:

    # En la Mac
    git push -u origin mac/task-T-XXXX

    # En el PC
    git fetch origin
    git worktree add -b task/T-XXXX "../repo-T-XXXX" origin/mac/task-T-XXXX

---

## Recuperación y continuidad

Escenario A — PC disponible: trabajo normal. Mac se mantiene por Git.

Escenario B — PC indisponible: Mac puede continuar en ramas task/* o mac/* y
publicarlas. La integración definitiva en main se pospone hasta recuperar la PC.

Escenario C — conflicto entre máquinas: se detiene la escritura, se comparan
commits, se resuelve en rama de tarea. No se permite forzar historia.

Escenario D — auditorías perdidas: los commits permanecen, la evidencia local
no se reconstruye automáticamente. Repetir validaciones antes de certificar.
