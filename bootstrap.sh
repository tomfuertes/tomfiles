#!/usr/bin/env bash

# Prevent script from being sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
	echo "Error: This script should be executed, not sourced."
	echo "Use: ./bootstrap.sh instead of source bootstrap.sh"
	return 1
fi
cd "$(dirname "${BASH_SOURCE[0]}")"
if ! git pull origin main; then
	echo "Warning: git pull failed. Continuing with local version." >&2
fi

# Check if rsync is installed
if ! command -v rsync &>/dev/null; then
	echo "Error: rsync is required but not installed."
	echo " - Install from: https://brew.sh/"
	echo " - Then: brew install rsync"
	exit 1
fi

source lib/sync.sh || { echo "Error: lib/sync.sh not found. Run from dotfiles dir." >&2; exit 1; }

echo "Changes to sync (repo → ~/):"
echo ""

if show_diffs "./" "$HOME/"; then
	echo ""
	read -p "This may overwrite existing files in your home directory. Proceed? (Y/n) " -n 1 -r
	echo ""
	if [[ -z $REPLY || $REPLY =~ ^[Yy]$ ]]; then
		if do_sync "./" "$HOME/"; then
			echo "Sync complete."

			# Source shell config (only works in zsh)
			if [[ -n "$ZSH_VERSION" ]]; then
				source "$HOME/.zshrc"
			else
				echo "Restart your terminal for changes to take effect."
			fi
		else
			echo "Sync failed!" >&2
			exit 1
		fi
	else
		echo "Sync cancelled."
	fi
else
	echo "No changes to sync."
fi

# === INSTALL MANAGED SKILLS ===
if command -v npx &>/dev/null && [[ ${#MANAGED_SKILLS[@]} -gt 0 ]]; then
	echo ""
	echo "━━━ Agent skills ━━━"
	needs_update=false
	for entry in "${MANAGED_SKILLS[@]}"; do
		repo="${entry%%|*}"
		skill="${entry##*|}"
		if [[ -d "$HOME/.claude/skills/$skill" ]]; then
			echo "  ✓ $skill"
			needs_update=true
		else
			echo "  ↓ $skill (installing...)"
			output=$(npx --yes skills add "$repo" --skill "$skill" -g --yes 2>&1)
			if [[ $? -eq 0 ]]; then
				echo "  ✓ $skill"
			else
				echo "  ✗ $skill (failed)" >&2
				echo "    $output" >&2
			fi
		fi
	done
	if $needs_update; then
		echo "  ⟳ updating installed skills..."
		output=$(npx --yes skills update -g 2>&1)
		if [[ $? -eq 0 ]]; then
			echo "  ✓ up to date"
		else
			echo "  ⚠ update failed (skills may be outdated)" >&2
			echo "    $output" >&2
		fi
	fi
else
	[[ ${#MANAGED_SKILLS[@]} -gt 0 ]] && echo "Skipping agent skills (npx not found)."
fi

# === EXCLUDE node_modules FROM TIME MACHINE ===
# Uses xattr to mark each node_modules dir (no sudo/FDA needed)
new_excludes=0
while IFS= read -r dir; do
	if ! xattr -p com.apple.metadata:com_apple_backup_excludeItem "$dir" &>/dev/null; then
		xattr -w com.apple.metadata:com_apple_backup_excludeItem com.apple.backupd "$dir" 2>/dev/null && ((new_excludes++))
	fi
done < <(find "$HOME/sandbox" -type d -name node_modules -prune 2>/dev/null)
if ((new_excludes > 0)); then
	echo ""
	echo "  Excluded $new_excludes node_modules directories from Time Machine."
fi
