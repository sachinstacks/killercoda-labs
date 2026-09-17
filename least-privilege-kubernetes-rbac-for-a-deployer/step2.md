# Prove the boundary with impersonation

`kubectl auth can-i` with `--as` asks the API server the question RBAC will answer at request time, without needing
the service account's credentials:

```plain
SA=system:serviceaccount:rbac-lab:deployer
kubectl auth can-i create deployments -n rbac-lab --as=$SA
kubectl auth can-i delete deployments -n rbac-lab --as=$SA
kubectl auth can-i get secrets -n rbac-lab --as=$SA
kubectl auth can-i list pods -n default --as=$SA
kubectl auth can-i create deployments -n default --as=$SA
```{{exec}}

Expected: one `yes`, four `no`s. The verb boundary (`delete`), the resource boundary (`secrets`) and the namespace
boundary (`default`) all hold.

The complete set is worth reading once:

```plain
kubectl auth can-i --list -n rbac-lab --as=$SA
```{{exec}}

The three `selfsubject*review` entries and the `/api`, `/healthz`, `/version` URLs come from the default
`system:basic-user` and `system:discovery` roles bound to every authenticated identity, not from your Role.

**CHECK** asks the API server the same five questions and expects exactly `yes, no, no, no, no`.

<details><summary>Solution</summary>

Run the first block above. If any answer is wrong, compare your Role and RoleBinding with the manifest in Step 1
and re-apply it.

</details>
