#!/usr/bin/env bash
# ==============================================================================
# sync.sh - Sincronizador de Skills Multi-IA
# Vincula suas skills ao Antigravity, Claude Code, Cursor, IntelliJ (Junie) e outros editores.
# ==============================================================================

set -e

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_PROJECT=""

# Parse de argumentos
while [[ $# -gt 0 ]]; do
  case $1 in
    --project|-p)
      TARGET_PROJECT="$2"
      shift 2
      ;;
    --help|-h)
      echo "Uso: ./sync.sh [OPÇÕES]"
      echo ""
      echo "Opções:"
      echo "  (sem argumentos)      Sincroniza globalmente no usuário (~/.gemini, ~/.claude, ~/.cursor, ~/.junie)"
      echo "  --project, -p <PATH>  Sincroniza dentro do diretório de um projeto específico (.agents/skills, .junie/skills, .cursor/rules)"
      echo "  --help, -h            Exibe esta mensagem de ajuda"
      exit 0
      ;;
    *)
      echo "Opção desconhecida: $1"
      exit 1
      ;;
  esac
done

echo "🔗 Sincronizando biblioteca de skills..."
echo "📂 Origem: $SOURCE_DIR/skills"

# Função para limpar symlinks mortos/órfãos
cleanup_broken_symlinks() {
  local target_dir="$1"
  if [ -d "$target_dir" ]; then
    for link in "$target_dir"/*; do
      if [ -L "$link" ] && [ ! -e "$link" ]; then
        rm "$link"
      fi
    done
  fi
}

# ------------------------------------------------------------------------------
# 1. Modo Projeto Específico (quando passado --project <path>)
# ------------------------------------------------------------------------------
if [ -n "$TARGET_PROJECT" ]; then
  if [ ! -d "$TARGET_PROJECT" ]; then
    echo "❌ Erro: Diretório do projeto '$TARGET_PROJECT' não encontrado."
    exit 1
  fi

  echo "🎯 Configurando para o projeto: $TARGET_PROJECT"

  # Antigravity, IntelliJ & Android Studio Workspace (.agents/skills)
  AGY_WS="$TARGET_PROJECT/.agents/skills"
  mkdir -p "$AGY_WS"
  for skill_dir in "$SOURCE_DIR"/skills/*/; do
    skill_name=$(basename "$skill_dir")
    ln -sfn "$skill_dir" "$AGY_WS/$skill_name"
  done
  cleanup_broken_symlinks "$AGY_WS"
  echo "  ✔ Workspace (.agents/skills/) configurado."

  # Android Studio Workspace (.android-studio/skills)
  AS_WS="$TARGET_PROJECT/.android-studio/skills"
  mkdir -p "$AS_WS"
  for skill_dir in "$SOURCE_DIR"/skills/*/; do
    skill_name=$(basename "$skill_dir")
    ln -sfn "$skill_dir" "$AS_WS/$skill_name"
  done
  cleanup_broken_symlinks "$AS_WS"
  echo "  ✔ Android Studio Workspace (.android-studio/skills/) configurado."

  # IntelliJ / JetBrains Junie Workspace (.junie/skills)
  INTELLIJ_WS="$TARGET_PROJECT/.junie/skills"
  mkdir -p "$INTELLIJ_WS"
  for skill_dir in "$SOURCE_DIR"/skills/*/; do
    skill_name=$(basename "$skill_dir")
    ln -sfn "$skill_dir" "$INTELLIJ_WS/$skill_name"
  done
  cleanup_broken_symlinks "$INTELLIJ_WS"
  echo "  ✔ IntelliJ / JetBrains (.junie/skills/) configurado."

  # Cursor Workspace (.cursor/rules)
  CURSOR_WS="$TARGET_PROJECT/.cursor/rules"
  mkdir -p "$CURSOR_WS"
  for skill_dir in "$SOURCE_DIR"/skills/*/; do
    skill_name=$(basename "$skill_dir")
    if [ -f "$skill_dir/SKILL.md" ]; then
      ln -sfn "$skill_dir/SKILL.md" "$CURSOR_WS/$skill_name.mdc"
    fi
  done
  cleanup_broken_symlinks "$CURSOR_WS"
  echo "  ✔ Cursor (.cursor/rules/) configurado."

  echo "🎉 Concluído com sucesso no projeto!"
  exit 0
fi

# ------------------------------------------------------------------------------
# 2. Modo Global (na máquina do desenvolvedor)
# ------------------------------------------------------------------------------

# Antigravity Global (~/.gemini/config/skills/)
AGY_GLOBAL="$HOME/.gemini/config/skills"
mkdir -p "$AGY_GLOBAL"
for skill_dir in "$SOURCE_DIR"/skills/*/; do
  skill_name=$(basename "$skill_dir")
  ln -sfn "$skill_dir" "$AGY_GLOBAL/$skill_name"
done
cleanup_broken_symlinks "$AGY_GLOBAL"
echo "  ✔ Antigravity Global ($AGY_GLOBAL) configurado."

# Android Studio Global (~/.android-studio/skills/)
ANDROID_STUDIO_GLOBAL="$HOME/.android-studio/skills"
mkdir -p "$ANDROID_STUDIO_GLOBAL"
for skill_dir in "$SOURCE_DIR"/skills/*/; do
  skill_name=$(basename "$skill_dir")
  ln -sfn "$skill_dir" "$ANDROID_STUDIO_GLOBAL/$skill_name"
done
cleanup_broken_symlinks "$ANDROID_STUDIO_GLOBAL"
echo "  ✔ Android Studio Global ($ANDROID_STUDIO_GLOBAL) configurado."

# Padrão Global .agents (~/.agents/skills/)
AGENTS_GLOBAL="$HOME/.agents/skills"
mkdir -p "$AGENTS_GLOBAL"
for skill_dir in "$SOURCE_DIR"/skills/*/; do
  skill_name=$(basename "$skill_dir")
  ln -sfn "$skill_dir" "$AGENTS_GLOBAL/$skill_name"
done
cleanup_broken_symlinks "$AGENTS_GLOBAL"
echo "  ✔ Agentes Multi-IDE Global ($AGENTS_GLOBAL) configurado."

# IntelliJ IDEA / JetBrains (Extensão Oficial Antigravity & AI Assistant)
# Escaneia diretórios de cache do JetBrains no macOS e Linux
shopt -s nullglob
JB_DIRS=(
  "$HOME/Library/Caches/JetBrains"/*/aia/agents
  "$HOME/.cache/JetBrains"/*/aia/agents
)
shopt -u nullglob

jb_configured=0
for jb_agents in "${JB_DIRS[@]}"; do
  if [ -d "$jb_agents" ]; then
    ide_label=$(basename "$(dirname "$(dirname "$jb_agents")")")
    
    # 1. Managed Skills Root (Settings -> Tools -> AI Assistant -> Skills)
    JB_MANAGED="$jb_agents/.agents/skills"
    mkdir -p "$JB_MANAGED"
    for skill_dir in "$SOURCE_DIR"/skills/*/; do
      skill_name=$(basename "$skill_dir")
      ln -sfn "$skill_dir" "$JB_MANAGED/$skill_name"
    done
    cleanup_broken_symlinks "$JB_MANAGED"

    # 2. Views / Other Root (Injetado pelo IntelliJ no Antigravity ACP)
    JB_VIEWS="$jb_agents/views/other/.agents/skills"
    mkdir -p "$JB_VIEWS"
    for skill_dir in "$SOURCE_DIR"/skills/*/; do
      skill_name=$(basename "$skill_dir")
      ln -sfn "$skill_dir" "$JB_VIEWS/$skill_name"
    done
    cleanup_broken_symlinks "$JB_VIEWS"

    echo "  ✔ IntelliJ IDEA / JetBrains ($ide_label) configurado."
    jb_configured=1
  fi
done

# IntelliJ / JetBrains Junie Global (~/.junie/skills/)
INTELLIJ_GLOBAL="$HOME/.junie/skills"
mkdir -p "$INTELLIJ_GLOBAL"
for skill_dir in "$SOURCE_DIR"/skills/*/; do
  skill_name=$(basename "$skill_dir")
  ln -sfn "$skill_dir" "$INTELLIJ_GLOBAL/$skill_name"
done
cleanup_broken_symlinks "$INTELLIJ_GLOBAL"
echo "  ✔ IntelliJ / JetBrains Junie ($INTELLIJ_GLOBAL) configurado."

# Claude Code Global (~/.claude/skills/)
CLAUDE_GLOBAL="$HOME/.claude/skills"
mkdir -p "$CLAUDE_GLOBAL"
for skill_dir in "$SOURCE_DIR"/skills/*/; do
  skill_name=$(basename "$skill_dir")
  ln -sfn "$skill_dir" "$CLAUDE_GLOBAL/$skill_name"
done
cleanup_broken_symlinks "$CLAUDE_GLOBAL"
echo "  ✔ Claude Code ($CLAUDE_GLOBAL) configurado."

# Cursor Global (~/.cursor/rules/)
CURSOR_GLOBAL="$HOME/.cursor/rules"
mkdir -p "$CURSOR_GLOBAL"
for skill_dir in "$SOURCE_DIR"/skills/*/; do
  skill_name=$(basename "$skill_dir")
  if [ -f "$skill_dir/SKILL.md" ]; then
    ln -sfn "$skill_dir/SKILL.md" "$CURSOR_GLOBAL/$skill_name.mdc"
  fi
done
cleanup_broken_symlinks "$CURSOR_GLOBAL"
echo "  ✔ Cursor Global ($CURSOR_GLOBAL) configurado."

# ------------------------------------------------------------------------------
# 3. Atualizar Catálogo Dinâmico no README.md
# ------------------------------------------------------------------------------
if [ -f "$SOURCE_DIR/scripts/update-catalog.py" ]; then
  python3 "$SOURCE_DIR/scripts/update-catalog.py"
fi

echo ""
echo "🎉 Pronto! Todas as skills foram vinculadas e o catálogo está atualizado."
