#!/bin/bash
# Prepares the environment: jq and a working directory. The namespace, the
# identity, the role and the binding are the task and are not created here.
set -x

# --- SachinStacks terminal identity (shared block, identical in every scenario) ---
# Installs the banner helper and the prompt. The banner prints exactly once, after
# /tmp/.lab-ready exists: from the foreground script in the normal case, or from
# the prompt hook below at the first prompt after readiness if the platform did
# not type the foreground script into the terminal. Nothing here touches the lab.
install_sachinstacks_identity() { # short-name "lab title"
  cat > /usr/local/bin/sachinstacks-banner <<'BANNER'
#!/bin/bash
# Usage: sachinstacks-banner "<lab title>". Prints the SachinStacks lab banner once
# (a flag file makes later calls no-ops), in colour when the terminal supports it.
flag=/tmp/.sachinstacks-banner-shown
[ -f "$flag" ] && exit 0
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
touch "$flag"
BANNER
  chmod +x /usr/local/bin/sachinstacks-banner
  # Prompt and banner hook for every interactive shell (the one already open
  # sources .bashrc when it starts; new tabs do the same).
  if ! grep -q 'sachinstacks_lab_hook' /root/.bashrc 2>/dev/null; then
    cat >> /root/.bashrc <<BASHRC

# SachinStacks lab identity
PS1="[sachinstacks@$1 \\W]# "
sachinstacks_lab_hook() {
  if [ -f /tmp/.lab-ready ] && [ ! -f /tmp/.sachinstacks-banner-shown ]; then sachinstacks-banner "$2"; fi
}
PROMPT_COMMAND="sachinstacks_lab_hook\${PROMPT_COMMAND:+;\$PROMPT_COMMAND}"
BASHRC
  fi
}
install_sachinstacks_identity 'rbac' 'Least-Privilege Kubernetes RBAC for a Deployer'
# --- end SachinStacks terminal identity ---
export DEBIAN_FRONTEND=noninteractive
mkdir -p /root/labs/rbac
if ! command -v jq >/dev/null 2>&1; then
  apt-get update -qq && apt-get install -y -qq jq >/dev/null 2>&1 \
    || { curl -sSfL -o /usr/local/bin/jq https://github.com/jqlang/jq/releases/latest/download/jq-linux-amd64 && chmod +x /usr/local/bin/jq; }
fi
# Wait until the API server answers so the first kubectl in the scenario does not race the cluster.
for _ in $(seq 1 60); do kubectl get --raw /readyz >/dev/null 2>&1 && break; sleep 2; done
touch /tmp/.lab-ready
