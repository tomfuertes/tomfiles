#!/bin/bash
# PreToolUse (Edit|Write): Block secrets in file content
# Exit 2 = block with prompt, user can approve to continue

set -euo pipefail

# Check dependencies
command -v jq &>/dev/null || { echo "Error: jq required but not installed" >&2; exit 1; }

HOOK_DIR="$(dirname "$0")"
source "$HOOK_DIR/lib/secret-patterns.sh" || { echo "Error: Cannot load $HOOK_DIR/lib/secret-patterns.sh" >&2; exit 1; }

PAYLOAD=$(cat)
CONTENT=$(echo "$PAYLOAD" | jq -r '.tool_input.content // .tool_input.new_string // ""')

[[ -z "$CONTENT" ]] && exit 0

if pattern=$(check_for_secrets "$CONTENT"); then
  redacted=$(get_redacted_match "$CONTENT" "$pattern")
  cat >&2 << EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚫 BLOCKED: Secret detected in file content
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Found: $redacted

Use environment variables instead:
  → Store in .env (gitignored)
  → Reference via process.env.VAR or \$VAR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
  exit 2
fi

exit 0
