#!/bin/bash
docker image inspect lab/app:v4 >/dev/null 2>&1 || { echo "lab/app:v4 does not exist yet"; exit 1; }
user=$(docker image inspect lab/app:v4 --format '{{.Config.User}}')
[ "$user" = "app" ] || [ "$user" = "10001" ] || { echo "lab/app:v4 must run as the app user"; exit 1; }
if docker run --rm lab/app:v4 python -m pip --version >/dev/null 2>&1; then
  echo "pip is still installed in lab/app:v4"; exit 1
fi
if ! trivy image --exit-code 1 --severity HIGH,CRITICAL --ignore-unfixed --quiet lab/app:v4 >/dev/null 2>&1; then
  echo "the gate still fails: lab/app:v4 has fixable HIGH/CRITICAL findings"; exit 1
fi
docker rm -f verify-v4 >/dev/null 2>&1
docker run --rm -d --name verify-v4 -p 127.0.0.1:18081:8080 lab/app:v4 >/dev/null || { echo "lab/app:v4 does not start"; exit 1; }
sleep 2
out=$(curl -s --max-time 5 http://127.0.0.1:18081/)
docker rm -f verify-v4 >/dev/null 2>&1
[ "$out" = "ok" ] || { echo "the container did not answer ok"; exit 1; }
echo "ok: lab/app:v4 passes the gate, has no pip, runs as app and answers ok"
