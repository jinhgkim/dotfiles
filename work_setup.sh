#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
trap 'echo "work_setup.sh failed at line $LINENO" >&2' ERR

copy() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" ]]; then
    echo "skip    $dest (already exists)"
    return
  fi
  cp "$src" "$dest"
  echo "copied  $dest"
}

copy "$DOTFILES/AGENTS.md" "$HOME/.claude/CLAUDE.md"
copy "$DOTFILES/AGENTS.md" "$HOME/.codex/AGENTS.md"
copy "$DOTFILES/vimrc" "$HOME/.vimrc"
copy "$DOTFILES/bashrc" "$HOME/.bashrc"
copy "$DOTFILES/gitconfig" "$HOME/.gitconfig"

# Secrets file: created once, never touched again if it already exists.
[[ -e "$HOME/.bashrc.local" ]] || touch "$HOME/.bashrc.local"
