#!/bin/bash
cd /root/labs/gitleaks 2>/dev/null || { echo "repository missing"; exit 1; }
[ -s gitleaks.sarif ] || { echo "gitleaks.sarif not found"; exit 1; }
jq -e '.version == "2.1.0" and (.runs[0].results | length) == 3' gitleaks.sarif >/dev/null 2>&1 \
  || { echo "gitleaks.sarif should be SARIF 2.1.0 with 3 results"; exit 1; }
if grep -q 'AKIA[A-Z2-7]\{16\}' gitleaks.sarif; then echo "the report contains an unredacted key; use --redact"; exit 1; fi
echo "ok: SARIF report with 3 redacted results"
