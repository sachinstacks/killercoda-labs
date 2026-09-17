# shellcheck shell=bash
echo "Waiting for the cluster and jq."
while [ ! -f /tmp/.lab-ready ]; do sleep 2; done
cd /root/labs/rbac
clear
kubectl get nodes
echo "Ready. You are cluster-admin on this cluster; the working directory is /root/labs/rbac."
