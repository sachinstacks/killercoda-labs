# Scan the SBOM with Grype

Scan the CycloneDX document, not the image, and keep the JSON result:

```plain
cd /root/labs/sbom
grype sbom:./py311.cdx.json -o json --file grype-py311.json
jq '.matches | length' grype-py311.json
jq -r '[.matches[].vulnerability.severity] | group_by(.) | map("\(.[0]): \(length)") | join(", ")' grype-py311.json
```{{exec}}

A few hundred matches in a slim image is normal for a Debian base that has been out for a while. It is also useless
as a gate. Ask a narrower question:

```plain
jq '[.matches[] | select(.vulnerability.fix.state == "fixed")] | length' grype-py311.json
jq -r '[.matches[] | select(.vulnerability.fix.state == "fixed") | .vulnerability.severity]
  | group_by(.) | map("\(.[0]): \(length)") | join(", ")' grype-py311.json
```{{exec}}

The findings with a fixed version available are the ones a rebuild can remove.

**CHECK** verifies that `grype-py311.json` is a Grype scan of the SBOM file with matches in it.

<details><summary>Solution</summary>

```plain
cd /root/labs/sbom && grype sbom:./py311.cdx.json -o json --file grype-py311.json
```{{exec}}

</details>
