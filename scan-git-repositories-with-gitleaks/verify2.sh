#!/bin/bash
cd /root/labs/gitleaks 2>/dev/null || { echo "repository missing"; exit 1; }
[ -s dir.json ] || { echo "dir.json not found; write it with gitleaks dir --report-format json --report-path dir.json"; exit 1; }
jq -e 'type == "array" and length == 1 and .[0].RuleID == "gitlab-pat" and (.[0].File | endswith("deploy.sh"))' dir.json >/dev/null 2>&1 \
  || { echo "dir.json should contain exactly one gitlab-pat finding in deploy.sh"; exit 1; }
echo "ok: working-tree scan reports the one live token"
