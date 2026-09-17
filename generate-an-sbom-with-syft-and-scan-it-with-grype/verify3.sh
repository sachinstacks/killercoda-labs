#!/bin/bash
cd /root/labs/sbom 2>/dev/null || { echo "/root/labs/sbom missing"; exit 1; }
[ -s gate.txt ] || { echo "gate.txt not found"; exit 1; }
rc=$(grep -E '^critical=[0-9]+$' gate.txt | tail -1 | cut -d= -f2)
rh=$(grep -E '^high=[0-9]+$' gate.txt | tail -1 | cut -d= -f2)
[ -n "$rc" ] && [ -n "$rh" ] || { echo "gate.txt should contain critical=<exit> and high=<exit>"; exit 1; }
grype sbom:./py311.cdx.json --only-fixed --fail-on critical -q >/dev/null 2>&1; ac=$?
grype sbom:./py311.cdx.json --only-fixed --fail-on high -q >/dev/null 2>&1; ah=$?
[ "$rc" = "$ac" ] && [ "$rh" = "$ah" ] || { echo "gate.txt (critical=$rc high=$rh) does not match the real gate results (critical=$ac high=$ah)"; exit 1; }
echo "ok: gate results recorded and reproduced (critical=$ac, high=$ah)"
