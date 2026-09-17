# The identity, the role, the binding

Create the namespace and the three objects. Read the rules before applying them:

```plain
kubectl create namespace rbac-lab
```{{exec}}

```plain
cat > /root/labs/rbac/deployer-rbac.yaml <<'YAML'
apiVersion: v1
kind: ServiceAccount
metadata:
  name: deployer
  namespace: rbac-lab
automountServiceAccountToken: false # CI presents a token; no pod needs this SA mounted
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: deployment-manager
  namespace: rbac-lab
rules:
  - apiGroups: ['apps']
    resources: ['deployments']
    verbs: ['get', 'list', 'watch', 'create', 'update', 'patch'] # no delete
  - apiGroups: ['']
    resources: ['pods', 'pods/log']
    verbs: ['get', 'list', 'watch'] # enough to see why a rollout is stuck
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: deployer-deployment-manager
  namespace: rbac-lab
subjects:
  - kind: ServiceAccount
    name: deployer
    namespace: rbac-lab
roleRef:
  kind: Role
  name: deployment-manager
  apiGroup: rbac.authorization.k8s.io
YAML
kubectl apply -f /root/labs/rbac/deployer-rbac.yaml
```{{exec}}

Three decisions are encoded here. `delete` is missing from the deployments rule because a deployer replaces
Deployments, it does not remove them; removal is a separate, reviewed change. `pods/log` is a subresource and must
be named explicitly; granting `pods` does not grant it. And the Role is namespaced, so even a mistake in the rules
cannot reach another namespace.

**CHECK** verifies that the namespace, the service account, the Role and the RoleBinding exist, and that the Role
grants `create` on Deployments and `get` on `pods/log` but not `delete` on Deployments.

<details><summary>Solution</summary>

Run the two blocks above: create the namespace, then apply the manifest.

</details>
