#!/bin/bash
kubectl -n payments get pod good >/dev/null 2>&1 || { echo "pod good missing in payments"; exit 1; }
ready=$(kubectl -n payments get pod good -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}')
[ "$ready" = "True" ] || { echo "pod good is not Ready yet"; exit 1; }
ro=$(kubectl -n payments get pod good -o jsonpath='{.spec.containers[0].securityContext.readOnlyRootFilesystem}')
[ "$ro" = "true" ] || { echo "the container should have readOnlyRootFilesystem: true"; exit 1; }
uid=$(kubectl -n payments exec good -- id -u 2>/dev/null)
[ "$uid" = "10001" ] || { echo "the process should run as uid 10001, got '$uid'"; exit 1; }
echo "ok: good is Ready and runs as uid 10001"
