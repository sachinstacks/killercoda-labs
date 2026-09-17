# Generate the SBOM in two formats

The `registry:` source pulls layers directly from Docker Hub, so this works on a CI runner with no container
runtime at all. Write a CycloneDX and an SPDX document, and print the table:

```plain
cd /root/labs/sbom
syft registry:python:3.11-slim-bookworm \
  -o cyclonedx-json=py311.cdx.json \
  -o spdx-json=py311.spdx.json \
  -o table
```{{exec}}

(The "Simple Launcher" entries are the Windows `.exe` launchers that ship inside the `pip` package; Syft identifies
them from their embedded version resource. They are noise on Linux and a good first candidate for an ignore rule.)

Look at what was written:

```plain
jq -r '.bomFormat, .specVersion, (.components | length)' py311.cdx.json
jq -r '.components[] | .type' py311.cdx.json | sort | uniq -c
jq -r '.spdxVersion, (.packages | length)' py311.spdx.json
```{{exec}}

Expected: `CycloneDX`, a spec version, and a few thousand components — but only about 140 of them are packages
(`application`, `library`, `operating-system`); the rest are `file` entries, which Syft includes for images so an
SBOM consumer can trace a package to what it put on disk. The SPDX document has the packages without the file
entries, which is why it is a tenth of the size. Both are valid inventories; which one you keep depends on what
consumes it.

**CHECK** verifies that both documents exist, are valid CycloneDX / SPDX 2.3 output for this image, and that the
CycloneDX document has more than 100 non-file components.

<details><summary>Solution</summary>

```plain
cd /root/labs/sbom && syft registry:python:3.11-slim-bookworm -o cyclonedx-json=py311.cdx.json -o spdx-json=py311.spdx.json -o table
```{{exec}}

</details>
