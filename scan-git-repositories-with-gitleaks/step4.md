# Suppress one confirmed false positive

Suppose the `AKIA…` value in the first commit were a fixture that a test needs. Suppress **that occurrence**, by
fingerprint, with a reason. Do not allowlist the file, the rule, or the directory.

The fingerprint is `<commit>:<file>:<rule>:<line>`; take it from the verbose output:

```plain
cd /root/labs/gitleaks
FP=$(gitleaks git --redact --verbose --no-banner . 2>/dev/null | awk '/aws-access-token:2$/ {print $2}')
echo "$FP"
printf '# test fixture, not a real key. Reviewed %s\n%s\n' "$(date +%F)" "$FP" > .gitleaksignore
gitleaks git --redact --no-banner .
```{{exec}}

Expected: `leaks found: 2`. The `generic-api-key` finding for the secret key on the next line is still reported,
which is correct: nothing was decided about it.

**CHECK** re-runs the history scan and verifies that `.gitleaksignore` suppresses exactly the `aws-access-token`
finding and nothing else.

<details><summary>Solution</summary>

```plain
cd /root/labs/gitleaks && FP=$(gitleaks git --redact --verbose --no-banner . 2>/dev/null | awk '/aws-access-token:2$/ {print $2}') && printf '# test fixture, not a real key\n%s\n' "$FP" > .gitleaksignore && gitleaks git --redact --no-banner .
```{{exec}}

</details>
