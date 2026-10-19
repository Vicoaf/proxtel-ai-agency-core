#!/usr/bin/env bash
# =====================================================================
# PROXTEL AI AGENCY - Bootstrap para macOS
# Preparación y verificación del entorno de la agencia.
# Idempotente: se puede ejecutar múltiples veces sin romper nada.
# Uso: en la raíz del Core:
#   chmod +x bootstrap/mac-setup.sh
#   ./bootstrap/mac-setup.sh
# =====================================================================

set -e
set -o pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}===============================================${NC}"
echo -e "${CYAN} PROXTEL AI AGENCY - Bootstrap macOS${NC}"
echo -e "${CYAN}===============================================${NC}"
echo ""

# ---------- Verificar que estamos en la raíz del Core ----------

EXPECTED_ROOT="$HOME/DEV/PROXTEL-AI-AGENCY"
CURRENT_ROOT="$(pwd)"

if [ "$CURRENT_ROOT" != "$EXPECTED_ROOT" ]; then
    echo -e "${YELLOW}AVISO: No estás en $EXPECTED_ROOT${NC}"
    echo -e "${YELLOW}       Estás en: $CURRENT_ROOT${NC}"
    read -p "¿Continuar de todos modos? (s/n) " response
    if [ "$response" != "s" ]; then
        echo -e "${RED}Cancelado por el usuario.${NC}"
        exit 1
    fi
fi

# ---------- Verificar Homebrew ----------

echo -e "${YELLOW}[1/8] Verificando Homebrew...${NC}"

if command -v brew >/dev/null 2>&1; then
    echo -e "${GREEN}  OK: Homebrew $(brew --version | head -n1)${NC}"
else
    echo -e "${RED}  ERROR: Homebrew no instalado.${NC}"
    echo -e "${RED}  Instalar desde: https://brew.sh${NC}"
    exit 1
fi

# ---------- Verificar Git ----------

echo -e "${YELLOW}[2/8] Verificando Git...${NC}"

if command -v git >/dev/null 2>&1; then
    echo -e "${GREEN}  OK: $(git --version)${NC}"
else
    echo -e "${RED}  ERROR: Git no instalado.${NC}"
    echo -e "${RED}  Instalar con: brew install git${NC}"
    exit 1
fi

# ---------- Verificar Node.js ----------

echo -e "${YELLOW}[3/8] Verificando Node.js...${NC}"

if command -v node >/dev/null 2>&1; then
    echo -e "${GREEN}  OK: Node $(node --version)${NC}"
else
    echo -e "${RED}  ERROR: Node.js no instalado.${NC}"
    echo -e "${RED}  Instalar con: brew install node${NC}"
    exit 1
fi

if command -v npm >/dev/null 2>&1; then
    echo -e "${GREEN}  OK: npm $(npm --version)${NC}"
else
    echo -e "${RED}  ERROR: npm no encontrado.${NC}"
    exit 1
fi

# ---------- Verificar PHP y Composer ----------

echo -e "${YELLOW}[4/8] Verificando PHP y Composer...${NC}"

if command -v php >/dev/null 2>&1; then
    echo -e "${GREEN}  OK: PHP $(php -r 'echo PHP_VERSION;')${NC}"
else
    echo -e "${YELLOW}  AVISO: PHP no instalado (necesario para proyectos Laravel).${NC}"
    echo -e "${YELLOW}  Instalar: brew install php${NC}"
fi

if command -v composer >/dev/null 2>&1; then
    echo -e "${GREEN}  OK: Composer $(composer --version 2>&1 | head -n1 | sed 's/Composer version //')${NC}"
else
    echo -e "${YELLOW}  AVISO: Composer no instalado.${NC}"
    echo -e "${YELLOW}  Instalar: brew install composer${NC}"
fi

# ---------- Verificar las 3 CLIs de IA ----------

echo -e "${YELLOW}[5/8] Verificando CLIs de IA...${NC}"

# Claude Code
if command -v claude >/dev/null 2>&1; then
    echo -e "${GREEN}  OK: Claude Code instalado${NC}"
else
    echo -e "${YELLOW}  AVISO: Claude Code no instalado.${NC}"
    echo -e "${YELLOW}  Instalar con: npm install -g @anthropic-ai/claude-code${NC}"
fi

# Codex CLI
if command -v codex >/dev/null 2>&1; then
    echo -e "${GREEN}  OK: Codex CLI instalado${NC}"
else
    echo -e "${YELLOW}  AVISO: Codex CLI no instalado.${NC}"
    echo -e "${YELLOW}  Instalar con: npm install -g @openai/codex${NC}"
fi

# Antigravity
if command -v agy >/dev/null 2>&1 || command -v antigravity >/dev/null 2>&1; then
    echo -e "${GREEN}  OK: Antigravity CLI instalado${NC}"
else
    echo -e "${YELLOW}  AVISO: Antigravity no encontrado.${NC}"
    echo -e "${YELLOW}  Instalar desde su instalador oficial (no vía npm).${NC}"
fi

# ---------- Crear symlinks de archivos de configuración ----------

echo -e "${YELLOW}[6/8] Configurando archivos globales de CLIs...${NC}"

# Claude Code: ~/.claude/CLAUDE.md
CLAUDE_DIR="$HOME/.claude"
mkdir -p "$CLAUDE_DIR"

CLAUDE_GLOBAL="$CLAUDE_DIR/CLAUDE.md"
CLAUDE_SOURCE="$CURRENT_ROOT/CLAUDE.md"

if [ -L "$CLAUDE_GLOBAL" ]; then
    echo -e "${YELLOW}  AVISO: $CLAUDE_GLOBAL ya es un symlink.${NC}"
    read -p "  ¿Recrear? (s/n) " resp
    if [ "$resp" = "s" ]; then
        rm "$CLAUDE_GLOBAL"
        ln -s "$CLAUDE_SOURCE" "$CLAUDE_GLOBAL"
        echo -e "${GREEN}  OK: symlink CLAUDE.md recreado${NC}"
    fi
elif [ -f "$CLAUDE_GLOBAL" ]; then
    echo -e "${YELLOW}  AVISO: $CLAUDE_GLOBAL existe como archivo.${NC}"
    read -p "  ¿Reemplazar con symlink al Core? (s/n) " resp
    if [ "$resp" = "s" ]; then
        mv "$CLAUDE_GLOBAL" "$CLAUDE_GLOBAL.bak.$(date +%Y%m%d%H%M%S)"
        ln -s "$CLAUDE_SOURCE" "$CLAUDE_GLOBAL"
        echo -e "${GREEN}  OK: symlink CLAUDE.md -> $CLAUDE_GLOBAL (backup guardado)${NC}"
    fi
else
    ln -s "$CLAUDE_SOURCE" "$CLAUDE_GLOBAL"
    echo -e "${GREEN}  OK: symlink CLAUDE.md -> $CLAUDE_GLOBAL${NC}"
fi

# Antigravity: ~/.gemini/GEMINI.md
GEMINI_DIR="$HOME/.gemini"
mkdir -p "$GEMINI_DIR"

GEMINI_GLOBAL="$GEMINI_DIR/GEMINI.md"
GEMINI_SOURCE="$CURRENT_ROOT/GEMINI.md"

if [ -L "$GEMINI_GLOBAL" ]; then
    echo -e "${YELLOW}  AVISO: $GEMINI_GLOBAL ya es un symlink.${NC}"
    read -p "  ¿Recrear? (s/n) " resp
    if [ "$resp" = "s" ]; then
        rm "$GEMINI_GLOBAL"
        ln -s "$GEMINI_SOURCE" "$GEMINI_GLOBAL"
        echo -e "${GREEN}  OK: symlink GEMINI.md recreado${NC}"
    fi
elif [ -f "$GEMINI_GLOBAL" ]; then
    echo -e "${YELLOW}  AVISO: $GEMINI_GLOBAL existe como archivo.${NC}"
    read -p "  ¿Reemplazar con symlink al Core? (s/n) " resp
    if [ "$resp" = "s" ]; then
        mv "$GEMINI_GLOBAL" "$GEMINI_GLOBAL.bak.$(date +%Y%m%d%H%M%S)"
        ln -s "$GEMINI_SOURCE" "$GEMINI_GLOBAL"
        echo -e "${GREEN}  OK: symlink GEMINI.md -> $GEMINI_GLOBAL (backup guardado)${NC}"
    fi
else
    ln -s "$GEMINI_SOURCE" "$GEMINI_GLOBAL"
    echo -e "${GREEN}  OK: symlink GEMINI.md -> $GEMINI_GLOBAL${NC}"
fi

# ---------- Verificar Playwright MCP ----------

echo -e "${YELLOW}[7/8] Verificando Playwright MCP...${NC}"

if command -v npx >/dev/null 2>&1; then
    if npx playwright --version >/dev/null 2>&1; then
        echo -e "${GREEN}  OK: Playwright disponible ($(npx playwright --version))${NC}"
    else
        echo -e "${YELLOW}  AVISO: Playwright no instalado globalmente.${NC}"
        echo -e "${YELLOW}  Se instala por proyecto: npm install --save-dev @playwright/test${NC}"
    fi
else
    echo -e "${YELLOW}  AVISO: npx no encontrado.${NC}"
fi

# ---------- Verificar configuración de Git ----------

echo -e "${YELLOW}[8/8] Verificando configuración de Git...${NC}"

GIT_USER="$(git config --global user.name 2>/dev/null || true)"
GIT_EMAIL="$(git config --global user.email 2>/dev/null || true)"

if [ -n "$GIT_USER" ]; then
    echo -e "${GREEN}  OK: git user.name = $GIT_USER${NC}"
else
    echo -e "${YELLOW}  AVISO: git user.name no configurado.${NC}"
    echo -e "${YELLOW}  Ejecutar: git config --global user.name \"Tu Nombre\"${NC}"
fi

if [ -n "$GIT_EMAIL" ]; then
    echo -e "${GREEN}  OK: git user.email = $GIT_EMAIL${NC}"
else
    echo -e "${YELLOW}  AVISO: git user.email no configurado.${NC}"
    echo -e "${YELLOW}  Ejecutar: git config --global user.email \"tu@email.com\"${NC}"
fi

# ---------- Resumen final ----------

echo ""
echo -e "${CYAN}===============================================${NC}"
echo -e "${CYAN} Bootstrap macOS completado${NC}"
echo -e "${CYAN}===============================================${NC}"
echo ""
echo -e "${YELLOW}Siguiente paso manual:${NC}"
echo -e "  1. Si alguna CLI no está instalada, seguir las instrucciones arriba."
echo -e "  2. Autenticar cada CLI por primera vez:"
echo -e "     - claude  (sigue el flujo de login)"
echo -e "     - codex   (sigue el flujo de login)"
echo -e "     - agy     (sigue el flujo de login)"
echo -e "  3. Verificar que los .env de cada proyecto existan localmente."
echo -e "  4. Verificar acceso a los repos de clientes con: git ls-remote <repo>"
echo ""
echo -e "${YELLOW}Cuando todo esté verde, ejecutar el State Brief de prueba:${NC}"
echo -e "  cd <repo-de-prueba>"
echo -e "  (seguir el script de docs/architecture-v3.md sección 4.1)"
echo ""
