#!/bin/bash
cd /root/labs/gitleaks 2>/dev/null || { echo "repository missing"; exit 1; }
[ -x .git/hooks/pre-commit ] || { echo ".git/hooks/pre-commit is missing or not executable"; exit 1; }
grep -q 'gitleaks' .git/hooks/pre-commit || { echo "the pre-commit hook does not run gitleaks"; exit 1; }
grep -q 'staged' .git/hooks/pre-commit || { echo "the hook should scan the staged diff (--pre-commit --staged)"; exit 1; }
git diff --cached --name-only | grep -q '^token.py$' || { echo "token.py should be staged"; exit 1; }
grep -Eq 'ghp_[A-Za-z0-9]{36}' token.py || { echo "token.py should contain a ghp_ token with 36 random characters"; exit 1; }
grep -Eq 'ghp_a{36}' token.py && { echo "token.py still holds the all-a placeholder; use the random one"; exit 1; }
[ "$(git rev-list --count HEAD)" -eq 3 ] || { echo "the repository should still have exactly 3 commits: the hook must reject the commit"; exit 1; }
git log -1 --format=%s | grep -q 'add token' && { echo "the token commit went through; the hook did not block it"; exit 1; }
echo "ok: the hook blocks the commit and history stays at 3 commits"
