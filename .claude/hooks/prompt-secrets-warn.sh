#!/bin/bash
# UserPromptSubmit: Warn about secrets pasted in prompts
# Exit 2 = block, user can approve to continue

set -euo pipefail

# Check dependencies
command -v jq &>/dev/null || { echo "Error: jq required but not installed" >&2; exit 1; }

HOOK_DIR="$(dirname "$0")"
source "$HOOK_DIR/lib/secret-patterns.sh" || { echo "Error: Cannot load $HOOK_DIR/lib/secret-patterns.sh" >&2; exit 1; }

PAYLOAD=$(cat)
PROMPT=$(echo "$PAYLOAD" | jq -r '.prompt // ""')

[[ -z "$PROMPT" ]] && exit 0

if pattern=$(check_for_secrets "$PROMPT"); then
  redacted=$(get_redacted_match "$PROMPT" "$pattern")
  cat >&2 << EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️  SECRET DETECTED IN PROMPT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Found: $redacted

If intentional (e.g., testing an API):
  → Type "proceed" or "continue" to allow

Consider instead:
  → Store in .env and reference as \$VAR_NAME
  → Secrets in prompts are saved in history
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
  exit 2
fi

exit 0
