# shellcheck shell=bash
echo "Preparing the environment: Trivy, jq, the vulnerability database and the base images."
echo "This takes a minute or two. Read the introduction on the left meanwhile."
while [ ! -f /tmp/.lab-ready ]; do sleep 2; done
cd /root/labs/trivy
clear
echo "Ready. Trivy $(trivy --version 2>/dev/null | head -1 | awk '{print $2}') is installed, the database is cached, and you are in /root/labs/trivy."
