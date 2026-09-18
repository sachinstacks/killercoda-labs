#!/bin/bash
cd /root/labs/sbom 2>/dev/null || { echo "/root/labs/sbom missing"; exit 1; }
[ -s grype-direct.json ] || { echo "grype-direct.json not found"; exit 1; }
# A direct image scan records the image layers; a scan of an SBOM does not.
jq -e '.descriptor.name == "grype" and .source.type == "image" and (.source.target.layers | type == "array") and (.source.target.userInput // "" | test("python"))' grype-direct.json >/dev/null 2>&1 \
  || { echo "grype-direct.json should be a direct image scan (grype registry:python:3.11-slim-bookworm)"; exit 1; }
a=$(jq '.matches | length' grype-direct.json); b=$(jq '.matches | length' grype-py311.json 2>/dev/null || echo 0)
d=$(( a > b ? a - b : b - a ))
[ "$d" -le 5 ] || { echo "direct scan ($a) and SBOM scan ($b) differ by $d matches; they should be the same inventory"; exit 1; }
echo "ok: direct scan $a vs SBOM scan $b"
