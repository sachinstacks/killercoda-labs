# Label the namespace, reject a default pod

Create the namespace and turn on the `restricted` profile for it:

```plain
kubectl create namespace payments
kubectl label namespace payments \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/enforce-version=latest \
  pod-security.kubernetes.io/warn=restricted
```{{exec}}

Now try to run a default pod in it:

```plain
kubectl -n payments run bad --image=nginx:1.27 --restart=Never
```{{exec}}

Expected: `Error from server (Forbidden): pods "bad" is forbidden: violates PodSecurity "restricted:latest"` followed
by all four missing fields at once: `allowPrivilegeEscalation != false`, `unrestricted capabilities`,
`runAsNonRoot != true` and `seccompProfile`.

Nothing was installed for this. The message lists every missing field, which is the best admission error message
in the ecosystem and the reason to turn on Pod Security before anything else.

**CHECK** verifies the namespace labels and asks the API server (server-side dry run) whether it still rejects a
default pod in `payments`.

<details><summary>Solution</summary>

Run the two blocks above. The second one is expected to fail: that is the check.

</details>
