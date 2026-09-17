#!/bin/bash
# Prepares the environment: jq, Helm, the Kyverno install (infrastructure, not
# the lesson) and the two images the pods use. Labelling the namespace, the
# pods and the policy are the task and are not done here.
set -x
export DEBIAN_FRONTEND=noninteractive
KYVERNO_CHART_VERSION=3.9.1
mkdir -p /root/labs/policy

if ! command -v jq >/dev/null 2>&1; then
  apt-get update -qq && apt-get install -y -qq jq >/dev/null 2>&1 \
    || { curl -sSfL -o /usr/local/bin/jq https://github.com/jqlang/jq/releases/latest/download/jq-linux-amd64 && chmod +x /usr/local/bin/jq; }
fi
if ! command -v helm >/dev/null 2>&1; then
  for i in 1 2 3; do curl -sSfL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash && break; sleep 5; done
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
