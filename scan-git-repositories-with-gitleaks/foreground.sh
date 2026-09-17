# shellcheck shell=bash
echo "Preparing the environment: Gitleaks, jq and a repository seeded with fake secrets."
while [ ! -f /tmp/.lab-ready ]; do sleep 2; done
cd /root/labs/gitleaks
clear
echo "Ready. $(gitleaks version 2>/dev/null | head -1 | sed 's/^/Gitleaks /') is installed and you are in /root/labs/gitleaks (3 commits)."
