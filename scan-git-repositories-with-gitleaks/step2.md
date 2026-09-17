# Scan the working tree

`dir` mode sees only what is on disk right now. Write its report as `dir.json`:

```plain
cd /root/labs/gitleaks
gitleaks dir --redact --verbose --no-banner .
gitleaks dir --redact --no-banner --report-format json --report-path dir.json .
jq 'length' dir.json
```{{exec}}

Expected: **1** finding, the GitLab token in `deploy.sh`. The AWS keys are gone from the working tree, so `dir` mode
cannot see them.

Notice what neither mode reported: the database password in `DATABASE_URL`. It is short, low-entropy and matches
no rule. Gitleaks is a pattern-and-entropy scanner, not a mind reader; a connection string with a weak password is
something a reviewer catches, or a custom rule.

**CHECK** verifies that `dir.json` contains exactly the one `gitlab-pat` finding in `deploy.sh`.

<details><summary>Solution</summary>

```plain
cd /root/labs/gitleaks && gitleaks dir --redact --no-banner --report-format json --report-path dir.json .
```{{exec}}

</details>
