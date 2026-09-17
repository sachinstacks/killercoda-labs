# Current base, non-root user

Change one line of the `FROM` and add a user. Everything else stays the same:

```plain
cat > /root/labs/trivy/Dockerfile <<'DF'
FROM python:3.13-slim
RUN useradd --create-home --uid 10001 app
USER app
WORKDIR /home/app
COPY --chown=app:app app.py .
EXPOSE 8080
CMD ["python", "app.py"]
DF
```{{exec}}

Build it as `lab/app:v2`, confirm the user, and write the report as `report-v2.json`:

```plain
cd /root/labs/trivy
docker build --pull -t lab/app:v2 .
docker run --rm lab/app:v2 id
trivy image --severity HIGH,CRITICAL --ignore-unfixed --quiet --format json --output report-v2.json lab/app:v2
jq '[.Results[].Vulnerabilities // [] | length] | add // 0' report-v2.json
```{{exec}}

Expected: `uid=10001(app)` and a much smaller count (14 in the reference run). What remains are Debian packages
that received security updates after this tag of the base image was published, plus a couple of Python packages.
The gate still fails:

```plain
trivy image --exit-code 1 --severity HIGH,CRITICAL --ignore-unfixed --quiet lab/app:v2 > /dev/null; echo "exit=$?"
```{{exec}}

**CHECK** verifies that `lab/app:v2` is built from Python 3.13, runs as `app`, and that `report-v2.json` counts
fewer findings than `report-v1.json`.

<details><summary>Solution</summary>

Write the Dockerfile shown above, then:

```plain
cd /root/labs/trivy && docker build --pull -t lab/app:v2 . && trivy image --severity HIGH,CRITICAL --ignore-unfixed --quiet --format json --output report-v2.json lab/app:v2
```{{exec}}

</details>
