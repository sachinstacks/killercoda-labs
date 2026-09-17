# Least-Privilege Kubernetes RBAC for a Deployer Service Account

**Level:** intermediate · **Time:** about 35 minutes · **Environment:** Kubernetes (kubeadm, one node)

A CI system that deploys to Kubernetes needs an identity. The wrong identity is the cluster-admin kubeconfig someone
exported in 2023. The right one is a service account bound to a namespaced Role that allows exactly the verbs a
rollout needs, authenticated with a token that expires in minutes.

In this scenario you build that identity, then try to break out of it from three directions: a different verb, a
different resource, and a different namespace. Finally you run three queries that find the usual problems in a
cluster you already have.

## What you have

A single-node kubeadm cluster, `kubectl` as cluster-admin, `jq`, and an empty working directory at
`/root/labs/rbac`. Nothing about the deployer identity exists yet; every object is yours to create.

Each step ends with a **CHECK** that asks the API server the real authorization questions (`kubectl auth can-i`
as the service account, a request with the real token), not whether a YAML file exists. Every step has a collapsed
**Solution**. Click **START** when the terminal shows the node.
