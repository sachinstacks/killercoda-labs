# A real token, in a kubeconfig that has nothing else

Impersonation proves the rules. A token proves the whole path. Since Kubernetes 1.24, service accounts have no
long-lived secret by default; you request a token with an expiry. The original lab uses ten minutes; here it is
thirty, so the token outlives the next step even if you read slowly.

```plain
cd /root/labs/rbac
TOKEN=$(kubectl create token deployer -n rbac-lab --duration=30m)
SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 -d > ca.crt

export KUBECONFIG=/root/labs/rbac/deployer.kubeconfig
kubectl config set-cluster lab --server="$SERVER" --certificate-authority=ca.crt --embed-certs=true
kubectl config set-credentials deployer --token="$TOKEN"
kubectl config set-context deployer --cluster=lab --user=deployer --namespace=rbac-lab
kubectl config use-context deployer
kubectl auth whoami
```{{exec}}

Expected: `Username  system:serviceaccount:rbac-lab:deployer`, with the `system:serviceaccounts` groups.

**Why a separate kubeconfig:** passing `--token` on the command line while your current context still has a client
certificate does not test the token — the certificate is presented during the TLS handshake and wins, and
`kubectl auth whoami` would still say `kubernetes-admin`. A kubeconfig that contains only the token is the honest
test.

The token is a JWT. Its claims say who it is for and how long it lives:

```plain
echo "$TOKEN" | cut -d. -f2 | tr '_-' '/+' | awk '{ l=length($0)%4; if(l==2) print $0"=="; else if(l==3) print $0"="; else print $0 }' \
  | base64 -d | jq '{iss, sub, aud, lifetime: (.exp - .iat)}'
```{{exec}}

Expected: `sub` is the service account and `lifetime` is `1800`.

**CHECK** uses `/root/labs/rbac/deployer.kubeconfig` to call the API server and verifies that it authenticates as
the service account with a token that expires within an hour.

<details><summary>Solution</summary>

Run the first block above exactly as written; it creates the token, the CA file and the kubeconfig, then switches
your shell to it.

</details>
