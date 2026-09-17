#!/bin/bash
KC=/root/labs/rbac/deployer.kubeconfig
kubectl -n rbac-lab get deployment web >/dev/null 2>&1 || { echo "Deployment web does not exist in rbac-lab (it must be created, and not deleted)"; exit 1; }
[ -s "$KC" ] || { echo "deployer.kubeconfig missing"; exit 1; }
who=$(kubectl --kubeconfig "$KC" auth whoami -o json 2>/dev/null | jq -r '.status.userInfo.username')
[ "$who" = "system:serviceaccount:rbac-lab:deployer" ] || { echo "the deployer token no longer works (expired?); redo Step 3"; exit 1; }
kubectl --kubeconfig "$KC" get secrets -n rbac-lab >/dev/null 2>&1 && { echo "the deployer can list secrets; the Role is too wide"; exit 1; }
kubectl --kubeconfig "$KC" delete deployment web -n rbac-lab --dry-run=server >/dev/null 2>&1 && { echo "the deployer can delete deployments; the Role is too wide"; exit 1; }
kubectl --kubeconfig "$KC" get pods -n default >/dev/null 2>&1 && { echo "the deployer can list pods in default; the binding leaks across namespaces"; exit 1; }
echo "ok: web was created by the deployer and the three escapes are Forbidden"
