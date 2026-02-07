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

# fnm (Fast Node Manager)
if command -v fnm &> /dev/null; then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

# =============================================================================
# EXPORTS
# =============================================================================
export EDITOR='code -w'
export GIT_MERGE_AUTOEDIT=no
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
# GIT CREDENTIALS
# =============================================================================
GIT_AUTHOR_NAME="tomfuertes"
GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
GIT_AUTHOR_EMAIL="tomfuertes@gmail.com"
GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"

# Write atomically only if changed (safe for parallel shell init)
_gitconfig_local="[user]
	name = $GIT_AUTHOR_NAME
	email = $GIT_AUTHOR_EMAIL
	signingkey = ~/.ssh/id_ed25519.pub
[gpg]
	format = ssh"
[[ -f ~/.gitconfig.local && "$_gitconfig_local" == "$(cat ~/.gitconfig.local)" ]] || echo "$_gitconfig_local" > ~/.gitconfig.local

# SSH agent for signing
eval "$(ssh-agent -s)" > /dev/null 2>&1
ssh-add --apple-use-keychain ~/.ssh/id_ed25519 2>/dev/null

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
alias j=z
alias c="clear"
alias G="gh browse"
alias b="npx bun"
alias brup="brew update; brew upgrade; brew cleanup"
alias subl=code
alias cursor=code

# ls with colors (macOS)
export LSCOLORS='BxBxhxDxfxhxhxhxhxcxcx'
alias l="ls -lFG"
alias la="ls -lAFG"
alias ll="la -h"
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
alias clean='find . -name "*.pyc" -delete; find . -name ".DS_Store" -delete; if [ -d .git ]; then git clean -fdx -- tmp; fi;'
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

notice() { echo -e "\033[1;32m=> $1\033[0m"; }
msg() { echo -e "\033[1;34m=> $1\033[0m"; }
error() { echo -e "\033[1;31m=> Error: $1\033[0m"; }

# Update deps workflow
udf() {
  git checkout -b update-deps-$(date +%Y-%m-%d)
  npx npm-check-updates -u --interactive
  git add package*
  git commit -m "npm run update-deps"
  git push --no-verify
  gh pr create
  npm run reset
  npm run audit
}

# Claude Code CLI helpers
cci() {
  claude -p "commit all staged and modified files with a concise commit message. Do NOT add Co-Authored-By or Generated-with lines.${1:+ Context: $1}" \
    --model haiku \
    --verbose \
    --output-format stream-json \
    --allowedTools "Bash(git add:*)" "Bash(git commit:*)" "Bash(git status:*)" "Bash(git diff:*)" "Bash(git log:*)" \
    | jq -r 'select(.type == "assistant" or .type == "result") | if .type == "result" then "✓ \(.result)" elif .message.content then .message.content[] | if .type == "text" then .text elif .type == "tool_use" then "→ \(.name): \(.input.command // .input.description // "")" else empty end else empty end'
}

cpr() {
  local base="${1:-$(git branch --show-current)}"
  claude -p "move the last commit to a new feature branch, reset $base back one commit, push the feature branch, and create a PR targeting $base. Do NOT add Co-Authored-By or Generated-with lines." \
    --model haiku \
    --verbose \
    --output-format stream-json \
    --allowedTools "Bash(git:*)" "Bash(gh pr:*)" \
    | jq -r 'select(.type == "assistant" or .type == "result") | if .type == "result" then "✓ \(.result)" elif .message.content then .message.content[] | if .type == "text" then .text elif .type == "tool_use" then "→ \(.name): \(.input.command // .input.description // "")" else empty end else empty end'
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

# History
export HISTSIZE=10000000
export SAVEHIST=10000000
setopt BANG_HIST
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt HIST_BEEP

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

# z (directory jumping)
. $(brew --prefix)/etc/profile.d/z.sh

# VSCode shell integration
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"

# =============================================================================
# GHOSTTY PER-REPO THEMES
# =============================================================================
# Drop a .ghostty file in any repo with the theme name (e.g. "IR Black")
# .local.ghostty takes precedence (personal override, gitignored)
_GHOSTTY_DEFAULT_THEME="Flexoki Dark"
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
_ghostty_chpwd  # apply on shell startup
