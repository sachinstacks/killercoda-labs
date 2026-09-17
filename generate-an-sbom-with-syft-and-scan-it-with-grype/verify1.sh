#!/bin/bash
cd /root/labs/sbom 2>/dev/null || { echo "/root/labs/sbom missing"; exit 1; }
[ -s py311.cdx.json ] || { echo "py311.cdx.json not found"; exit 1; }
[ -s py311.spdx.json ] || { echo "py311.spdx.json not found"; exit 1; }
jq -e '.bomFormat == "CycloneDX"' py311.cdx.json >/dev/null 2>&1 || { echo "py311.cdx.json is not a CycloneDX document"; exit 1; }
jq -e '.spdxVersion == "SPDX-2.3"' py311.spdx.json >/dev/null 2>&1 || { echo "py311.spdx.json is not SPDX-2.3"; exit 1; }
jq -e '(.metadata.component.name // "") | test("python")' py311.cdx.json >/dev/null 2>&1 || { echo "the SBOM should describe the python image"; exit 1; }
n=$(jq '[.components[] | select(.type != "file")] | length' py311.cdx.json)
[ "$n" -gt 100 ] || { echo "expected more than 100 non-file components, got $n"; exit 1; }
echo "ok: CycloneDX ($n packages) and SPDX-2.3 documents written"
