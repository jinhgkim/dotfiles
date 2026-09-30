#!/usr/bin/env bash
set -Eeuo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
trap 'echo "mac_setup.sh failed at line $LINENO" >&2' ERR

# 1. Homebrew: skip if already installed.
if command -v brew &>/dev/null; then
  BREW_BIN="$(command -v brew)"
elif [[ -x /opt/homebrew/bin/brew ]]; then
  BREW_BIN=/opt/homebrew/bin/brew
else
  echo "Installing Homebrew. Follow the installer's prompts."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  BREW_BIN=/opt/homebrew/bin/brew
fi

# Enable brew now, and make sure future Terminal sessions have it too.
eval "$("$BREW_BIN" shellenv)"
BREW_SETUP="$(printf 'eval "$(%q shellenv)"' "$BREW_BIN")"
grep -Fqx "$BREW_SETUP" "$HOME/.zprofile" 2>/dev/null ||
  printf '\n%s\n' "$BREW_SETUP" >> "$HOME/.zprofile"

# 2. Symlinks: skip if already correct, back up anything real.
link() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    echo "ok      $dest"
    return
  fi
  if [[ -L "$dest" ]]; then
    rm "$dest"
  elif [[ -e "$dest" ]]; then
    mv "$dest" "$dest.bak"
    echo "backed up existing $dest -> $dest.bak"
  fi
  ln -s "$src" "$dest"
  echo "linked  $dest -> $src"
}

link "$DOTFILES/AGENTS.md" "$HOME/.claude/CLAUDE.md"
link "$DOTFILES/AGENTS.md" "$HOME/.codex/AGENTS.md"
link "$DOTFILES/gitconfig" "$HOME/.gitconfig"
link "$DOTFILES/vimrc" "$HOME/.vimrc"
link "$DOTFILES/zshrc" "$HOME/.zshrc"

# Secrets file: created once, never touched again if it already exists.
[[ -e "$HOME/.zshrc.local" ]] || touch "$HOME/.zshrc.local"

# 3. Apps: install whatever's missing, upgrade whatever's outdated.
if ! brew bundle --file="$DOTFILES/Brewfile"; then
  echo "warning: one or more apps in Brewfile failed (see above) — everything else still succeeded" >&2
  exit 1
fi
