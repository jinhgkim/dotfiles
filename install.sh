#!/usr/bin/env bash
# Symlinks this repo's config into the fixed paths each tool expects.
# Safe to re-run: existing real files are backed up once (.bak), existing
# correct symlinks are left alone.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"

  if [[ -L "$dest" ]]; then
    if [[ "$(readlink "$dest")" == "$src" ]]; then
      echo "ok      $dest"
      return
    fi
    rm "$dest"
  elif [[ -e "$dest" ]]; then
    mv "$dest" "$dest.bak"
    echo "backed up existing $dest -> $dest.bak"
  fi

  ln -s "$src" "$dest"
  echo "linked  $dest -> $src"
}

link "$DOTFILES/agents/AGENTS.md" "$HOME/.claude/CLAUDE.md"
link "$DOTFILES/agents/AGENTS.md" "$HOME/.codex/AGENTS.md"
link "$DOTFILES/gitconfig" "$HOME/.gitconfig"