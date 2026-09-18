# Secure Docker Images with Trivy

**Level:** beginner · **Time:** about 30 minutes · **Environment:** Ubuntu with Docker

By the end of this scenario you will have scanned an image built from an end-of-life base, watched the count of
fixable HIGH and CRITICAL findings fall through three rebuilds, and understood why the last few findings are the
hardest to remove.

The exact numbers depend on the day's vulnerability database. The reference run (Trivy 0.68.2, database of
2026-09-13) went **70 → 14 → 2 → 0**; yours will be higher on the first image, which is part of the lesson.

## What is being prepared

While you read this, a background script installs Trivy 0.74.0 (the original lab was verified with 0.68.2, whose
release has since been withdrawn from GitHub; the commands are identical) and `jq`, downloads the vulnerability database
once (it is several hundred MB, which is why it is done for you) and pulls the two base images. The terminal
tells you when it is done.

The application is a Python HTTP server that answers `ok`. It never changes; only the Dockerfile does. It is
already at `/root/labs/trivy/app.py`:

```plain
cat /root/labs/trivy/app.py
```{{exec}}

## How the steps work

Each step ends with a **CHECK** that inspects the real state of the environment: the images you built, the reports
you wrote and the gate result. Every step also has a collapsed **Solution** if you get stuck.

Click **START** when the terminal says it is ready.
