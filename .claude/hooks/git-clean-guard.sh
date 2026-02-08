#!/bin/bash
# PreToolUse (Bash): Block git clean with force flags
# Exit 2 = block, user can approve to continue
# git clean -fd destroys untracked files — especially dangerous on orphan branches
# where .env and other gitignored files aren't protected by the index.

set -euo pipefail

command -v jq &>/dev/null || { echo "Error: jq required but not installed" >&2; exit 1; }

PAYLOAD=$(cat)
COMMAND=$(echo "$PAYLOAD" | jq -r '.tool_input.command // ""')

[[ -z "$COMMAND" ]] && exit 0

# Match git clean with any force flag (-f, -fd, -fx, -fxd, --force, etc.)
if echo "$COMMAND" | grep -qE 'git\s+clean\s+.*-[a-zA-Z]*f'; then
  cat >&2 << EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️  git clean -f BLOCKED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Command: $COMMAND

git clean with force flags destroys untracked
files permanently. On orphan branches (pr-assets)
this will delete .env and other gitignored files.

Safer alternatives:
  → git rm -rf .       (clears index only)
  → git checkout --    (restore tracked files)
  → git stash          (save changes temporarily)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
  exit 2
fi

exit 0
