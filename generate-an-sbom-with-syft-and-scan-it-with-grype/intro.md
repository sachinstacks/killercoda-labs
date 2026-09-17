# Generate an SBOM with Syft and Scan It with Grype

**Level:** intermediate · **Time:** about 35 minutes · **Environment:** Ubuntu (4 GB)

An SBOM is the inventory that lets you answer "are we affected?" in minutes when a new CVE drops, without pulling
the image again. In this scenario you generate one for a real image, `python:3.11-slim-bookworm`, scan it with
Grype, set a gate that fails on the findings you can act on, and compare the SBOM scan with a direct image scan.

The reference run used Syft 1.51.1 and Grype 0.118.0 with a database built on 2026-09-12: 287 matches, 29 with a
fix available, 6 of them High. Your numbers will have drifted upward as new CVEs were published, which is the point
of the last section.

## What is being prepared

A background script installs Syft 1.51.1, Grype 0.118.0 and `jq`, then downloads the Grype vulnerability
database once (it is large, which is why it is done for you). The terminal tells you when it is done.

The original lab runs both tools from their official container images; here they are binaries on the `PATH`, so
the paths in the commands are `./` instead of the mounted `/out/`. Everything else is identical.

Each step ends with a **CHECK** that inspects the SBOM and report files you write, and has a collapsed
**Solution**. Click **START** when the terminal says it is ready.
