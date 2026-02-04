#!/bin/bash
# Ensures .gitignore has the *.local.* pattern for local config files
# and removes the overly broad *local* pattern if present

set -e

[ -f .gitignore ] || exit 0

# Remove overly broad *local* pattern if it exists (exact match only)
if grep -Fxq '*local*' .gitignore; then
  # macOS sed requires '', Linux sed doesn't
  if [[ "$OSTYPE" == darwin* ]]; then
    sed -i '' '/^\*local\*$/d' .gitignore
  else
    sed -i '/^\*local\*$/d' .gitignore
  fi
  echo 'Removed overly broad *local* from .gitignore'
fi

# Add *.local.* pattern if missing
if ! grep -Fq '*.local.*' .gitignore; then
  echo '' >> .gitignore
  echo '# Local overrides (e.g., settings.local.json for machine-specific config)' >> .gitignore
  echo '*.local.*' >> .gitignore
  echo '✓ Added *.local.* to .gitignore'
fi
