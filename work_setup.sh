#!/usr/bin/env bash
set -Eeuo pipefail

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

# Load personal bashrc from the end of ~/.bashrc, keeping any work-provided config.
SOURCE_LINE='[[ -f ~/.bashrc.personal ]] && source ~/.bashrc.personal'
grep -Fqx "$SOURCE_LINE" "$HOME/.bashrc" 2>/dev/null ||
  { printf '\n%s\n' "$SOURCE_LINE" >> "$HOME/.bashrc"; echo "added   source line to $HOME/.bashrc"; }

# No ~/.gitconfig: use the personal one as is. Work-provided ~/.gitconfig: include
# the personal one from it, keeping the work name and email.
if [[ ! -e "$HOME/.gitconfig" ]] || cmp -s "$DOTFILES/gitconfig" "$HOME/.gitconfig"; then
  copy "$DOTFILES/gitconfig" "$HOME/.gitconfig"
else
  copy "$DOTFILES/gitconfig" "$HOME/.gitconfig.personal"
  for key in user.name user.email; do
    git config --file "$HOME/.gitconfig.personal" --unset "$key" || true
  done
  INCLUDE_PATH='~/.gitconfig.personal'
  git config --global --get-all include.path 2>/dev/null | grep -Fqx "$INCLUDE_PATH" ||
    { git config --global --add include.path "$INCLUDE_PATH"; echo "added   include to $HOME/.gitconfig"; }
fi

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

pm=""
if command -v apt-get &>/dev/null; then
  pm=apt-get
elif command -v dnf &>/dev/null; then
  pm=dnf
fi

find_missing
if (( ${#missing[@]} )) && [[ -t 0 ]] && [[ -n "$pm" ]] && command -v sudo &>/dev/null; then
  read -rp "Install ${missing[*]} with sudo $pm? [y/N] " answer || answer=""
  if [[ "$answer" == [yY] ]]; then
    if [[ "$pm" != apt-get ]] || sudo apt-get update; then
      for pkg in "${missing[@]}"; do
        sudo "$pm" install -y "$pkg" || echo "$pm could not install $pkg" >&2
      done
    fi
    find_missing
  fi
fi
if (( ${#missing[@]} )); then
  echo "optional tools not installed: ${missing[*]}"
fi
