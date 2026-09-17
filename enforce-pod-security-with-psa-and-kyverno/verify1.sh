#!/bin/bash
kubectl get ns payments >/dev/null 2>&1 || { echo "namespace payments missing"; exit 1; }
enf=$(kubectl get ns payments -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/enforce}')
[ "$enf" = "restricted" ] || { echo "payments must be labelled pod-security.kubernetes.io/enforce=restricted"; exit 1; }
kubectl -n payments get pod bad >/dev/null 2>&1 && { echo "pod bad exists; Pod Security should have rejected it"; exit 1; }
out=$(kubectl -n payments run psa-check --image=nginx:1.27 --restart=Never --dry-run=server 2>&1)
echo "$out" | grep -q 'violates PodSecurity "restricted' || { echo "the API server does not reject a default pod in payments"; exit 1; }
echo "ok: restricted is enforced in payments"
