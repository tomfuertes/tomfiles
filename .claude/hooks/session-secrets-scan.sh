#!/bin/bash
# SessionStart: Scan tracked git files for existing secrets
# Non-blocking hygiene check - warns via stderr

set -euo pipefail

HOOK_DIR="$(dirname "$0")"
source "$HOOK_DIR/lib/secret-patterns.sh" || { echo "Warning: Cannot load secret patterns library" >&2; exit 0; }

# Only run in git repos
git rev-parse --git-dir &>/dev/null || exit 0

COMBINED=$(get_combined_pattern)
FINDINGS=$(git ls-files -z 2>/dev/null | xargs -0 grep -lE -- "$COMBINED" 2>/dev/null | head -10) || true

if [[ -n "$FINDINGS" ]]; then
  echo "" >&2
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
  echo "⚠️  REPO HYGIENE: Potential secrets in tracked files" >&2
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2

  while IFS= read -r file; do
    LINES=$(grep -nE -- "$COMBINED" "$file" 2>/dev/null | head -3 | cut -d: -f1 | xargs -I{} echo "     Line {}")
    echo "   📄 $file" >&2
    echo "$LINES" >&2
  done <<< "$FINDINGS"

  TOTAL=$(echo "$FINDINGS" | wc -l | tr -d ' ')
  [[ $TOTAL -gt 10 ]] && echo "   ... and more (showing first 10)" >&2

  echo "" >&2
  echo "   Consider rotating these and using .env" >&2
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
  echo "" >&2
fi

exit 0
