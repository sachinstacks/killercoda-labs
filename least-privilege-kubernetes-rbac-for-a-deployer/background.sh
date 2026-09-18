#!/bin/bash
# Prepares the environment: jq and a working directory. The namespace, the
# identity, the role and the binding are the task and are not created here.
set -x

# --- SachinStacks terminal identity (shared block, identical in every scenario) ---
# Installs the banner helper the foreground script prints once the environment is
# ready, and a subtle prompt for shells opened later. Nothing here touches the lab.
install_sachinstacks_identity() { # short-name
  cat > /usr/local/bin/sachinstacks-banner <<'BANNER'
#!/bin/bash
# Usage: sachinstacks-banner "<lab title>". Prints the SachinStacks lab banner once,
# in colour when the terminal supports it. Output goes to the interactive terminal only.
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
  # Prompt for shells opened after start (new terminal tabs); the foreground
  # script sets the same prompt in the shell that is already open.
  grep -q 'sachinstacks@' /root/.bashrc 2>/dev/null || \
    printf '\n# SachinStacks lab prompt\nPS1="[sachinstacks@%s \\W]# "\n' "$1" >> /root/.bashrc
}
install_sachinstacks_identity 'rbac'
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
