# A rule Pod Security cannot express, in Audit mode

Every container image must carry an explicit tag or a digest. Write the policy in Audit mode, with background
scanning on so existing pods are reported too:

```plain
cat > /root/labs/policy/disallow-latest-tag.yaml <<'YAML'
apiVersion: policies.kyverno.io/v1
kind: ValidatingPolicy
metadata:
  name: disallow-latest-tag
spec:
  validationActions: [Audit]
  evaluation:
    background:
      enabled: true
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: ['v1']
        operations: [CREATE, UPDATE]
        resources: [pods]
  matchConditions:
    - name: exclude-system-namespaces
      expression: "!(request.namespace in ['kube-system', 'kyverno', 'local-path-storage'])"
  validations:
    - expression: >-
        object.spec.containers.all(c,
          c.image.contains('@sha256:') || (c.image.contains(':') && !c.image.endsWith(':latest')))
      messageExpression: >-
        "Every container image needs an explicit tag or digest; " +
        object.spec.containers
          .filter(c, !(c.image.contains('@sha256:') || (c.image.contains(':') && !c.image.endsWith(':latest'))))
          .map(c, c.image).join(', ') +
        " is mutable."
      message: 'Every container image needs an explicit tag or digest.'
YAML
kubectl apply -f /root/labs/policy/disallow-latest-tag.yaml
kubectl get vpol
```{{exec}}

Expected: `READY  true` (it may take a few seconds).

Now create a pod that passes Pod Security but uses an untagged image. In Audit mode it is admitted, and shows up in
the report:

```plain
cd /root/labs/policy
sed 's/name: good/name: audit-test/; s/nginx-unprivileged:1.27/nginx-unprivileged/' good.yaml | kubectl apply -f -
sleep 30
kubectl get policyreport -A -o json | jq -r '
  .items[] | .metadata.namespace as $ns | .scope.name as $name
  | .results[]? | select(.result == "fail")
  | "\($ns)/\($name)\t\(.policy)\t\(.message)"'
```{{exec}}

Expected: `pod/audit-test created`, then a line `payments/audit-test  disallow-latest-tag  Every container image
needs an explicit tag or digest; nginxinc/nginx-unprivileged is mutable.` (If the report is empty, wait a little
and run the last command again: the reports controller needs a moment.)

The report is the list of what enforcement would break. In a real cluster you leave the policy here until that
list is empty, or every remaining line has an owner.

**CHECK** verifies that the policy is Ready in Audit mode, that `audit-test` was admitted, and that a
PolicyReport records its failure.

<details><summary>Solution</summary>

Run the two blocks above in order. Re-run the `kubectl get policyreport` command until the `fail` line appears.

</details>
