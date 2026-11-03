#!/usr/bin/env bash

# Safe to re-run: copies are overwritten with the latest dotfiles versions.

set -Eeuo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
trap 'echo "work_setup.sh failed at line $LINENO" >&2' ERR

copy() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [[ ! -e "$dest" ]]; then
    cp "$src" "$dest"
    echo "copied  $dest"
  elif cmp -s "$src" "$dest"; then
    echo "skip    $dest (up to date)"
  else
    cp "$src" "$dest"
    echo "updated $dest"
  fi
}

copy_dir() {
  local src="$1" dest="$2"
  if [[ -d "$dest" ]] && diff -rq "$src" "$dest" &>/dev/null; then
    echo "skip    $dest (up to date)"
    return
  fi
  if [[ -e "$dest" ]]; then
    rm -rf "$dest.bak"
    mv "$dest" "$dest.bak"
    echo "backed up $dest -> $dest.bak"
  fi
  mkdir -p "$(dirname "$dest")"
  cp -R "$src" "$dest"
  echo "copied  $dest"
}

copy "$DOTFILES/AGENTS.md" "$HOME/.claude/CLAUDE.md"
copy "$DOTFILES/AGENTS.md" "$HOME/.codex/AGENTS.md"
copy "$DOTFILES/vimrc" "$HOME/.vimrc"
copy_dir "$DOTFILES/nvim" "$HOME/.config/nvim"
copy "$DOTFILES/bashrc" "$HOME/.bashrc.personal"

# Load personal bashrc from the end of ~/.bashrc, keeping any work-provided config.
SOURCE_LINE='[[ -f ~/.bashrc.personal ]] && source ~/.bashrc.personal'
grep -Fqx "$SOURCE_LINE" "$HOME/.bashrc" 2>/dev/null ||
  { printf '\n%s\n' "$SOURCE_LINE" >> "$HOME/.bashrc"; echo "added   source line to $HOME/.bashrc"; }

# This assumes there's always a work-provided ~/.gitconfig and includes the .personal
# one from it, keeping the work name and email.
copy "$DOTFILES/gitconfig" "$HOME/.gitconfig.personal"
for key in user.name user.email; do
  git config --file "$HOME/.gitconfig.personal" --unset "$key" || true
done
INCLUDE_PATH='~/.gitconfig.personal'
git config --global --get-all include.path 2>/dev/null | grep -Fqx "$INCLUDE_PATH" ||
  { git config --global --add include.path "$INCLUDE_PATH"; echo "added   include to $HOME/.gitconfig"; }

# Secrets file: created once, never touched again if it already exists.
[[ -e "$HOME/.bashrc.local" ]] || touch "$HOME/.bashrc.local"

# Nerd Font for nvim icons
FONT_DIR="$HOME/.local/share/fonts"
for font in "$DOTFILES"/fonts/*.ttf; do
  copy "$font" "$FONT_DIR/${font##*/}"
done
command -v fc-cache &>/dev/null && fc-cache -f "$FONT_DIR"

# Optional CLI tools: bashrc falls back to plain ls/cat/pager without them.
# nvim (kickstart) needs rg, fd and tree-sitter.
find_missing() {
  missing=()
  for pair in rg:ripgrep eza:eza delta:git-delta starship:starship tree-sitter:tree-sitter-cli; do
    command -v "${pair%%:*}" &>/dev/null || missing+=("${pair#*:}")
  done
  command -v bat &>/dev/null || command -v batcat &>/dev/null || missing+=("bat")
  # Debian/Ubuntu ship fd as fdfind
  command -v fd &>/dev/null || command -v fdfind &>/dev/null || missing+=("fd-find")
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

# kickstart.nvim needs Neovim 0.12+, and distro packages are often older.
NVIM_HELP="see ~/.config/nvim/README.md (Install Recipes) for ways to get a recent version"
if ! command -v nvim &>/dev/null; then
  echo "neovim not installed: $NVIM_HELP"
else
  nvim_ver="$(nvim --version)"
  nvim_ver="${nvim_ver%%$'\n'*}"
  nvim_ver="${nvim_ver#NVIM v}"
  if [[ "$(printf '%s\n' 0.12 "$nvim_ver" | sort -V | head -n1)" != 0.12 ]]; then
    echo "neovim $nvim_ver is older than 0.12: $NVIM_HELP"
  fi
fi
