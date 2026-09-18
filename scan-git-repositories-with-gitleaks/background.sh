#!/bin/bash
# Prepares the environment: Gitleaks, jq and a throwaway repository seeded with
# FAKE secrets. The values are generated here, at random, with the right shape;
# none of them is a real credential and none exists outside this environment.
set -x

# --- SachinStacks terminal identity (shared block, identical in every scenario) ---
# Installs the banner helper and, through .bashrc, the prompt and a hook that prints
# the banner once per interactive shell at its first prompt after /tmp/.lab-ready
# exists. Killercoda's terminal sometimes reconnects and starts a fresh shell while
# the foreground script is still running in the old one; the hook covers that shell
# too. Nothing here touches the lab.
install_sachinstacks_identity() { # short-name "lab title"
  cat > /usr/local/bin/sachinstacks-banner <<'BANNER'
#!/bin/bash
# Usage: sachinstacks-banner "<lab title>". Prints the SachinStacks lab banner, in
# colour when the terminal supports it. Callers decide when (see .bashrc hook).
title="${1:-SachinStacks lab}"
if [ -t 1 ] && command -v tput >/dev/null 2>&1 && [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then
  c="$(tput bold)$(tput setaf 6)"; r="$(tput sgr0)"
else
  c=""; r=""
fi
line="------------------------------------------------------------"
printf '%s\n' "$line"
printf ' %sSACHINSTACKS LAB%s\n' "$c" "$r"
printf ' %s%s%s\n' "$c" "$title" "$r"
printf '\n'
printf ' sachinchaurasiya.com\n'
printf ' Environment hosted on Killercoda\n'
printf '%s\n' "$line"
BANNER
  chmod +x /usr/local/bin/sachinstacks-banner
  if ! grep -q 'sachinstacks_lab_hook' /root/.bashrc 2>/dev/null; then
    cat >> /root/.bashrc <<BASHRC

# SachinStacks lab identity: prompt, and the banner once per shell after setup is ready
PS1="[sachinstacks@$1 \\W]# "
sachinstacks_lab_hook() {
  if [ -z "\$SACHINSTACKS_BANNER_SHOWN" ] && [ -f /tmp/.lab-ready ]; then
    SACHINSTACKS_BANNER_SHOWN=1
    sachinstacks-banner "$2"
  fi
}
PROMPT_COMMAND="sachinstacks_lab_hook\${PROMPT_COMMAND:+;\$PROMPT_COMMAND}"
BASHRC
  fi
}
install_sachinstacks_identity 'gitleaks' 'Scan Git Repositories with Gitleaks'
# --- end SachinStacks terminal identity ---
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
  for _ in 1 2 3; do
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
