# Done

You turned on the built-in admission control, wrote a pod that satisfies it, then added a rule it cannot express
and rolled it out the production way: audit, read the report, deny.

## Two layers, deliberately

Pod Security Admission is built in, has no controller to keep alive, and covers the fields that matter most. Kyverno
adds what PSA cannot: image sources and tags, mutation, generated resources. If Kyverno's admission controller is
down with `failurePolicy: Fail`, matching requests are rejected; PSA keeps working regardless. Keep both, and treat
the Kyverno namespace like the control plane.

## Cleanup

This environment is discarded when you leave it. On a cluster you keep:

```plain
kubectl delete vpol disallow-latest-tag
kubectl delete namespace payments
helm uninstall kyverno -n kyverno
```{{copy}}

## Further reading

Read the full engineering notes and explanation on sachinchaurasiya.com:
[Enforce Pod Security with Pod Security Admission and Kyverno](https://sachinchaurasiya.com/labs/enforce-pod-security-with-psa-and-kyverno).
