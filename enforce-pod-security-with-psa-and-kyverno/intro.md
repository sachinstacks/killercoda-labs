# Enforce Pod Security with Pod Security Admission and Kyverno

**Level:** intermediate · **Time:** about 40 minutes · **Environment:** Kubernetes (kubeadm, one node, 4 GB)

Two admission controls, layered. First the built-in one: Pod Security Admission rejects pods that do not meet the
`restricted` profile, and tells you every field that is missing. Then Kyverno, for a rule Pod Security cannot
express (no `:latest` tags), rolled out the way you would in production: audit first, read the report, then deny.

## What is being prepared

Pod Security Admission needs nothing installed, so you can start as soon as the cluster answers. Kyverno takes a
few minutes to pull and start, so a background script installs it (chart 3.9.1, Kyverno 1.19) while you work on
Steps 1 and 2; Step 3 confirms it is running. `jq` and Helm are installed, and the two nginx images the pods use
are pre-pulled.

Everything else — the namespace labels, the pods, the policy and its mode — is yours to do.

Each step ends with a **CHECK** that inspects the cluster: namespace labels, pod state, policy readiness, the
PolicyReport, and whether the API server really rejects what it should. Every step has a collapsed **Solution**.
Click **START** when the terminal shows the node.
