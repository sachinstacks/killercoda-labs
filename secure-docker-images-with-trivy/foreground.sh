# shellcheck shell=bash
echo "Preparing the environment: Trivy, jq, the vulnerability database and the base images."
echo "This takes a minute or two. Read the introduction on the left meanwhile."
while [ ! -f /tmp/.lab-ready ]; do sleep 2; done
cd /root/labs/trivy
PS1="[sachinstacks@trivy \W]# "
type sachinstacks_lab_hook >/dev/null 2>&1 || sachinstacks-banner "Secure Docker Images with Trivy" 2>/dev/null
if command -v trivy >/dev/null 2>&1; then
  echo "Ready. Trivy $(trivy --version 2>/dev/null | head -1 | awk '{print $2}') is installed, the database is cached, and you are in /root/labs/trivy."
else
  echo "WARNING: Trivy could not be installed (see /var/log/killercoda/background0_stderr.log). Reload the scenario to retry."
fi
