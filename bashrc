# aliases
alias ..='cd ..'
alias ...='cd ../..'

alias ll='ls -lh --color=auto'
alias la='ls -lah --color=auto'

alias reload='source ~/.bashrc'
alias proj='cd $HOME/projects'

# exports
export EDITOR=vim
export VISUAL=vim

# dedupe history, share it live across terminals
export HISTCONTROL=ignoredups
shopt -s histappend
PROMPT_COMMAND="history -a; history -c; history -r${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# smart tab completions
[[ -f /usr/share/bash-completion/bash_completion ]] && source /usr/share/bash-completion/bash_completion

# secrets
[[ -f ~/.bashrc.local ]] && source ~/.bashrc.local
