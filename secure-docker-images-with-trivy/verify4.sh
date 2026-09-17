#!/bin/bash
L=/root/labs/trivy
docker image inspect lab/app:v3 >/dev/null 2>&1 || { echo "lab/app:v3 does not exist yet"; exit 1; }
docker image history --no-trunc lab/app:v3 | grep -q 'apt-get upgrade' || { echo "lab/app:v3 must run apt-get upgrade in a RUN layer"; exit 1; }
[ -s "$L/report-v3.json" ] || { echo "report-v3.json not found"; exit 1; }
jq -e '.ArtifactName == "lab/app:v3"' "$L/report-v3.json" >/dev/null 2>&1 || { echo "report-v3.json is not a report of lab/app:v3"; exit 1; }
os=$(jq '[.Results[] | select(.Class == "os-pkgs") | .Vulnerabilities // [] | length] | add // 0' "$L/report-v3.json")
[ "$os" -eq 0 ] || { echo "lab/app:v3 still has $os fixable HIGH/CRITICAL findings in Debian packages"; exit 1; }
echo "ok: Debian packages are clean in lab/app:v3"
