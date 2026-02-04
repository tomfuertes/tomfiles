#!/usr/bin/env bash

# Reverse of bootstrap.sh: pulls tracked files from $HOME back into repo

# Prevent script from being sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
	echo "Error: This script should be executed, not sourced."
	echo "Use: ./reverse.sh instead of source reverse.sh"
	return 1
fi
cd "$(dirname "${BASH_SOURCE[0]}")"

# Check if rsync is installed
if ! command -v rsync &>/dev/null; then
	echo "Error: rsync is required but not installed."
	echo " - Install from: https://brew.sh/"
	echo " - Then: brew install rsync"
	exit 1
fi

source lib/sync.sh || { echo "Error: lib/sync.sh not found. Run from dotfiles dir." >&2; exit 1; }

echo "Changes to pull (~/ → repo):"
echo ""

if show_diffs "$HOME/" "./"; then
	echo ""
	read -p "Pull changes from ~ into repo? (Y/n) " -n 1 -r
	echo ""
	if [[ -z $REPLY || $REPLY =~ ^[Yy]$ ]]; then
		if do_sync "$HOME/" "./"; then
			echo ""
			scan_for_secrets
			check_local_skills
			echo ""
			echo "Sync complete. Review with: git status && git diff"
		else
			echo "Sync failed!" >&2
			exit 1
		fi
	else
		echo "Sync cancelled."
	fi
else
	echo "No changes to sync from ~ into repo."
	check_local_skills
fi
