#!/usr/bin/env bash
# Lightweight static checks for a dependency-free HTML site.
set -uo pipefail
FAIL=0

for f in $(git ls-files '*.html'); do
  # every external link must carry rel="noopener"
  if grep -n 'target="_blank"' "$f" | grep -v 'rel="noopener"' >/dev/null 2>&1; then
    echo "LINT  $f: target=\"_blank\" without rel=\"noopener\""; FAIL=1
  fi
  # images need alt attributes
  if grep -oE '<img [^>]*>' "$f" | grep -v 'alt=' >/dev/null 2>&1; then
    echo "LINT  $f: <img> missing alt"; FAIL=1
  fi
  # no inline event handlers other than the sanctioned onerror fallbacks
  if grep -oE 'on(click|load|mouseover)=' "$f" >/dev/null 2>&1; then
    echo "LINT  $f: inline event handler found — bind in JS instead"; FAIL=1
  fi
  # no http:// resources
  if grep -n 'src="http://\|href="http://' "$f" >/dev/null 2>&1; then
    echo "LINT  $f: insecure http:// resource"; FAIL=1
  fi
done

[ "$FAIL" -eq 0 ] && echo "lint: clean"
exit $FAIL
