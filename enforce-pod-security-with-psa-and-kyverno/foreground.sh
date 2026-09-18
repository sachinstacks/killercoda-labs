# shellcheck shell=bash
echo "Waiting for the cluster, jq and Helm. Kyverno is being installed in the background; it is needed from Step 3."
while [ ! -f /tmp/.lab-ready ]; do sleep 2; done
cd /root/labs/policy
PS1="[sachinstacks@policy \W]# "
type sachinstacks_lab_hook >/dev/null 2>&1 || sachinstacks-banner "Enforce Pod Security with PSA and Kyverno" 2>/dev/null
kubectl get nodes
echo "Ready. Pod Security Admission is built into this cluster; the working directory is /root/labs/policy."
