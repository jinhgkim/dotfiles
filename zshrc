# aliases
alias ..='cd ..'
alias ...='cd ../..'

alias ll='ls -lhG'
alias la='ls -lahG'

alias reload='source ~/.zshrc'
alias proj='cd $HOME/projects'

# exports
export EDITOR=vim
export VISUAL=vim

# dedupe history, share it live across terminals
setopt HIST_IGNORE_DUPS SHARE_HISTORY INC_APPEND_HISTORY

# smart tab completions
autoload -Uz compinit && compinit

# secrets
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local