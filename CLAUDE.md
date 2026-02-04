# CRITICAL: This is a dotfiles repo that syncs to $HOME

**This `.claude/` folder syncs to `~/.claude/` via rsync.**

When editing files here, remember:

- `settings.json` → `~/.claude/settings.json` (global Claude Code config)
- `hooks/` → `~/.claude/hooks/` (global hooks, run from ANY project)
- Paths in hooks must use `$HOME/.claude/` not `$CLAUDE_PROJECT_DIR`
- Changes here affect ALL Claude Code sessions after next `./bootstrap.sh`

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
- Personal preferences live in `.claude/CLAUDE.md` (syncs to `~/.claude/CLAUDE.md`)
