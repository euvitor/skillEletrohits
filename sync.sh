#!/usr/bin/env bash
# ==============================================================================
# sync.sh - Sincronizador de Skills Multi-IA (por Álbuns)
# Vincula suas skills ao Antigravity, Android Studio, IntelliJ, Claude Code, Cursor e Junie.
# ==============================================================================

set -e

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_PROJECT=""
ALBUM_FILTER=""

# Parse de argumentos
while [[ $# -gt 0 ]]; do
  case $1 in
    --project|-p)
      TARGET_PROJECT="$2"
      shift 2
      ;;
    --album|-a)
      ALBUM_FILTER="$2"
      shift 2
      ;;
    --help|-h)
      echo "Uso: ./sync.sh [OPÇÕES]"
      echo ""
      echo "Opções:"
      echo "  (sem argumentos)      Sincroniza todos os álbuns globalmente (~/.gemini, ~/.android-studio, ~/.agents, IntelliJ, ~/.junie, ~/.claude, ~/.cursor)"
      echo "  --album, -a <ALBUM>   Sincroniza apenas um álbum específico (ex: vol-1, vol-2, vol-1-core)"
      echo "  --project, -p <PATH>  Sincroniza dentro de um projeto específico (.agents/skills, .android-studio/skills, .junie/skills, .cursor/rules)"
      echo "  --help, -h            Exibe esta mensagem de ajuda"
      exit 0
      ;;
    *)
      echo "Opção desconhecida: $1"
      exit 1
      ;;
  esac
done

# Resolver álbuns selecionados
shopt -s nullglob
ALBUM_DIRS=()
for album_path in "$SOURCE_DIR"/skills/*/; do
  album_name=$(basename "$album_path")
  if [ -z "$ALBUM_FILTER" ] || [ "$album_name" = "$ALBUM_FILTER" ] || [[ "$album_name" == "$ALBUM_FILTER"-* ]]; then
    ALBUM_DIRS+=("$album_path")
  fi
done
shopt -u nullglob

if [ ${#ALBUM_DIRS[@]} -eq 0 ]; then
  echo "❌ Erro: Nenhum álbum encontrado para o filtro '$ALBUM_FILTER'."
  exit 1
fi

echo "🔗 Sincronizando biblioteca de skills..."
echo "📂 Origem: $SOURCE_DIR/skills"
if [ -n "$ALBUM_FILTER" ]; then
  echo "💿 Álbum filtrado: $ALBUM_FILTER"
fi

# Limpa symlinks mortos/órfãos
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

# Cria symlinks planos das skills dos álbuns selecionados em um diretório alvo
sync_skills_to() {
  local target_dir="$1"
  mkdir -p "$target_dir"
  shopt -s nullglob
  for album_dir in "${ALBUM_DIRS[@]}"; do
    for skill_dir in "$album_dir"*/; do
      if [ -f "$skill_dir/SKILL.md" ]; then
        skill_name=$(basename "$skill_dir")
        ln -sfn "$skill_dir" "$target_dir/$skill_name"
      fi
    done
  done
  shopt -u nullglob
  cleanup_broken_symlinks "$target_dir"
}

# Cria symlinks .mdc para Cursor
sync_cursor_to() {
  local target_dir="$1"
  mkdir -p "$target_dir"
  shopt -s nullglob
  for album_dir in "${ALBUM_DIRS[@]}"; do
    for skill_dir in "$album_dir"*/; do
      if [ -f "$skill_dir/SKILL.md" ]; then
        skill_name=$(basename "$skill_dir")
        ln -sfn "$skill_dir/SKILL.md" "$target_dir/$skill_name.mdc"
      fi
    done
  done
  shopt -u nullglob
  cleanup_broken_symlinks "$target_dir"
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

  sync_skills_to "$TARGET_PROJECT/.agents/skills"
  echo "  ✔ Workspace (.agents/skills/) configurado."

  sync_skills_to "$TARGET_PROJECT/.android-studio/skills"
  echo "  ✔ Android Studio Workspace (.android-studio/skills/) configurado."

  sync_skills_to "$TARGET_PROJECT/.junie/skills"
  echo "  ✔ IntelliJ / JetBrains (.junie/skills/) configurado."

  sync_cursor_to "$TARGET_PROJECT/.cursor/rules"
  echo "  ✔ Cursor (.cursor/rules/) configurado."

  echo "🎉 Concluído com sucesso no projeto!"
  exit 0
fi

# ------------------------------------------------------------------------------
# 2. Modo Global (na máquina do desenvolvedor)
# ------------------------------------------------------------------------------

AGY_GLOBAL="$HOME/.gemini/config/skills"
sync_skills_to "$AGY_GLOBAL"
echo "  ✔ Antigravity Global ($AGY_GLOBAL) configurado."

ANDROID_STUDIO_GLOBAL="$HOME/.android-studio/skills"
sync_skills_to "$ANDROID_STUDIO_GLOBAL"
echo "  ✔ Android Studio Global ($ANDROID_STUDIO_GLOBAL) configurado."

AGENTS_GLOBAL="$HOME/.agents/skills"
sync_skills_to "$AGENTS_GLOBAL"
echo "  ✔ Agentes Multi-IDE Global ($AGENTS_GLOBAL) configurado."

# IntelliJ IDEA / JetBrains (Extensão Oficial Antigravity & AI Assistant)
shopt -s nullglob
JB_DIRS=(
  "$HOME/Library/Caches/JetBrains"/*/aia/agents
  "$HOME/.cache/JetBrains"/*/aia/agents
)
shopt -u nullglob

for jb_agents in "${JB_DIRS[@]}"; do
  if [ -d "$jb_agents" ]; then
    ide_label=$(basename "$(dirname "$(dirname "$jb_agents")")")
    sync_skills_to "$jb_agents/.agents/skills"
    sync_skills_to "$jb_agents/views/other/.agents/skills"
    echo "  ✔ IntelliJ IDEA / JetBrains ($ide_label) configurado."
  fi
done

INTELLIJ_GLOBAL="$HOME/.junie/skills"
sync_skills_to "$INTELLIJ_GLOBAL"
echo "  ✔ IntelliJ / JetBrains Junie ($INTELLIJ_GLOBAL) configurado."

CLAUDE_GLOBAL="$HOME/.claude/skills"
sync_skills_to "$CLAUDE_GLOBAL"
echo "  ✔ Claude Code ($CLAUDE_GLOBAL) configurado."

CURSOR_GLOBAL="$HOME/.cursor/rules"
sync_cursor_to "$CURSOR_GLOBAL"
echo "  ✔ Cursor Global ($CURSOR_GLOBAL) configurado."

# ------------------------------------------------------------------------------
# 3. Atualizar Catálogo Dinâmico no README.md
# ------------------------------------------------------------------------------
if [ -f "$SOURCE_DIR/scripts/update-catalog.py" ]; then
  python3 "$SOURCE_DIR/scripts/update-catalog.py"
fi

echo ""
echo "🎉 Pronto! Todas as skills foram vinculadas e o catálogo está atualizado."
