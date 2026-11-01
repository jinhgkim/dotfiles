############## aliases ##############
alias ..='cd ..'
alias ...='cd ../..'

if command -v eza &>/dev/null; then
  alias ll='eza -l'
  alias la='eza -la'
else
  alias ll='ls -lh --color=auto'
  alias la='ls -lah --color=auto'
fi

# Debian/Ubuntu ship bat as batcat
if command -v bat &>/dev/null; then
  alias cat='bat --paging=never'
elif command -v batcat &>/dev/null; then
  alias cat='batcat --paging=never'
fi

# work machines keep personal settings in *.personal copies
_rc=~/.bashrc
[[ -f $_rc.personal ]] && _rc=$_rc.personal
alias bashv="vim $_rc"
alias bashc="cat $_rc"

_gitcfg=~/.gitconfig
[[ -f $_gitcfg.personal ]] && _gitcfg=$_gitcfg.personal
alias gitv="vim $_gitcfg"
alias gitc="cat $_gitcfg"

alias reload='source ~/.bashrc'
alias proj='cd $HOME/projects'

############## exports ##############
export EDITOR=vim
export VISUAL=vim

# dedupe history, share it live across terminals
export HISTCONTROL=ignoredups
shopt -s histappend
PROMPT_COMMAND="history -a; history -c; history -r${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# smart tab completions
[[ -f /usr/share/bash-completion/bash_completion ]] && source /usr/share/bash-completion/bash_completion

# colored git diffs
command -v delta &>/dev/null && export GIT_PAGER=delta

# prompt
command -v starship &>/dev/null && eval "$(starship init bash)"

# secrets
[[ -f ~/.bashrc.local ]] && source ~/.bashrc.local

unset _rc _gitcfg
