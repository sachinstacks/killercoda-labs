# shellcheck shell=bash
echo "Waiting for the cluster and jq."
while [ ! -f /tmp/.lab-ready ]; do sleep 2; done
cd /root/labs/rbac
PS1="[sachinstacks@rbac \W]# "
type sachinstacks_lab_hook >/dev/null 2>&1 || sachinstacks-banner "Least-Privilege Kubernetes RBAC for a Deployer" 2>/dev/null
kubectl get nodes
echo "Ready. You are cluster-admin on this cluster; the working directory is /root/labs/rbac."
