#!/bin/bash
# Prepares the environment: jq and a working directory. The namespace, the
# identity, the role and the binding are the task and are not created here.
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
