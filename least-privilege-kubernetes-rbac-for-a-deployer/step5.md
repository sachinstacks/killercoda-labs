# Audit the cluster you already have

The lab identity is tight. The rest of the cluster may not be. Three queries find the usual problems; keep their
output in `/root/labs/rbac/audit.txt`:

```plain
cd /root/labs/rbac
{
echo "# Who holds cluster-admin?"
kubectl get clusterrolebindings -o json | jq -r '
  .items[] | select(.roleRef.name == "cluster-admin")
  | "\(.metadata.name): \(.subjects // [] | map(.kind + "/" + .name) | join(", "))"'
echo "# Which roles grant every verb on every resource?"
kubectl get clusterroles -o json | jq -r '
  .items[] | select(.rules[]? | (.verbs | index("*")) and (.resources | index("*"))) | .metadata.name'
echo "# Which bindings include unauthenticated callers?"
kubectl get clusterrolebindings -o json | jq -r '
  .items[] | select(.subjects[]? | .name == "system:unauthenticated" or .name == "system:anonymous")
  | "\(.metadata.name) → \(.roleRef.name)"'
} | tee audit.txt
```{{exec}}

Expected on a clean kubeadm cluster: two group bindings to `cluster-admin` (`system:masters` and
`kubeadm:cluster-admins`, both only reachable with a certificate issued by the control plane), one wildcard role
(`cluster-admin` itself), and unauthenticated access limited to `system:public-info-viewer` (`/version`,
`/healthz` and friends). Run the same three queries against a production cluster and every extra line is a
conversation.

**CHECK** verifies that `audit.txt` holds the real answers of the three queries for this cluster.

<details><summary>Solution</summary>

Run the block above; it writes the three answers to `audit.txt`.

</details>
