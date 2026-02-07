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
# Prompt (git branch via vcs_info, no external deps)
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '%F{magenta}%b%f '
setopt PROMPT_SUBST
PROMPT='%F{cyan}%1~%f ${vcs_info_msg_0_}%F{yellow}❯%f '

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
# GHOSTTY PER-REPO THEMES
# =============================================================================
# Drop a .ghostty file in any repo with the theme name (e.g. "IR Black")
# Default theme set via _GHOSTTY_DEFAULT_THEME in .extra
_GHOSTTY_THEME_DIR="/Applications/Ghostty.app/Contents/Resources/ghostty/themes"
_GHOSTTY_CURRENT=""

_ghostty_apply_theme() {
  local theme_file="$_GHOSTTY_THEME_DIR/$1"
  [[ -f "$theme_file" ]] || return
  while IFS= read -r line; do
    case "$line" in
      palette\ =\ *)
        local rest="${line#palette = }" idx="${rest%%=*}" color="${rest#*=}"
        printf '\033]4;%s;%s\033\\' "$idx" "$color" ;;
      foreground\ =\ *)    printf '\033]10;%s\033\\' "${line#foreground = }" ;;
      background\ =\ *)    printf '\033]11;%s\033\\' "${line#background = }" ;;
      cursor-color\ =\ *)  printf '\033]12;%s\033\\' "${line#cursor-color = }" ;;
    esac
  done < "$theme_file"
}

_ghostty_chpwd() {
  [[ "$TERM_PROGRAM" != "ghostty" ]] && return
  # Walk up from $PWD looking for .local.ghostty (personal) then .ghostty (shared)
  local dir="$PWD" theme=""
  while [[ "$dir" != "/" ]]; do
    [[ -f "$dir/.local.ghostty" ]] && { theme="$(<"$dir/.local.ghostty")"; break; }
    [[ -f "$dir/.ghostty" ]] && { theme="$(<"$dir/.ghostty")"; break; }
    dir="${dir:h}"
  done
  theme="${theme:-${_GHOSTTY_DEFAULT_THEME:-Flexoki Dark}}"
  # Skip if theme hasn't changed
  [[ "$theme" == "$_GHOSTTY_CURRENT" ]] && return
  _GHOSTTY_CURRENT="$theme"
  _ghostty_apply_theme "$theme"
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _ghostty_chpwd

# =============================================================================
# MACHINE-SPECIFIC (credentials, local config)
# =============================================================================
[ -r ~/.extra ] && [ -f ~/.extra ] && source ~/.extra
_ghostty_chpwd  # apply theme after .extra sets REPO_THEMES
