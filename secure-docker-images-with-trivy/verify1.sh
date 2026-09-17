#!/bin/bash
# lab/app:v1 exists, is built from Python 3.9 and has no USER set (runs as root).
docker image inspect lab/app:v1 >/dev/null 2>&1 || { echo "lab/app:v1 does not exist yet"; exit 1; }
docker image inspect lab/app:v1 --format '{{range .Config.Env}}{{println .}}{{end}}' | grep -q '^PYTHON_VERSION=3\.9' \
  || { echo "lab/app:v1 is not built from python:3.9-slim"; exit 1; }
user=$(docker image inspect lab/app:v1 --format '{{.Config.User}}')
[ -z "$user" ] || [ "$user" = "root" ] || [ "$user" = "0" ] || { echo "lab/app:v1 should still run as root in this step"; exit 1; }
echo "ok: lab/app:v1 is the weak image"
