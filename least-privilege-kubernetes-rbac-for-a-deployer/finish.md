# Done

You built a deployer identity that can roll out Deployments in one namespace and nothing else, proved it twice
(impersonation, then a real short-lived token in a kubeconfig that holds nothing else), watched the three escapes
fail with messages that name the identity, the verb and the namespace, and audited the cluster for the usual
problems.

## What CI should actually hold

Not the token you created. A short-lived token is created at job start by something that is allowed to create it
(a short-lived cloud identity, or a workload identity federation such as GitLab's OIDC with the cluster's
authentication webhook) and never stored. If your platform cannot do that yet, a long-lived service account secret
bound to this Role is still far better than a cluster-admin kubeconfig, provided it is rotated and lives only in
the CI secret store.

## Cleanup

This environment is discarded when you leave it. On a cluster you keep, remove the lab objects with:

```plain
kubectl delete namespace rbac-lab
rm -f /root/labs/rbac/deployer.kubeconfig /root/labs/rbac/ca.crt
```{{copy}}

## Further reading

Read the full engineering notes and explanation on sachinchaurasiya.com:
[Least-Privilege Kubernetes RBAC for a Deployer Service Account](https://sachinchaurasiya.com/labs/least-privilege-kubernetes-rbac-for-a-deployer).
