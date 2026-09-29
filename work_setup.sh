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
copy "$DOTFILES/bashrc" "$HOME/.bashrc.personal"
copy "$DOTFILES/gitconfig" "$HOME/.gitconfig"

# Load personal bashrc from the end of ~/.bashrc, keeping any work-provided config.
SOURCE_LINE='[[ -f ~/.bashrc.personal ]] && source ~/.bashrc.personal'
grep -Fqx "$SOURCE_LINE" "$HOME/.bashrc" 2>/dev/null ||
  { printf '\n%s\n' "$SOURCE_LINE" >> "$HOME/.bashrc"; echo "added   source line to $HOME/.bashrc"; }

# Secrets file: created once, never touched again if it already exists.
[[ -e "$HOME/.bashrc.local" ]] || touch "$HOME/.bashrc.local"

# Optional CLI tools: bashrc falls back to plain ls/cat/pager without them.
find_missing() {
  missing=()
  for pair in rg:ripgrep eza:eza delta:git-delta starship:starship; do
    command -v "${pair%%:*}" &>/dev/null || missing+=("${pair#*:}")
  done
  command -v bat &>/dev/null || command -v batcat &>/dev/null || missing+=("bat")
}

find_missing
if (( ${#missing[@]} )) && [[ -t 0 ]] && command -v apt-get &>/dev/null && command -v sudo &>/dev/null; then
  read -rp "Install ${missing[*]} with sudo apt? [y/N] " answer
  if [[ "$answer" == [yY] ]]; then
    if sudo apt-get update; then
      for pkg in "${missing[@]}"; do
        sudo apt-get install -y "$pkg" || echo "apt could not install $pkg" >&2
      done
    fi
    find_missing
  fi
fi
if (( ${#missing[@]} )); then
  echo "optional tools not installed: ${missing[*]}"
fi
