#!/bin/bash
# PreToolUse (Bash): Warn about secrets in shell commands
# Exit 2 = block, user can approve to continue

set -euo pipefail

# Check dependencies
command -v jq &>/dev/null || { echo "Error: jq required but not installed" >&2; exit 1; }

HOOK_DIR="$(dirname "$0")"
source "$HOOK_DIR/lib/secret-patterns.sh" || { echo "Error: Cannot load $HOOK_DIR/lib/secret-patterns.sh" >&2; exit 1; }

PAYLOAD=$(cat)
COMMAND=$(echo "$PAYLOAD" | jq -r '.tool_input.command // ""')

[[ -z "$COMMAND" ]] && exit 0

if pattern=$(check_for_secrets "$COMMAND"); then
  redacted=$(get_redacted_match "$COMMAND" "$pattern")
  cat >&2 << EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️  SECRET DETECTED IN BASH COMMAND
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Found: $redacted

To allow this command:
  → Approve in the permission prompt

Better approach:
  → export TOKEN="..." then use \$TOKEN
  → Commands with secrets are logged
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
  exit 2
fi

exit 0
