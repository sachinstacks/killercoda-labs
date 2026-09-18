# shellcheck shell=bash
echo "Waiting for the cluster, jq and Helm. Kyverno is being installed in the background; it is needed from Step 3."
while [ ! -f /tmp/.lab-ready ]; do sleep 2; done
cd /root/labs/policy
PS1="[sachinstacks@policy \W]# "
sachinstacks-banner "Enforce Pod Security with PSA and Kyverno" 2>/dev/null || echo "SachinStacks lab: Enforce Pod Security with PSA and Kyverno - sachinchaurasiya.com - Environment hosted on Killercoda"
kubectl get nodes
echo "Ready. Pod Security Admission is built into this cluster; the working directory is /root/labs/policy."
