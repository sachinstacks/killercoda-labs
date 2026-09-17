# Patch the OS, and look at what is left

The remaining Debian findings have fixed versions in the distribution. Upgrade the packages at build time:

```plain
cat > /root/labs/trivy/Dockerfile <<'DF'
FROM python:3.13-slim
RUN apt-get update \
 && apt-get upgrade -y \
 && rm -rf /var/lib/apt/lists/*
RUN useradd --create-home --uid 10001 app
USER app
WORKDIR /home/app
COPY --chown=app:app app.py .
EXPOSE 8080
CMD ["python", "app.py"]
DF
```{{exec}}

```plain
cd /root/labs/trivy
docker build -t lab/app:v3 .
trivy image --severity HIGH,CRITICAL --ignore-unfixed --quiet lab/app:v3
trivy image --severity HIGH,CRITICAL --ignore-unfixed --quiet --format json --output report-v3.json lab/app:v3
```{{exec}}

Expected: the Debian side reports `Total: 0`. What is left (two HIGH findings in the reference run) is in the
Python packages that `pip` vendors inside itself, read from `pip/_vendor/vendor.txt`. Upgrading `pip` does not
change them: they are reachable only when `pip` itself runs.

**CHECK** verifies that `lab/app:v3` applies the OS upgrade and that `report-v3.json` shows zero fixable
HIGH/CRITICAL findings in Debian packages.

<details><summary>Solution</summary>

Write the Dockerfile shown above, then:

```plain
cd /root/labs/trivy && docker build -t lab/app:v3 . && trivy image --severity HIGH,CRITICAL --ignore-unfixed --quiet --format json --output report-v3.json lab/app:v3
```{{exec}}

</details>
