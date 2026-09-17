# killercoda-labs

Interactive, browser-based versions of the hands-on labs published at
[sachinchaurasiya.com/labs](https://sachinchaurasiya.com/labs), built for [Killercoda](https://killercoda.com).

Each directory is one Killercoda scenario and is named exactly after the lab slug on the website:

| Scenario | Environment | Website lab |
| --- | --- | --- |
| `secure-docker-images-with-trivy` | `ubuntu` | https://sachinchaurasiya.com/labs/secure-docker-images-with-trivy |
| `scan-git-repositories-with-gitleaks` | `ubuntu` | https://sachinchaurasiya.com/labs/scan-git-repositories-with-gitleaks |
| `generate-an-sbom-with-syft-and-scan-it-with-grype` | `ubuntu-4GB` | https://sachinchaurasiya.com/labs/generate-an-sbom-with-syft-and-scan-it-with-grype |
| `least-privilege-kubernetes-rbac-for-a-deployer` | `kubernetes-kubeadm-1node` | https://sachinchaurasiya.com/labs/least-privilege-kubernetes-rbac-for-a-deployer |
| `enforce-pod-security-with-psa-and-kyverno` | `kubernetes-kubeadm-1node-4GB` | https://sachinchaurasiya.com/labs/enforce-pod-security-with-psa-and-kyverno |

## Layout of a scenario

```
<slug>/
  index.json        title, description, steps, environment (Killercoda schema)
  intro.md          what the learner builds, what is prepared, how CHECK works
  background.sh     installs tools and fixtures; never completes the learning objective
  foreground.sh     waits for background.sh and tells the learner the environment is ready
  stepN.md          objective, commands, expected result, collapsed Solution
  verifyN.sh        exits 0 only when the real state of the environment is correct
  finish.md         what was learned, cleanup on a machine you keep, link to the full notes
```

## Principles

- Every scenario is completable on Killercoda alone: task, expected result and solution are in the scenario. The
  link to sachinchaurasiya.com at the end is optional further reading.
- Verification inspects state (images, reports, RBAC answers from the API server, policy readiness, reports), not
  marker files, and fails before the task is done.
- Setup scripts prepare infrastructure (tools, databases, fixtures, Kyverno) so the learner's time goes to the
  lesson; they never do the lesson.
- No real credentials anywhere. The Gitleaks fixtures are generated at random when the environment starts and
  exist only inside that disposable environment.
- Environments are ephemeral (one hour on the free tier); cleanup sections show what to remove on a machine you
  keep.

Killercoda hosts the practice environments. This repository and the scenarios are the author's own work, adapted
from the labs on sachinchaurasiya.com.
