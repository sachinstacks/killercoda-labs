#!/bin/bash
kubectl get ns kyverno >/dev/null 2>&1 || { echo "namespace kyverno missing: the install has not started"; exit 1; }
for d in kyverno-admission-controller kyverno-background-controller kyverno-cleanup-controller kyverno-reports-controller; do
  avail=$(kubectl -n kyverno get deploy "$d" -o jsonpath='{.status.availableReplicas}' 2>/dev/null)
  [ "${avail:-0}" -ge 1 ] || { echo "$d is not available yet; wait for the rollout"; exit 1; }
done
echo "ok: all four Kyverno controllers are available"
