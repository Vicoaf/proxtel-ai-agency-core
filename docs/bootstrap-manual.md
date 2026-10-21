# Bootstrap manual (pasos no automatizables)

Complemento a `bootstrap/windows-setup.ps1` y `bootstrap/mac-setup.sh`.
Solo documenta lo que los scripts **no** pueden automatizar.

---

## PC Windows

1. Instalar Laravel Herd y TablePlus manualmente.
2. Instalar KeePassXC y crear `secrets/PROXTEL-KEYS.kdbx` con:
   - API keys de Claude, Codex, Antigravity.
   - Tokens de Git.
   - Credenciales de clientes.
   - Claves de Asterisk.
3. Autenticar las 3 CLIs (una vez por máquina):
   - `claude login`
   - `codex login`
   - `agy login`
4. Verificar: `claude --version`, `codex --version`, `agy --version`.
5. Crear `.env` locales en cada proyecto (nunca en el Core).

---

## MacBook

1. Instalar Homebrew, VS Code, Git.
2. Instalar KeePassXC y descifrar el mismo `.kdbx` (nunca sincronizar por nube).
3. Autenticar las 3 CLIs (mismo comando que en Windows).
4. Verificar versiones.
5. Crear `.env` locales.

---

## Regla

Si un paso no está aquí ni en los scripts, **no inventes un tercer método**. Añádelo a este documento después de probarlo.
