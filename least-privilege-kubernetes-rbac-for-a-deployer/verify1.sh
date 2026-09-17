#!/bin/bash
kubectl get ns rbac-lab >/dev/null 2>&1 || { echo "namespace rbac-lab missing"; exit 1; }
kubectl -n rbac-lab get sa deployer >/dev/null 2>&1 || { echo "service account deployer missing in rbac-lab"; exit 1; }
kubectl -n rbac-lab get role deployment-manager >/dev/null 2>&1 || { echo "Role deployment-manager missing"; exit 1; }
kubectl -n rbac-lab get rolebinding deployer-deployment-manager -o json 2>/dev/null \
  | jq -e '.roleRef.kind == "Role" and .roleRef.name == "deployment-manager" and any(.subjects[]?; .kind == "ServiceAccount" and .name == "deployer")' >/dev/null \
  || { echo "RoleBinding deployer-deployment-manager must bind ServiceAccount deployer to Role deployment-manager"; exit 1; }
SA=system:serviceaccount:rbac-lab:deployer
[ "$(kubectl auth can-i create deployments -n rbac-lab --as=$SA)" = "yes" ] || { echo "deployer cannot create deployments in rbac-lab"; exit 1; }
[ "$(kubectl auth can-i get pods/log -n rbac-lab --as=$SA)" = "yes" ] || { echo "deployer should be able to get pods/log"; exit 1; }
[ "$(kubectl auth can-i delete deployments -n rbac-lab --as=$SA)" = "no" ] || { echo "deployer must NOT be able to delete deployments"; exit 1; }
echo "ok: identity, role and binding are in place with the right verbs"
