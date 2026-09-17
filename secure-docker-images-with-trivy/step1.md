# Build the weak image

`python:3.9` reached end of life in October 2025. The tag still resolves, still builds, and still runs as root.

Create this Dockerfile in `/root/labs/trivy`:

```plain
cat > /root/labs/trivy/Dockerfile <<'DF'
FROM python:3.9-slim
COPY app.py /app.py
CMD ["python", "/app.py"]
DF
```{{exec}}

Build it as `lab/app:v1` and check which user the process runs as:

```plain
cd /root/labs/trivy
docker build --pull -t lab/app:v1 .
docker run --rm lab/app:v1 id
```{{exec}}

Expected: the last line is `uid=0(root) gid=0(root) groups=0(root)`.

**CHECK** verifies that `lab/app:v1` exists, was built from a Python 3.9 base and runs as root.

<details><summary>Solution</summary>

The two blocks above are the complete solution: write the Dockerfile, then run

```plain
cd /root/labs/trivy && docker build --pull -t lab/app:v1 . && docker run --rm lab/app:v1 id
```{{exec}}

</details>
