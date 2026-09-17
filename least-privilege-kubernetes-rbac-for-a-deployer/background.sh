#!/bin/bash
# Prepares the environment: jq and a working directory. The namespace, the
# identity, the role and the binding are the task and are not created here.
set -x
export DEBIAN_FRONTEND=noninteractive
mkdir -p /root/labs/rbac
if ! command -v jq >/dev/null 2>&1; then
  apt-get update -qq && apt-get install -y -qq jq >/dev/null 2>&1 \
    || { curl -sSfL -o /usr/local/bin/jq https://github.com/jqlang/jq/releases/latest/download/jq-linux-amd64 && chmod +x /usr/local/bin/jq; }
fi
# Wait until the API server answers so the first kubectl in the scenario does not race the cluster.
for _ in $(seq 1 60); do kubectl get --raw /readyz >/dev/null 2>&1 && break; sleep 2; done
touch /tmp/.lab-ready
