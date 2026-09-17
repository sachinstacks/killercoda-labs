# Scan history

`gitleaks git` walks every commit. Run it verbosely first, with `--redact` so the values are not echoed:

```plain
cd /root/labs/gitleaks
gitleaks git --redact --verbose --no-banner .
```{{exec}}

Expected: **3** findings, `gitlab-pat` in `deploy.sh`, and `aws-access-token` plus `generic-api-key` in
`settings.py` — the last two in the *first* commit even though `HEAD` no longer contains the keys. That is the whole
point of history scanning.

Now keep the result as a JSON report named `history.json`:

```plain
gitleaks git --redact --no-banner --report-format json --report-path history.json .
jq 'length' history.json
jq -r '.[] | [.RuleID, .File, .Commit[0:8]] | @tsv' history.json
```{{exec}}

**CHECK** verifies that `history.json` is a Gitleaks report with the three expected rules and that two of the
findings sit in a commit that is no longer `HEAD`.

<details><summary>Solution</summary>

```plain
cd /root/labs/gitleaks && gitleaks git --redact --no-banner --report-format json --report-path history.json .
```{{exec}}

</details>
