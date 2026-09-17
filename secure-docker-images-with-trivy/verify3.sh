#!/bin/bash
L=/root/labs/trivy
docker image inspect lab/app:v2 >/dev/null 2>&1 || { echo "lab/app:v2 does not exist yet"; exit 1; }
docker image inspect lab/app:v2 --format '{{range .Config.Env}}{{println .}}{{end}}' | grep -q '^PYTHON_VERSION=3\.13' \
  || { echo "lab/app:v2 must be built from python:3.13-slim"; exit 1; }
user=$(docker image inspect lab/app:v2 --format '{{.Config.User}}')
[ "$user" = "app" ] || [ "$user" = "10001" ] || { echo "lab/app:v2 must run as the app user (USER app)"; exit 1; }
[ -s "$L/report-v2.json" ] || { echo "report-v2.json not found"; exit 1; }
jq -e '.ArtifactName == "lab/app:v2"' "$L/report-v2.json" >/dev/null 2>&1 || { echo "report-v2.json is not a report of lab/app:v2"; exit 1; }
v1=$(jq '[.Results[].Vulnerabilities // [] | length] | add // 0' "$L/report-v1.json" 2>/dev/null || echo 0)
v2=$(jq '[.Results[].Vulnerabilities // [] | length] | add // 0' "$L/report-v2.json")
[ "$v2" -lt "$v1" ] || { echo "expected fewer findings in v2 ($v2) than in v1 ($v1)"; exit 1; }
echo "ok: v1=$v1 → v2=$v2, and lab/app:v2 runs as app"
