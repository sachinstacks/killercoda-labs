#!/bin/bash
A=/root/labs/rbac/audit.txt
[ -s "$A" ] || { echo "audit.txt not found"; exit 1; }
grep -q 'cluster-admin: Group/system:masters' "$A" || { echo "audit.txt should list the cluster-admin binding for Group/system:masters"; exit 1; }
grep -q '^cluster-admin$' "$A" || { echo "audit.txt should list cluster-admin as the wildcard role"; exit 1; }
grep -q 'system:public-info-viewer' "$A" || { echo "audit.txt should list the system:public-info-viewer binding for unauthenticated callers"; exit 1; }
# The answers must match the live cluster, not a pasted example.
n=$(kubectl get clusterrolebindings -o json | jq -r '.items[] | select(.roleRef.name == "cluster-admin") | .metadata.name' | wc -l)
m=$(grep -c ': Group/\|: User/\|: ServiceAccount/' "$A")
[ "$m" -eq "$n" ] || { echo "audit.txt lists $m cluster-admin bindings but the cluster has $n"; exit 1; }
echo "ok: the audit reflects this cluster ($n cluster-admin bindings)"
