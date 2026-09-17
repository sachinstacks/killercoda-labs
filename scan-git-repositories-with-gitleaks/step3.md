# Report formats

SARIF is what code-hosting platforms and IDEs ingest; JSON is easier for scripts. Because `--redact` is used,
neither file contains the secret values, only the locations.

```plain
cd /root/labs/gitleaks
gitleaks git --redact --no-banner --report-format sarif --report-path gitleaks.sarif .
jq '.runs[0].results | length' gitleaks.sarif
jq -r '.runs[0].results[0] | [.ruleId, .locations[0].physicalLocation.artifactLocation.uri, .partialFingerprints.commitSha] | @tsv' gitleaks.sarif
```{{exec}}

Expected: `3`, then one line with a rule id, `settings.py` or `deploy.sh`, and a commit hash.

**CHECK** verifies that `gitleaks.sarif` is a SARIF 2.1.0 log with three redacted results.

<details><summary>Solution</summary>

```plain
cd /root/labs/gitleaks && gitleaks git --redact --no-banner --report-format sarif --report-path gitleaks.sarif .
```{{exec}}

</details>
