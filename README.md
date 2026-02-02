# dotfiles

Personal dotfiles, zsh-only. Fork of [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles).

## Install

```bash
git clone https://github.com/tomfuertes/dotfiles.git && cd dotfiles && ./bootstrap.sh
```

## Structure

```
.zshrc         # All shell config (PATH, exports, aliases, functions)
.extra         # Personal config (git credentials, local aliases, Claude helpers)
.gitconfig     # Git aliases and settings
.gitignore     # Global gitignore
bootstrap.sh   # Sync dotfiles to ~ (shows diff, prompts)
brew.sh        # Homebrew packages for new Mac
```

Also: `.curlrc`, `.wgetrc`, `.editorconfig`, `.hushlogin`

## Setup

```bash
./brew.sh                                                       # Install packages
git clone https://github.com/sindresorhus/pure.git ~/.zsh/pure  # Pure prompt
```
