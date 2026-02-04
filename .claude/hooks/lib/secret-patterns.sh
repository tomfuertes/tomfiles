# Shared secret detection patterns
# Source this file: source "$(dirname "$0")/lib/secret-patterns.sh"

SECRET_PATTERNS=(
  # AWS
  'AKIA[0-9A-Z]{16}'
  'aws_secret_access_key\s*[=:]\s*[A-Za-z0-9/+=]{40}'

  # GitHub
  'ghp_[a-zA-Z0-9]{36}'
  'github_pat_[a-zA-Z0-9]{22}_[a-zA-Z0-9]{59}'
  'gho_[a-zA-Z0-9]{36}'
  'ghu_[a-zA-Z0-9]{36}'
  'ghs_[a-zA-Z0-9]{36}'
  'ghr_[a-zA-Z0-9]{36}'

  # Stripe
  'sk_live_[a-zA-Z0-9]{24,}'
  'sk_test_[a-zA-Z0-9]{24,}'
  'rk_live_[a-zA-Z0-9]{24,}'
  'rk_test_[a-zA-Z0-9]{24,}'

  # OpenAI
  'sk-[a-zA-Z0-9]{48}'
  'sk-proj-[a-zA-Z0-9_-]{80,}'

  # Anthropic
  'sk-ant-[a-zA-Z0-9_-]{80,}'

  # Slack
  'xox[baprs]-[0-9]{10,13}-[0-9]{10,13}-[a-zA-Z0-9]{24}'

  # Private keys
  '-----BEGIN RSA PRIVATE KEY-----'
  '-----BEGIN OPENSSH PRIVATE KEY-----'
  '-----BEGIN EC PRIVATE KEY-----'
  '-----BEGIN PGP PRIVATE KEY BLOCK-----'

  # Database URLs with credentials
  'mongodb(\+srv)?://[^:]+:[^@]+@'
  'postgres(ql)?://[^:]+:[^@]+@'
  'mysql://[^:]+:[^@]+@'
  'redis://[^:]+:[^@]+@'

  # npm
  'npm_[a-zA-Z0-9]{36}'

  # Heroku
  '[hH]eroku.*[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}'

  # Twilio
  'SK[a-fA-F0-9]{32}'

  # SendGrid
  'SG\.[a-zA-Z0-9_-]{22}\.[a-zA-Z0-9_-]{43}'

  # Mailchimp
  '[a-f0-9]{32}-us[0-9]{1,2}'
)

# Helper: check content for secrets, returns matched pattern or empty
check_for_secrets() {
  local content="$1"
  for pattern in "${SECRET_PATTERNS[@]}"; do
    if echo "$content" | grep -qE -- "$pattern"; then
      echo "$pattern"
      return 0
    fi
  done
  return 1
}

# Helper: get redacted match
get_redacted_match() {
  local content="$1"
  local pattern="$2"
  local matched=$(echo "$content" | grep -oE -- "$pattern" | head -1)
  echo "${matched:0:10}..."
}

# Helper: combined pattern for grep -E
get_combined_pattern() {
  local IFS='|'
  echo "${SECRET_PATTERNS[*]}"
}
