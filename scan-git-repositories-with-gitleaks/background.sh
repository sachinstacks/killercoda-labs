#!/bin/bash
# Prepares the environment: Gitleaks, jq and a throwaway repository seeded with
# FAKE secrets. The values are generated here, at random, with the right shape;
# none of them is a real credential and none exists outside this environment.
set -x
export DEBIAN_FRONTEND=noninteractive
GITLEAKS_VERSION=8.30.1
LAB=/root/labs/gitleaks

install_jq() {
  command -v jq >/dev/null 2>&1 && return 0
  apt-get update -qq && apt-get install -y -qq jq >/dev/null 2>&1 && return 0
  curl -sSfL -o /usr/local/bin/jq https://github.com/jqlang/jq/releases/latest/download/jq-linux-amd64 && chmod +x /usr/local/bin/jq
}
install_gitleaks() {
  command -v gitleaks >/dev/null 2>&1 && return 0
  for i in 1 2 3; do
    curl -sSfL "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz" \
      | tar -xz -C /usr/local/bin gitleaks && chmod +x /usr/local/bin/gitleaks && return 0
    sleep 5
  done
  return 1
}

install_jq
install_gitleaks

git config --global user.name "Lab User"
git config --global user.email "lab@example.invalid"
git config --global init.defaultBranch main

# Seed the repository with leaks. Gitleaks skips documented placeholders such as
# AKIAIOSFODNN7EXAMPLE and low-entropy strings, so the values must be random.
rand() { LC_ALL=C tr -dc "$1" < /dev/urandom | head -c "$2"; }
AKID="AKIA$(rand 'A-Z2-7' 16)"
ASEC="$(rand 'A-Za-z0-9' 40)"
rm -rf "$LAB" && mkdir -p "$LAB" && cd "$LAB"
git init -q -b main
cat > settings.py <<PY
DATABASE_URL = "postgres://app:s3cr3t-pa55@db.internal:5432/app"
AWS_ACCESS_KEY_ID = "$AKID"
AWS_SECRET_ACCESS_KEY = "$ASEC"
PY
git add settings.py && git commit -qm "add settings"

# "Fix" it the wrong way: remove the keys in a new commit. They stay in history.
sed -i.bak "s/$AKID/REDACTED/; s#$ASEC#REDACTED#" settings.py
rm settings.py.bak && git commit -qam "remove keys"

printf '#!/bin/sh\nexport GITLAB_TOKEN="glpat-%s"\n' "$(rand 'A-Za-z0-9' 20)" > deploy.sh
git add deploy.sh && git commit -qm "deploy script"

touch /tmp/.lab-ready
