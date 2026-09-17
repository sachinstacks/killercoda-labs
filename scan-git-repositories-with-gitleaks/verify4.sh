#!/bin/bash
cd /root/labs/gitleaks 2>/dev/null || { echo "repository missing"; exit 1; }
[ -s .gitleaksignore ] || { echo ".gitleaksignore not found"; exit 1; }
first=$(git rev-list --max-parents=0 HEAD)
grep -q "^${first}:settings.py:aws-access-token:2$" .gitleaksignore || { echo ".gitleaksignore should contain the full fingerprint <commit>:settings.py:aws-access-token:2"; exit 1; }
if grep -Eq '^[^#].*(generic-api-key|gitlab-pat)' .gitleaksignore; then echo "only the aws-access-token occurrence should be suppressed"; exit 1; fi
tmp=$(mktemp)
gitleaks git --redact --no-banner --report-format json --report-path "$tmp" . >/dev/null 2>&1
n=$(jq 'length' "$tmp" 2>/dev/null || echo -1); rm -f "$tmp"
[ "$n" -eq 2 ] || { echo "expected 2 findings after suppression, got $n"; exit 1; }
echo "ok: one fingerprint suppressed, 2 findings remain"
