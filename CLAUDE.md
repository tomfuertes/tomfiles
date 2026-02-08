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

- `.zshrc` - All shell config (PATH, exports, aliases, functions, git credentials, zsh settings)
- `.gitconfig` - Git aliases and settings
- `.gitignore` - Global gitignore
- `.config/ghostty/config` - Ghostty terminal config
- `.ghostty` - Per-repo Ghostty theme (convention: drop in any repo root)

## Notes

- Prompt: built-in `vcs_info` (no external deps)
- Per-repo terminal themes: drop a `.ghostty` file with theme name, `.local.ghostty` for personal override
- Personal preferences live in `.claude/CLAUDE.md` (syncs to `~/.claude/CLAUDE.md`)
- Git worktree workflow is documented in `.claude/CLAUDE.md` under "Git Worktrees"
