# Scan it, then count what matters

Scan the image for HIGH and CRITICAL findings that have a fix available. Unfixable findings are noise for a gate:
nothing you do to the Dockerfile removes them.

```plain
trivy image --severity HIGH,CRITICAL --ignore-unfixed --quiet lab/app:v1
```{{exec}}

Read the summary table: the Debian packages carry most of the findings, including CRITICAL ones in packages the
application never calls (`openssl`, `perl-base`), all with a fixed version in Debian.

Now get the number you will track as a single integer, and keep the JSON report as `report-v1.json`:

```plain
cd /root/labs/trivy
trivy image --severity HIGH,CRITICAL --ignore-unfixed --quiet --format json --output report-v1.json lab/app:v1
jq '[.Results[].Vulnerabilities // [] | length] | add // 0' report-v1.json
```{{exec}}

That is the baseline: Debian packages plus the few Python packages the base image ships. The reference run counted
70; yours will be higher, because advisories only accumulate for an end-of-life image.

**CHECK** verifies that `report-v1.json` is a Trivy report of `lab/app:v1` with fixable HIGH/CRITICAL findings in
it.

<details><summary>Solution</summary>

```plain
cd /root/labs/trivy && trivy image --severity HIGH,CRITICAL --ignore-unfixed --quiet --format json --output report-v1.json lab/app:v1 && jq '[.Results[].Vulnerabilities // [] | length] | add // 0' report-v1.json
```{{exec}}

</details>
