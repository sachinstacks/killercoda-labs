# shellcheck shell=bash
echo "Waiting for the cluster, jq and Helm. Kyverno is being installed in the background; it is needed from Step 3."
while [ ! -f /tmp/.lab-ready ]; do sleep 2; done
cd /root/labs/policy
clear
kubectl get nodes
echo "Ready. Pod Security Admission is built into this cluster; the working directory is /root/labs/policy."
