# Scan Git Repositories with Gitleaks

**Level:** beginner · **Time:** about 25 minutes · **Environment:** Ubuntu

By the end of this scenario you will know what Gitleaks detects and what it deliberately ignores, how a secret
survives the "remove it in a new commit" fix, how findings are reported and suppressed, and how to stop the next
one before it reaches history. Everything runs with Gitleaks 8.30.1.

## What is being prepared

A background script installs Gitleaks and `jq`, then seeds a throwaway repository at `/root/labs/gitleaks` with
three commits:

1. `add settings`: a `settings.py` with a database URL, an AWS access key ID and an AWS secret access key
2. `remove keys`: the keys replaced by `REDACTED` — the wrong fix, because they stay in history
3. `deploy script`: a `deploy.sh` that exports a GitLab personal access token

**All of these values are fake.** They are generated at random, with the right *shape*, when the environment
starts. That matters: Gitleaks ships with a built-in allowlist for documented placeholders such as Amazon's
`AKIAIOSFODNN7EXAMPLE`, and it skips strings with the right prefix but no entropy (`ghp_aaaaaaaa…`). A lab seeded
with those would prove nothing.

Have a look at what was seeded:

```plain
cd /root/labs/gitleaks && git log --oneline && cat settings.py deploy.sh
```{{exec}}

Each step ends with a **CHECK** that inspects the reports you write and the state of the repository, and has a
collapsed **Solution**. Click **START** when the terminal says it is ready.
