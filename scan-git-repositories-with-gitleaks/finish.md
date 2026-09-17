# Done

You have seen the four things Gitleaks is for: history scanning finds secrets that a later commit "removed",
working-tree scanning finds what is live now, a fingerprint suppresses one reviewed occurrence without widening the
allowlist, and a staged-diff scan at commit time stops the next leak before it exists.

## What remediation looks like for real

Had these been real credentials, the order of operations is: rotate the credential, confirm nothing else uses it,
then remove it from the working tree. Rewriting history with `git filter-repo` and force-pushing is optional hygiene
for public repositories, done only after everyone with a clone has been told, and it never un-leaks anything: CI
caches, forks and backups still have the old commit.

## On your own machine

Install the hook through the `pre-commit` framework so it is versioned with the repository:

```plain
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.30.1
    hooks:
      - id: gitleaks
```{{copy}}

Every value used in this environment was a random fake generated at start; the environment is discarded when you
leave it.

## Further reading

Read the full engineering notes and explanation on sachinchaurasiya.com:
[Scan Git Repositories with Gitleaks](https://sachinchaurasiya.com/labs/scan-git-repositories-with-gitleaks).
