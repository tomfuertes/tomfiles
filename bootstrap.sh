#!/usr/bin/env bash

# Prevent script from being sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
	echo "Error: This script should be executed, not sourced."
	echo "Use: ./bootstrap.sh instead of source bootstrap.sh"
	return 1
fi
cd "$(dirname "${BASH_SOURCE[0]}")"
git pull origin main

# Check if rsync is installed
if ! command -v rsync &>/dev/null; then
	echo "Error: rsync is required but not installed."

	echo " - Install from: https://brew.sh/"
	echo " - Then: brew install rsync"
	exit 1
fi

# Define excluded files/patterns
EXCLUDES=(
	".git*"
	".DS_Store"
	"bootstrap.sh"
	"README.md"
	"LICENSE-MIT.txt"
	"brew.sh"
	"CLAUDE.md"
	"AGENTS.md"
	"settings.local.json"
)

# Build exclude parameters for rsync
EXCLUDE_PARAMS=""
for item in "${EXCLUDES[@]}"; do
	EXCLUDE_PARAMS="$EXCLUDE_PARAMS --exclude=$item"
done

# Build find exclusions (prune dirs, exclude files)
FIND_PRUNE=()
FIND_EXCLUDES=()
for item in "${EXCLUDES[@]}"; do
	FIND_PRUNE+=(-name "$item" -prune -o)
	FIND_EXCLUDES+=(-not -name "$item")
done

# Show diffs for files that would change
has_changes=false
while IFS= read -r file; do
	[[ -z "$file" ]] && continue
	file="${file#./}"  # Strip leading ./
	if [[ -f "$HOME/$file" ]]; then
		if ! diff -q "$file" "$HOME/$file" &>/dev/null; then
			has_changes=true
			echo "━━━ $file ━━━"
			git diff --no-index --color=always "$HOME/$file" "$file" 2>/dev/null | tail -n +5
			echo ""
		fi
	else
		has_changes=true
		echo "━━━ $file (new) ━━━"
	fi
done < <(find . "${FIND_PRUNE[@]}" -type f "${FIND_EXCLUDES[@]}" -print 2>/dev/null | sort)

if ! $has_changes; then
	echo "No changes to sync."
fi
echo ""

# Prompt for confirmation
read -p "This may overwrite existing files in your home directory. Proceed? (Y/n) " -n 1 -r
echo ""
if [[ -z $REPLY || $REPLY =~ ^[Yy]$ ]]; then
	rsync -av $EXCLUDE_PARAMS ./ "$HOME/"
	echo "Sync complete."

	# Source appropriate shell configuration
	if [ -n "$ZSH_VERSION" ]; then
		source "$HOME/.zshrc"
	else
		echo "Unknown shell, please restart your terminal for changes to take effect."
	fi
else
	echo "Sync cancelled."
fi
