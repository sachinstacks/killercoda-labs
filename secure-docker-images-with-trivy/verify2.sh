#!/bin/bash
# report-v1.json is a Trivy JSON report of lab/app:v1 and contains findings.
R=/root/labs/trivy/report-v1.json
[ -s "$R" ] || { echo "report-v1.json not found in /root/labs/trivy"; exit 1; }
jq -e '.ArtifactName == "lab/app:v1"' "$R" >/dev/null 2>&1 || { echo "report-v1.json is not a Trivy report of lab/app:v1"; exit 1; }
n=$(jq '[.Results[].Vulnerabilities // [] | length] | add // 0' "$R")
[ "$n" -gt 0 ] || { echo "report-v1.json lists no findings; scan with --severity HIGH,CRITICAL --ignore-unfixed"; exit 1; }
echo "ok: baseline is $n fixable HIGH/CRITICAL findings"
