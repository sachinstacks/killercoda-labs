# Compare with a direct image scan

Scan the image itself and compare the match counts:

```plain
cd /root/labs/sbom
grype registry:python:3.11-slim-bookworm -o json --file grype-direct.json
jq '.matches | length' grype-direct.json grype-py311.json
```{{exec}}

Expected: the same number (they may differ by a few if the database updated between runs), because Grype's direct
scan runs Syft internally to build the same inventory. The only difference is that the SBOM scan needed no
registry access, no image and no container runtime. That is what makes it possible to answer "does last month's
release contain the package in today's advisory?" from a laptop, during an incident, in seconds.

Finally, note the database build date. Re-running the SBOM scan next week gives higher counts without a single
byte of the SBOM changing:

```plain
grype db status
```{{exec}}

**CHECK** verifies that `grype-direct.json` is a scan of the image and reports the same number of matches as the
SBOM scan.

<details><summary>Solution</summary>

```plain
cd /root/labs/sbom && grype registry:python:3.11-slim-bookworm -o json --file grype-direct.json
```{{exec}}

</details>
