############## aliases ##############
alias ..='cd ..'
alias ...='cd ../..'

if command -v eza &>/dev/null; then
  alias ll='eza -l'
  alias la='eza -la'
else
  alias ll='ls -lhG'
  alias la='ls -lahG'
fi

command -v bat &>/dev/null && alias cat='bat --paging=never'

alias bashv='nvim ~/.zshrc'
alias bashc='cat ~/.zshrc'
alias gitv='nvim ~/.gitconfig'
alias gitc='cat ~/.gitconfig'

alias reload='source ~/.zshrc'
alias proj='cd $HOME/projects'

############## exports ##############
export EDITOR=nvim
export VISUAL=nvim

# for OSL dev work
export LLVM_ROOT=/opt/homebrew/opt/llvm

# emacs-style line editing; set explicitly because zsh picks vi mode when EDITOR contains "vi"
bindkey -e

# Ctrl-X Ctrl-E: edit the current command in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# dedupe history, share it live across terminals
setopt HIST_IGNORE_DUPS SHARE_HISTORY INC_APPEND_HISTORY

# smart tab completions
autoload -Uz compinit && compinit

# colored git diffs
command -v delta &>/dev/null && export GIT_PAGER=delta

# prompt
command -v starship &>/dev/null && eval "$(starship init zsh)"

# iTerm2 shell integration
[[ -f ~/.iterm2_shell_integration.zsh ]] && source ~/.iterm2_shell_integration.zsh

# secrets
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
