#!/bin/bash
actions=$(kubectl get vpol disallow-latest-tag -o jsonpath='{.spec.validationActions}' 2>/dev/null)
echo "$actions" | grep -q 'Deny' || { echo "the policy should be in Deny mode, got '$actions'"; exit 1; }
kubectl -n payments get pod deny-test >/dev/null 2>&1 && { echo "pod deny-test exists; Kyverno should have denied it"; exit 1; }
[ -s /root/labs/policy/good.yaml ] || { echo "good.yaml missing"; exit 1; }
out=$(sed 's/name: good/name: deny-check/; s/nginx-unprivileged:1.27/nginx-unprivileged/' /root/labs/policy/good.yaml | kubectl apply --dry-run=server -f - 2>&1)
echo "$out" | grep -q 'disallow-latest-tag' || { echo "the API server did not reject an untagged pod with the policy: $out"; exit 1; }
echo "ok: Deny mode rejects the untagged pod with the policy's message"
