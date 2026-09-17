# Remove what the runtime does not need

A runtime image has no reason to contain `pip`. Uninstall it, and the bundled wheels `ensurepip` would use to
reinstall it, and the findings go with it:

```plain
cat > /root/labs/trivy/Dockerfile <<'DF'
FROM python:3.13-slim
RUN apt-get update \
 && apt-get upgrade -y \
 && rm -rf /var/lib/apt/lists/* \
 && python -m pip uninstall -y pip \
 && rm -rf /usr/local/lib/python3.13/ensurepip
RUN useradd --create-home --uid 10001 app
USER app
WORKDIR /home/app
COPY --chown=app:app app.py .
EXPOSE 8080
CMD ["python", "app.py"]
DF
```{{exec}}

Build `lab/app:v4`, run the gate, and prove the application still answers:

```plain
cd /root/labs/trivy
docker build -t lab/app:v4 .
trivy image --exit-code 1 --severity HIGH,CRITICAL --ignore-unfixed --quiet lab/app:v4 > /dev/null; echo "exit=$?"
docker run --rm -d --name v4 -p 127.0.0.1:18080:8080 lab/app:v4 && sleep 1 && curl -s http://127.0.0.1:18080/; docker rm -f v4
```{{exec}}

Expected: `exit=0` and `ok`. Then compare all four:

```plain
for tag in v1 v2 v3 v4; do
  printf '%s: ' "$tag"
  trivy image --quiet --severity HIGH,CRITICAL --ignore-unfixed --format json lab/app:$tag \
    | jq '[.Results[].Vulnerabilities // [] | length] | add // 0'
done
docker image ls lab/app --format '{{.Tag}} {{.Size}}'
```{{exec}}

Note the sizes: the clean image is the largest, because `apt-get upgrade` adds a layer on top of the base rather
than replacing it. Size and vulnerability count are different goals; the scan result is the one that gates a
deploy.

**CHECK** runs the gate against `lab/app:v4` itself, confirms `pip` is gone and that the container answers `ok`.

<details><summary>Solution</summary>

Write the Dockerfile shown above, then:

```plain
cd /root/labs/trivy && docker build -t lab/app:v4 . && trivy image --exit-code 1 --severity HIGH,CRITICAL --ignore-unfixed --quiet lab/app:v4 >/dev/null; echo "exit=$?"
```{{exec}}

</details>
