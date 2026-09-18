#!/bin/bash
# Prepares the environment: jq, Helm, the Kyverno install (infrastructure, not
# the lesson) and the two images the pods use. Labelling the namespace, the
# pods and the policy are the task and are not done here.
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
install_sachinstacks_identity 'policy' 'Enforce Pod Security with PSA and Kyverno'
# --- end SachinStacks terminal identity ---
export DEBIAN_FRONTEND=noninteractive
KYVERNO_CHART_VERSION=3.9.1
mkdir -p /root/labs/policy

if ! command -v jq >/dev/null 2>&1; then
  apt-get update -qq && apt-get install -y -qq jq >/dev/null 2>&1 \
    || { curl -sSfL -o /usr/local/bin/jq https://github.com/jqlang/jq/releases/latest/download/jq-linux-amd64 && chmod +x /usr/local/bin/jq; }
fi
if ! command -v helm >/dev/null 2>&1; then
  for _ in 1 2 3; do curl -sSfL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash && break; sleep 5; done
fi

for _ in $(seq 1 60); do kubectl get --raw /readyz >/dev/null 2>&1 && break; sleep 2; done
touch /tmp/.lab-ready   # the learner can start Step 1 (Pod Security needs nothing installed)

# Pull the pod images now so the pods in Steps 2 and 4 start quickly.
( crictl pull docker.io/nginxinc/nginx-unprivileged:1.27 || ctr -n k8s.io images pull docker.io/nginxinc/nginx-unprivileged:1.27 ) >/dev/null 2>&1 &
( crictl pull docker.io/nginxinc/nginx-unprivileged:latest || ctr -n k8s.io images pull docker.io/nginxinc/nginx-unprivileged:latest ) >/dev/null 2>&1 &

# Kyverno takes a few minutes to pull and start; install it while Steps 1 and 2 are being worked on.
helm repo add kyverno https://kyverno.github.io/kyverno/ >/dev/null 2>&1
helm repo update >/dev/null 2>&1
for _ in 1 2 3; do
  helm upgrade --install kyverno kyverno/kyverno --namespace kyverno --create-namespace \
    --version "$KYVERNO_CHART_VERSION" --timeout 15m && break
  sleep 10
done
kubectl -n kyverno rollout status deploy --timeout=900s
touch /tmp/.kyverno-ready
