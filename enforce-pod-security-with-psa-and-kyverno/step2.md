# A pod that satisfies `restricted`

Write a pod that meets every field the error listed, and give nginx somewhere to write:

```plain
cat > /root/labs/policy/good.yaml <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: good
  namespace: payments
spec:
  automountServiceAccountToken: false
  securityContext:
    runAsNonRoot: true
    runAsUser: 10001
    seccompProfile: { type: RuntimeDefault }
  containers:
    - name: app
      image: nginxinc/nginx-unprivileged:1.27
      securityContext:
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        capabilities: { drop: ['ALL'] }
      resources:
        requests: { cpu: '100m', memory: '64Mi' }
        limits: { cpu: '500m', memory: '128Mi' }
      volumeMounts:
        - { name: tmp, mountPath: /tmp }
        - { name: cache, mountPath: /var/cache/nginx }
        - { name: run, mountPath: /var/run }
  volumes:
    - { name: tmp, emptyDir: {} }
    - { name: cache, emptyDir: {} }
    - { name: run, emptyDir: {} }
YAML
kubectl apply -f /root/labs/policy/good.yaml
kubectl -n payments wait --for=condition=Ready pod/good --timeout=300s
kubectl -n payments exec good -- id
```{{exec}}

Expected: `pod/good created`, `condition met`, and `uid=10001`.

The three `emptyDir` mounts exist because `readOnlyRootFilesystem: true` means nginx cannot write its cache or PID
file anywhere else. That is the usual reason a `restricted` rollout breaks an application: not the security
context, but the writable paths nobody documented.

**CHECK** verifies that `good` is Ready in `payments` and runs as uid 10001 with a read-only root filesystem.

<details><summary>Solution</summary>

Run the block above as written.

</details>
