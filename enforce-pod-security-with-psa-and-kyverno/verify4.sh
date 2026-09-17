#!/bin/bash
kubectl get vpol disallow-latest-tag >/dev/null 2>&1 || { echo "ValidatingPolicy disallow-latest-tag missing"; exit 1; }
actions=$(kubectl get vpol disallow-latest-tag -o jsonpath='{.spec.validationActions}')
echo "$actions" | grep -q 'Audit' || { echo "the policy should be in Audit mode in this step, got $actions"; exit 1; }
ready=$(kubectl get vpol disallow-latest-tag -o jsonpath='{.status.conditionStatus.ready}')
[ "$ready" = "true" ] || { echo "the policy is not Ready yet (status: '$ready'); kubectl describe vpol disallow-latest-tag"; exit 1; }
kubectl -n payments get pod audit-test >/dev/null 2>&1 || { echo "pod audit-test missing: in Audit mode it must be admitted"; exit 1; }
img=$(kubectl -n payments get pod audit-test -o jsonpath='{.spec.containers[0].image}')
case "$img" in *:*) echo "audit-test must use an untagged image (nginxinc/nginx-unprivileged), got $img"; exit 1;; esac
kubectl get policyreport -A -o json 2>/dev/null | jq -e '
  [.items[] | select(.scope.name == "audit-test") | .results[]? | select(.policy == "disallow-latest-tag" and .result == "fail")] | length > 0' >/dev/null \
  || { echo "no PolicyReport failure for audit-test yet; the reports controller may still be catching up"; exit 1; }
echo "ok: policy Ready in Audit mode, audit-test admitted and reported"
