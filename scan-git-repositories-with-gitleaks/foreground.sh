# shellcheck shell=bash
echo "Preparing the environment: Gitleaks, jq and a repository seeded with fake secrets."
while [ ! -f /tmp/.lab-ready ]; do sleep 2; done
cd /root/labs/gitleaks
PS1="[sachinstacks@gitleaks \W]# "
sachinstacks-banner "Scan Git Repositories with Gitleaks" 2>/dev/null || echo "SachinStacks lab: Scan Git Repositories with Gitleaks - sachinchaurasiya.com - Environment hosted on Killercoda"
echo "Ready. $(gitleaks version 2>/dev/null | head -1 | sed 's/^/Gitleaks /') is installed and you are in /root/labs/gitleaks (3 commits)."
