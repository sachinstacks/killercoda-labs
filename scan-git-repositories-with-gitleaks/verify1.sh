#!/bin/bash
cd /root/labs/gitleaks 2>/dev/null || { echo "repository missing"; exit 1; }
[ -s history.json ] || { echo "history.json not found; write it with --report-format json --report-path history.json"; exit 1; }
jq -e 'type == "array" and length == 3' history.json >/dev/null 2>&1 || { echo "history.json should contain exactly 3 findings"; exit 1; }
for rule in gitlab-pat aws-access-token generic-api-key; do
  jq -e --arg r "$rule" 'map(.RuleID) | index($r)' history.json >/dev/null 2>&1 || { echo "finding for rule $rule missing"; exit 1; }
done
head=$(git rev-parse HEAD)
jq -e --arg h "$head" '[.[] | select(.File == "settings.py" and .Commit != $h)] | length == 2' history.json >/dev/null 2>&1 \
  || { echo "the two settings.py findings should come from a commit that is no longer HEAD"; exit 1; }
echo "ok: 3 findings in history, 2 of them from an old commit"
