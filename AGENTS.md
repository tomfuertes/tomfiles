# CLAUDE.md

Guidance for Claude Code when working in this repository.

## Overview

Personal dotfiles. Shell config synced to `$HOME` via rsync.

## Commands

```bash
./bootstrap.sh   # Sync dotfiles to ~ (shows diff, prompts)
./brew.sh        # Install Homebrew packages (new Mac setup)
```

## Structure

- `.zshrc` - All shell config (PATH, exports, aliases, functions, zsh settings)
- `.extra` - Personal config (git credentials, local aliases, Claude CLI helpers)
- `.gitconfig` - Git aliases and settings
- `.gitignore` - Global gitignore

## Notes

- Uses [Pure prompt](https://github.com/sindresorhus/pure): `git clone https://github.com/sindresorhus/pure.git ~/.zsh/pure`
- Fork and customize `.extra` for your own credentials

## Dev Workflow

- Prefer hooks and skills for repeatable patterns
- Use Haiku for cheap checks, Sonnet for judgment, Opus for synthesis
- Separate shared config (settings.json) from personal (settings.local.json)
- When setting up new patterns: explain the tradeoffs, then just do it
