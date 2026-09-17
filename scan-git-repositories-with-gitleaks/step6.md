# Block the next leak at commit time

The pre-commit scan looks at the staged diff. Run what the hook runs, first with a low-entropy fake to see it
ignored, then with a random one to see it caught:

```plain
cd /root/labs/gitleaks
printf 'GITHUB_TOKEN = "ghp_%s"\n' "$(head -c 36 /dev/zero | tr '\0' 'a')" > token.py
git add token.py
gitleaks git --pre-commit --staged --redact --no-banner .
```{{exec}}

Expected: `no leaks found` (all-`a` strings have no entropy).

```plain
printf 'GITHUB_TOKEN = "ghp_%s"\n' "$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 36)" > token.py
git add token.py
gitleaks git --pre-commit --staged --redact --verbose --no-banner .
```{{exec}}

Expected: `RuleID: github-pat` and `leaks found: 1`.

Now make Git run this automatically. The original lab installs the hook through the `pre-commit` framework
(`.pre-commit-config.yaml` with the `gitleaks/gitleaks` repo); that build needs Go and a few minutes, so here the
hook is written directly, which is what the framework generates for you:

```plain
cat > .git/hooks/pre-commit <<'HOOK'
#!/bin/sh
exec gitleaks git --pre-commit --staged --redact --no-banner .
HOOK
chmod +x .git/hooks/pre-commit
git commit -m "add token"; echo "exit=$?"
git log --oneline
```{{exec}}

Expected: the hook prints `leaks found: 1`, the commit is rejected (`exit=1`), and the log still shows three
commits.

**CHECK** verifies that the hook exists and runs Gitleaks, that `token.py` is staged with a random-shaped token,
and that no commit was added.

<details><summary>Solution</summary>

Run the three blocks above in order. The last one writes the hook and attempts the commit that must be rejected.

</details>
