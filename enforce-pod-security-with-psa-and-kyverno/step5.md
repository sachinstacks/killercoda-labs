# Switch to Deny

Same expression, same message, now a rejection:

```plain
cd /root/labs/policy
kubectl patch vpol disallow-latest-tag --type=merge -p '{"spec":{"validationActions":["Deny"]}}'
sleep 5
sed 's/name: good/name: deny-test/; s/nginx-unprivileged:1.27/nginx-unprivileged/' good.yaml | kubectl apply -f -
```{{exec}}

Expected: `Error from server: error when creating "STDIN": admission webhook … denied the request: Policy
disallow-latest-tag failed: Every container image needs an explicit tag or digest; nginxinc/nginx-unprivileged is
mutable.`

Pod Security still runs first: a pod that fails both gets the Pod Security message, because the API server stops
at the first admission plugin that denies. Prove it:

```plain
kubectl -n payments run both-bad --image=nginx --restart=Never
```{{exec}}

**CHECK** verifies that the policy is in Deny mode, that `deny-test` does not exist, and that the API server
rejects an untagged (but otherwise compliant) pod with the policy's message.

<details><summary>Solution</summary>

Run the first block above. The `apply` is expected to fail: that is the check.

</details>
