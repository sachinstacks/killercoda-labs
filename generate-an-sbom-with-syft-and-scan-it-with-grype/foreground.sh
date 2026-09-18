# shellcheck shell=bash
echo "Preparing the environment: Syft, Grype, jq and the Grype vulnerability database."
echo "The database is large; this takes a few minutes. Read the introduction on the left meanwhile."
while [ ! -f /tmp/.lab-ready ]; do sleep 2; done
cd /root/labs/sbom
PS1="[sachinstacks@sbom \W]# "
type sachinstacks_lab_hook >/dev/null 2>&1 || sachinstacks-banner "Generate an SBOM with Syft and Scan It with Grype" 2>/dev/null
echo "Ready. $(syft version 2>/dev/null | awk '/^Version/ {print "Syft " $2}'), $(grype version 2>/dev/null | awk '/^Version/ {print "Grype " $2}'); database cached; you are in /root/labs/sbom."
