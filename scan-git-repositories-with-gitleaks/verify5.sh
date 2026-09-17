#!/bin/bash
cd /root/labs/gitleaks 2>/dev/null || { echo "repository missing"; exit 1; }
[ -s recent.json ] || { echo "recent.json not found"; exit 1; }
head=$(git rev-parse HEAD)
jq -e --arg h "$head" 'type == "array" and length == 1 and .[0].Commit == $h and (.[0].File | endswith("deploy.sh"))' recent.json >/dev/null 2>&1 \
  || { echo "recent.json should contain exactly the one finding from the HEAD commit (deploy.sh)"; exit 1; }
echo "ok: only the newest commit was scanned"
