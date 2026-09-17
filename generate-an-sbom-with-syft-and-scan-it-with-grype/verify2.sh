#!/bin/bash
cd /root/labs/sbom 2>/dev/null || { echo "/root/labs/sbom missing"; exit 1; }
[ -s grype-py311.json ] || { echo "grype-py311.json not found"; exit 1; }
jq -e '.descriptor.name == "grype"' grype-py311.json >/dev/null 2>&1 || { echo "grype-py311.json is not a Grype JSON report"; exit 1; }
jq -e '(.source.target | tostring) | test("cdx|cyclonedx|py311")' grype-py311.json >/dev/null 2>&1 \
  || { echo "the scan target should be the SBOM file (sbom:./py311.cdx.json), not the image"; exit 1; }
n=$(jq '.matches | length' grype-py311.json)
[ "$n" -gt 0 ] || { echo "no matches in the report"; exit 1; }
echo "ok: $n matches from the SBOM scan"
