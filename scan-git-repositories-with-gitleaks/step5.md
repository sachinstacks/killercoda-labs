# Scan only new commits

CI on a merge request should not re-scan a year of history on every push. `--log-opts` passes a range to
`git log`; write the report of the last commit only as `recent.json`:

```plain
cd /root/labs/gitleaks
gitleaks git --redact --no-banner --log-opts="HEAD~1..HEAD" --report-format json --report-path recent.json .
jq -r '.[] | [.RuleID, .File, .Commit[0:8]] | @tsv' recent.json
```{{exec}}

Expected: `1 commits scanned`, one finding, in `deploy.sh`. In a pipeline the range is `origin/main..HEAD` after
fetching the target branch; the full-history scan belongs on the default branch and on a nightly schedule.

**CHECK** verifies that `recent.json` contains only the finding from the `HEAD` commit.

<details><summary>Solution</summary>

```plain
cd /root/labs/gitleaks && gitleaks git --redact --no-banner --log-opts="HEAD~1..HEAD" --report-format json --report-path recent.json .
```{{exec}}

</details>
