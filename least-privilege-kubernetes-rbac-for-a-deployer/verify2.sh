#!/bin/bash
SA=system:serviceaccount:rbac-lab:deployer
got="$(kubectl auth can-i create deployments -n rbac-lab --as=$SA 2>/dev/null) $(kubectl auth can-i delete deployments -n rbac-lab --as=$SA 2>/dev/null) $(kubectl auth can-i get secrets -n rbac-lab --as=$SA 2>/dev/null) $(kubectl auth can-i list pods -n default --as=$SA 2>/dev/null) $(kubectl auth can-i create deployments -n default --as=$SA 2>/dev/null)"
[ "$got" = "yes no no no no" ] || { echo "expected 'yes no no no no' for create/delete/secrets/pods-in-default/deployments-in-default, got '$got'"; exit 1; }
echo "ok: the verb, resource and namespace boundaries hold"
