# aliases
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

alias bashrc='vim ~/.zshrc'
alias reload='source ~/.zshrc'
alias proj='cd $HOME/projects'

# exports
export EDITOR=vim
export VISUAL=vim

# dedupe history, share it live across terminals
setopt HIST_IGNORE_DUPS SHARE_HISTORY INC_APPEND_HISTORY

# smart tab completions
autoload -Uz compinit && compinit

# colored git diffs
command -v delta &>/dev/null && export GIT_PAGER=delta

# prompt
command -v starship &>/dev/null && eval "$(starship init zsh)"

# secrets
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local