#!/usr/bin/env bash
# Zero-trust secret scan. Exits non-zero if a candidate secret is staged.
set -uo pipefail

FILES=$(git diff --cached --name-only --diff-filter=ACM)
[ -z "$FILES" ] && { echo "scan-secrets: nothing staged"; exit 0; }

PATTERNS=(
  'AKIA[0-9A-Z]{16}'                       # AWS access key id
  'aws_secret_access_key'                  # AWS secret
  'ghp_[A-Za-z0-9]{36}'                    # GitHub PAT
  'github_pat_[A-Za-z0-9_]{22,}'           # GitHub fine-grained PAT
  'sk-[A-Za-z0-9]{20,}'                    # OpenAI-style key
  'sk-ant-[A-Za-z0-9_\-]{20,}'             # Anthropic key
  'AIza[0-9A-Za-z_\-]{35}'                 # Google API key
  'xox[baprs]-[0-9A-Za-z\-]{10,}'          # Slack token
  '-----BEGIN [A-Z ]*PRIVATE KEY-----'     # private key block
  '(api[_-]?key|apikey|secret|passwd|password|token)[[:space:]]*[:=][[:space:]]*["\x27][^"\x27]{8,}'
)

FAIL=0
# Files that legitimately contain the patterns themselves (the scanners).
SELF="scripts/scan-secrets.sh .github/workflows/ci.yml RULES.md"

for f in $FILES; do
  [ -f "$f" ] || continue
  case "$f" in *.jpg|*.jpeg|*.png|*.gif|*.webp|*.mp4|*.mov|*.woff|*.woff2) continue ;; esac
  case " $SELF " in *" $f "*) echo "skip (scanner self)  $f"; continue ;; esac
  for p in "${PATTERNS[@]}"; do
    if git show ":$f" | grep -nEI "$p" >/dev/null 2>&1; then
      echo "BLOCKED  possible secret in $f  (pattern: $p)"
      FAIL=1
    fi
  done
done

# .env must never be staged
echo "$FILES" | grep -qE '(^|/)\.env' && { echo "BLOCKED  .env file is staged"; FAIL=1; }

if [ "$FAIL" -ne 0 ]; then
  echo ""
  echo "Commit rejected by zero-trust secret scan."
  echo "Move the value into an environment variable, then re-stage."
  exit 1
fi
echo "scan-secrets: clean"
