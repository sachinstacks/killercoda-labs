# Done

You took an image from an end-of-life base with dozens of fixable HIGH and CRITICAL findings to one that passes the
gate: current base, non-root user, patched packages, no `pip` in the runtime image, and the application still
answers `ok`.

## Run this again next month

`lab/app:v4` passed today. Rebuild it with `--pull` in a month and it will not, because Debian will have published
new advisories. The gate is only meaningful if images are rebuilt on a schedule, and the scan runs against what is
deployed, not what was deployed.

For a real application, do the `pip install` of your dependencies in a builder stage and copy only `site-packages`
into a runtime stage that never had `pip`: the multi-stage pattern gets the same result without the uninstall dance.

## Cleanup

This environment is discarded when you leave it. On your own machine the equivalent would be:

```plain
docker image rm lab/app:v1 lab/app:v2 lab/app:v3 lab/app:v4
rm -rf ~/labs/trivy
```{{copy}}

## Further reading

Read the full engineering notes and explanation on sachinchaurasiya.com:
[Secure Docker Images with Trivy](https://sachinchaurasiya.com/labs/secure-docker-images-with-trivy).
