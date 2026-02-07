---
name: ghostty-theme
description: Set a Ghostty terminal theme for the current repo (.ghostty or .local.ghostty)
model: haiku
context: none
agent: general-purpose
allowed-tools: Bash(ls *), Bash(echo *), Bash(cat *), Bash(grep *), Read, Write, Edit
argument-hint: "[Atom|Firefox Dev|Flexoki Dark|Github Dark|IR Black|Liquid Carbon Transparent] [--local]"
---

You set Ghostty terminal themes per-repo. Be terse — one confirmation line when done.

## How It Works

The user's shell (`~/.zshrc`) has a `chpwd` hook that walks up from `$PWD` looking for:
1. `.local.ghostty` (personal override, gitignored) — checked first
2. `.ghostty` (shared/committed) — checked second

Each file contains one line: the Ghostty theme name.

## Available Themes

All 438 built-in themes live at `/Applications/Ghostty.app/Contents/Resources/ghostty/themes/`.

Favorites (suggest these first):
- Atom
- Firefox Dev
- Flexoki Dark
- Github Dark
- IR Black
- Liquid Carbon Transparent

## Action: $ARGUMENTS

### If a theme name is given (e.g. `/ghostty-theme IR Black`)
1. Verify the theme exists: `ls "/Applications/Ghostty.app/Contents/Resources/ghostty/themes/$THEME"`
2. Write the theme name to `.ghostty` in the repo root (find via `git rev-parse --show-toplevel`)
3. If `--local` flag is present, write to `.local.ghostty` instead and ensure `.local.ghostty` is in the repo's `.gitignore`

### If `--local` flag without a theme
1. Check if `.ghostty` exists, read its theme
2. Copy that theme to `.local.ghostty` so the user can override independently
3. Ensure `.local.ghostty` is in `.gitignore`

### If `list` or no arguments
1. Show current theme: `cat .ghostty .local.ghostty 2>/dev/null`
2. List the favorites above
3. Mention `ls "/Applications/Ghostty.app/Contents/Resources/ghostty/themes/" | grep -i <query>` for searching all 438

## Gitignore Handling

When creating `.local.ghostty`:
1. Find the repo's `.gitignore` (repo root)
2. If `.local.ghostty` is not already in it, append it
3. If no `.gitignore` exists, create one with `.local.ghostty`

## Output

One line: what you did. E.g.: `Set .ghostty → IR Black` or `Set .local.ghostty → Github Dark (added to .gitignore)`
