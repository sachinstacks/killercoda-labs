# Kyverno is running

Kyverno was installed in the background with Helm, exactly as the original lab does it by hand:

```plain
helm repo add kyverno https://kyverno.github.io/kyverno/ && helm repo update
helm install kyverno kyverno/kyverno --namespace kyverno --create-namespace --version 3.9.1
```{{copy}}

Wait for its four controllers to be rolled out (this returns immediately if they already are):

```plain
kubectl -n kyverno rollout status deploy --timeout=900s
kubectl -n kyverno get pods
```{{exec}}

Expected: `deployment "kyverno-admission-controller" successfully rolled out`, then the background, cleanup and
reports controllers. If Helm ever reports a release as `failed` because its wait expired during image pulls,
ignore it; `rollout status` is the check that matters.

**CHECK** verifies that all four Kyverno deployments are available.

<details><summary>Solution</summary>

Nothing to do beyond waiting. If the rollout never completes, inspect it with
`kubectl -n kyverno describe pods`.

</details>
