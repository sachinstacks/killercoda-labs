#!/bin/bash
# Prepares the environment: Trivy and jq, the vulnerability database and the
# application fixture. It never builds or scans the lab images; that is the task.
set -x

# --- SachinStacks terminal identity (shared block, identical in every scenario) ---
# Installs the banner helper and the prompt. The banner prints exactly once, after
# /tmp/.lab-ready exists: from the foreground script in the normal case, or from
# the prompt hook below at the first prompt after readiness if the platform did
# not type the foreground script into the terminal. Nothing here touches the lab.
install_sachinstacks_identity() { # short-name "lab title"
  cat > /usr/local/bin/sachinstacks-banner <<'BANNER'
#!/bin/bash
# Usage: sachinstacks-banner "<lab title>". Prints the SachinStacks lab banner once
# (a flag file makes later calls no-ops), in colour when the terminal supports it.
flag=/tmp/.sachinstacks-banner-shown
[ -f "$flag" ] && exit 0
title="${1:-SachinStacks lab}"
if [ -t 1 ] && command -v tput >/dev/null 2>&1 && [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then
  c="$(tput bold)$(tput setaf 6)"; r="$(tput sgr0)"
else
  c=""; r=""
fi
line="------------------------------------------------------------"
printf '%s\n' "$line"
printf ' %sSACHINSTACKS LAB%s\n' "$c" "$r"
printf ' %s%s%s\n' "$c" "$title" "$r"
printf '\n'
printf ' sachinchaurasiya.com\n'
printf ' Environment hosted on Killercoda\n'
printf '%s\n' "$line"
touch "$flag"
BANNER
  chmod +x /usr/local/bin/sachinstacks-banner
  # Prompt and banner hook for every interactive shell (the one already open
  # sources .bashrc when it starts; new tabs do the same).
  if ! grep -q 'sachinstacks_lab_hook' /root/.bashrc 2>/dev/null; then
    cat >> /root/.bashrc <<BASHRC

# SachinStacks lab identity
PS1="[sachinstacks@$1 \\W]# "
sachinstacks_lab_hook() {
  if [ -f /tmp/.lab-ready ] && [ ! -f /tmp/.sachinstacks-banner-shown ]; then sachinstacks-banner "$2"; fi
}
PROMPT_COMMAND="sachinstacks_lab_hook\${PROMPT_COMMAND:+;\$PROMPT_COMMAND}"
BASHRC
  fi
}
install_sachinstacks_identity 'trivy' 'Secure Docker Images with Trivy'
# --- end SachinStacks terminal identity ---
export DEBIAN_FRONTEND=noninteractive
# The lab was verified with Trivy 0.68.2; that release has since been withdrawn
# from GitHub (only v0.69.2+ remain), so the current release is installed.
TRIVY_VERSION=0.74.0
LAB=/root/labs/trivy
mkdir -p "$LAB"

install_jq() {
  command -v jq >/dev/null 2>&1 && return 0
  apt-get update -qq && apt-get install -y -qq jq >/dev/null 2>&1 && return 0
  curl -sSfL -o /usr/local/bin/jq https://github.com/jqlang/jq/releases/latest/download/jq-linux-amd64 && chmod +x /usr/local/bin/jq
}
install_trivy() {
  command -v trivy >/dev/null 2>&1 && return 0
  for _ in 1 2 3; do
    curl -sSfL "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" \
      | tar -xz -C /usr/local/bin trivy && chmod +x /usr/local/bin/trivy && return 0
    sleep 5
  done
  return 1
}

install_jq
install_trivy

# The application never changes; only the Dockerfile does.
cat > "$LAB/app.py" <<'PY'
from http.server import HTTPServer, BaseHTTPRequestHandler
class H(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200); self.end_headers(); self.wfile.write(b"ok\n")
HTTPServer(("0.0.0.0", 8080), H).serve_forever()
PY

# The vulnerability database is large; fetch it once now so the first scan is fast.
for _ in 1 2 3; do trivy image --download-db-only --timeout 15m && break; sleep 10; done

# Warm the base images the Dockerfiles use, so builds do not wait on the registry.
docker pull -q python:3.9-slim >/dev/null 2>&1 || true
docker pull -q python:3.13-slim >/dev/null 2>&1 || true

touch /tmp/.lab-ready
