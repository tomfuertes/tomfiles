# .zshrc

# =============================================================================
# PATH
# =============================================================================
export PATH="$PATH:/usr/local/sbin"
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
export PATH="$HOME/.local/bin:$PATH"
eval "$(/opt/homebrew/bin/brew shellenv)"

# System
ulimit -n 2560

# =============================================================================
# EXPORTS
# =============================================================================
export EDITOR='code'
export NODE_REPL_HISTORY=~/.node_history
export NODE_REPL_HISTORY_SIZE='32768'
export NODE_REPL_MODE='sloppy'
export PYTHONIOENCODING='UTF-8'
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export LESS_TERMCAP_md=$'\e[1;33m'
export MANPAGER='less -X'
export GPG_TTY=$(tty)

# =============================================================================
# ALIASES
# =============================================================================
# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~"
alias -- -="cd -"

# Shortcuts
alias g="git"
alias gist='gh gist create'
alias sudo='sudo '
alias pip=/opt/homebrew/bin/pip3
alias python=/opt/homebrew/bin/python3

# ls with colors (macOS)
export LSCOLORS='BxBxhxDxfxhxhxhxhxcxcx'
alias l="ls -lFG"
alias la="ls -lAFG"
alias lsd="ls -lFG | grep --color=never '^d'"
alias ls="command ls -G"

# grep with colors
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Utilities
alias update='sudo softwareupdate -i -a; brew update; brew upgrade; brew cleanup; npm install npm -g; npm update -g'
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias flush="dscacheutil -flushcache && killall -HUP mDNSResponder"
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"
alias reload="exec $SHELL -l"
alias path='echo -e ${PATH//:/\\n}'

# =============================================================================
# FUNCTIONS
# =============================================================================
o() {
  if [ $# -eq 0 ]; then
    open .
  else
    open "$@"
  fi
}

# =============================================================================
# ZSH CONFIG
# =============================================================================
# Pure prompt
fpath+=$HOME/.zsh/pure
autoload -U promptinit; promptinit
prompt pure

# Completion
autoload -U +X bashcompinit && bashcompinit
autoload -U +X compinit && compinit

# Homebrew completions
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
  autoload -Uz compinit
  compinit
fi

# Tab completion for `g` alias
if type _git &> /dev/null; then
  complete -o default -o nospace -F _git g
fi

# SSH hostname completion
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh

# VSCode shell integration
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"

# =============================================================================
# MACHINE-SPECIFIC (credentials, local config)
# =============================================================================
[ -r ~/.extra ] && [ -f ~/.extra ] && source ~/.extra
