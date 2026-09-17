# Try to break out

Still in the deployer context (your shell has `KUBECONFIG` pointing at the deployer kubeconfig; if you opened a new
terminal, run `export KUBECONFIG=/root/labs/rbac/deployer.kubeconfig` first):

```plain
kubectl get deployments
kubectl create deployment web --image=nginxinc/nginx-unprivileged:1.27
kubectl get secrets
kubectl delete deployment web
kubectl get pods -n default
```{{exec}}

Expected: the create succeeds, and the three escapes fail with `Forbidden` messages that name the identity, the verb
and the namespace. Those messages are what your CI logs will show when someone widens a pipeline's scope without
widening the Role, which is the correct order of failure.

Switch back to your admin context before continuing, but leave the `web` Deployment in place for the check:

```plain
unset KUBECONFIG
kubectl auth whoami
```{{exec}}

**CHECK** verifies that the `web` Deployment exists in `rbac-lab` (created through the deployer's own token) and
that the same token is denied `secrets`, `delete` and the `default` namespace.

<details><summary>Solution</summary>

```plain
export KUBECONFIG=/root/labs/rbac/deployer.kubeconfig && kubectl create deployment web --image=nginxinc/nginx-unprivileged:1.27; kubectl get secrets; kubectl delete deployment web; kubectl get pods -n default; unset KUBECONFIG
```{{exec}}

</details>
