#!/usr/bin/env bash
# Parse manifest and provide rsync-driven sync functions
# Bash 3.x compatible (macOS default shell)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="$SCRIPT_DIR/dotfiles.manifest"

# Fail fast if manifest missing
[[ -f "$MANIFEST" ]] || { echo "Error: $MANIFEST not found" >&2; exit 1; }

# Parse manifest into include/exclude arrays
INCLUDES=()
EXCLUDES=()

while IFS= read -r line || [[ -n "$line" ]]; do
	# Skip empty lines and comments
	[[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
	# Strip inline comments and trailing whitespace
	line="${line%%#*}"
	line="${line%"${line##*[![:space:]]}"}"
	[[ -z "$line" ]] && continue

	case "$line" in
		!*) EXCLUDES+=("${line#!}") ;;
		*)  INCLUDES+=("$line") ;;
	esac
done < "$MANIFEST"

# Build rsync filter rules as a temp file (bash 3.x compatible)
# Returns path to temp file containing filter rules
build_rsync_filter_file() {
	local filter_file
	filter_file=$(mktemp)
	local parents=""

	# Collect parent directories (use string matching for dedup)
	for item in "${INCLUDES[@]}"; do
		local current="$item"
		local parent="${current%/*}"
		while [[ "$parent" != "$current" && -n "$parent" && "$parent" != "." ]]; do
			if [[ ! "$parents" =~ (^|:)"$parent"(:|$) ]]; then
				parents="${parents}${parents:+:}$parent"
			fi
			current="$parent"
			parent="${parent%/*}"
		done
	done

	# Write parent directories (sorted)
	if [[ -n "$parents" ]]; then
		echo "$parents" | tr ':' '\n' | sort | while read -r parent; do
			[[ -n "$parent" ]] && echo "+ $parent/"
		done >> "$filter_file"
	fi

	# Exclude sensitive files (must come before includes — rsync first-match-wins)
	for item in "${EXCLUDES[@]}"; do
		echo "- $item" >> "$filter_file"
	done

	# Include the actual items
	for item in "${INCLUDES[@]}"; do
		if [[ "$item" == */ ]]; then
			# Directory: include it and everything under it
			echo "+ $item" >> "$filter_file"
			echo "+ $item**" >> "$filter_file"
		else
			echo "+ $item" >> "$filter_file"
		fi
	done

	# Exclude everything else
	echo "- *" >> "$filter_file"

	echo "$filter_file"
}

# Check for skills in $HOME not in repo (informational only)
check_local_skills() {
	local home_skills="$HOME/.claude/skills"
	local repo_skills="$SCRIPT_DIR/.claude/skills"

	[[ ! -d "$home_skills" ]] && return

	local new_skills=()
	for skill_dir in "$home_skills"/*/; do
		[[ ! -d "$skill_dir" ]] && continue
		local skill_name=$(basename "$skill_dir")
		[[ "$skill_name" == "*" ]] && continue
		if [[ ! -d "$repo_skills/$skill_name" ]]; then
			new_skills+=("$skill_name")
		fi
	done

	if [[ ${#new_skills[@]} -gt 0 ]]; then
		echo ""
		echo "━━━ Local skills not in repo ━━━"
		for skill in "${new_skills[@]}"; do
			echo "  • $skill"
		done
		echo "(Copy manually if you want to track them)"
	fi
}

# Get list of files that would change (rsync dry-run)
get_changed_files() {
	local src="$1" dest="$2"
	local filter_file
	filter_file=$(build_rsync_filter_file)

	# Filter out rsync info lines (start with space, "Transfer", "total", "sent")
	rsync -avn --filter="merge $filter_file" --out-format='%n' "$src" "$dest" 2>/dev/null \
		| grep -v '/$' \
		| grep -v '^Transfer ' \
		| grep -v '^total size' \
		| grep -v '^sent '
	rm -f "$filter_file"
}

# Show colored diffs for changed files
# Returns 0 if there are changes, 1 if no changes
show_diffs() {
	local src="$1" dest="$2"
	local has_changes=false
	local file
	local lines_added=0 lines_removed=0
	local new_files=() modified_files=()

	while IFS= read -r file; do
		[[ -z "$file" ]] && continue
		has_changes=true

		local src_file="$src$file"
		local dest_file="$dest$file"

		echo -e "\033[36m━━━ $file ━━━\033[0m"
		if [[ -f "$dest_file" ]]; then
			modified_files+=("$file")
			# Get diff stats
			local diff_stat
			diff_stat=$(git diff --no-index --stat "$dest_file" "$src_file" 2>/dev/null | tail -1 || true)
			local added removed
			added=$(echo "$diff_stat" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || echo 0)
			removed=$(echo "$diff_stat" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+' || echo 0)
			((lines_added += ${added:-0}))
			((lines_removed += ${removed:-0}))
			# Show colored diff
			git diff --no-index --color=always "$dest_file" "$src_file" 2>/dev/null | tail -n +5
		else
			new_files+=("$file")
			local file_lines
			file_lines=$(wc -l < "$src_file" | tr -d ' ')
			((lines_added += file_lines))
			echo "(new file)"
			head -20 "$src_file"
			[[ $file_lines -gt 20 ]] && echo "... (truncated)"
		fi
		echo ""
	done < <(get_changed_files "$src" "$dest")

	# Print summary
	if $has_changes; then
		echo -e "\033[33m━━━ Summary ━━━\033[0m"
		if [[ ${#new_files[@]} -gt 0 ]]; then
			echo "New files (${#new_files[@]}):"
			for f in "${new_files[@]}"; do
				echo -e "  \033[32m+ $f\033[0m"
			done
		fi
		if [[ ${#modified_files[@]} -gt 0 ]]; then
			echo "Modified files (${#modified_files[@]}):"
			for f in "${modified_files[@]}"; do
				echo -e "  \033[33m~ $f\033[0m"
			done
		fi
		echo ""
		echo -e "Total: \033[32m+$lines_added\033[0m \033[31m-$lines_removed\033[0m lines"
	fi

	$has_changes
}

# Actually sync files
# Returns 0 on success, 1 on failure
do_sync() {
	local src="$1" dest="$2"
	local filter_file rsync_status
	filter_file=$(build_rsync_filter_file)

	rsync -av --filter="merge $filter_file" "$src" "$dest"
	rsync_status=$?
	rm -f "$filter_file"

	if [[ $rsync_status -ne 0 ]]; then
		echo "Error: rsync failed with exit code $rsync_status" >&2
		return 1
	fi
	return 0
}

# Scan synced files for potential secrets
# Returns 0 if secrets found, 1 if clean
scan_for_secrets() {
	echo "━━━ Scanning for potential secrets... ━━━"

	local patterns=(
		'ANTHROPIC_API_KEY'
		'OPENAI_API_KEY'
		'API_KEY\s*='
		'api[_-]?key\s*[:=]'
		'secret[_-]?key\s*[:=]'
		'access[_-]?token\s*[:=]'
		'Bearer\s+[A-Za-z0-9_-]+'
		'sk-[A-Za-z0-9]{20,}'
		'ghp_[A-Za-z0-9]{36}'
		'gho_[A-Za-z0-9]{36}'
		'github_pat_[A-Za-z0-9_]{22,}'
		'xox[baprs]-[A-Za-z0-9-]+'
		'-----BEGIN\s+(RSA\s+)?PRIVATE\s+KEY-----'
		'password\s*[:=]\s*["\x27][^\s]+'
		'AWS_SECRET_ACCESS_KEY'
		'PRIVATE_KEY'
	)

	local file_patterns="--include=*.sh --include=*.json --include=*.md"
	file_patterns="$file_patterns --include=.zshrc --include=.gitconfig"
	file_patterns="$file_patterns --include=.curlrc --include=.wgetrc --include=.editorconfig"

	local found=false
	local pattern matches
	for pattern in "${patterns[@]}"; do
		matches=$(grep -rEin "$pattern" . $file_patterns 2>/dev/null \
			| grep -v "reverse.sh" \
			| grep -v "lib/sync.sh" \
			| grep -v "secret-patterns.sh" \
			| grep -v "SECRET_PATTERNS" \
			| grep -v "patterns=" \
			|| true)
		if [[ -n "$matches" ]]; then
			if ! $found; then
				echo ""
				echo "Warning: Potential secrets detected:"
				found=true
			fi
			echo "$matches"
		fi
	done

	if $found; then
		echo ""
		echo "Review the above before committing!"
		echo "Consider adding sensitive values to .gitignore or .extra"
		return 0
	else
		echo "No obvious secrets found."
		return 1
	fi
}
