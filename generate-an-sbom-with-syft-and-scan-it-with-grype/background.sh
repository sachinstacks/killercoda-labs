#!/bin/bash
# Prepares the environment: Syft, Grype, jq and the Grype vulnerability
# database (large, so it is fetched once here). Generating and scanning the
# SBOM is the task and is not done here.
set -x
export DEBIAN_FRONTEND=noninteractive
SYFT_VERSION=1.51.1
GRYPE_VERSION=0.118.0
LAB=/root/labs/sbom
mkdir -p "$LAB"

install_jq() {
  command -v jq >/dev/null 2>&1 && return 0
  apt-get update -qq && apt-get install -y -qq jq >/dev/null 2>&1 && return 0
  curl -sSfL -o /usr/local/bin/jq https://github.com/jqlang/jq/releases/latest/download/jq-linux-amd64 && chmod +x /usr/local/bin/jq
}
install_tool() { # name version
  command -v "$1" >/dev/null 2>&1 && return 0
  for i in 1 2 3; do
    curl -sSfL "https://raw.githubusercontent.com/anchore/$1/main/install.sh" | sh -s -- -b /usr/local/bin "v$2" && return 0
    sleep 5
  done
  return 1
}

install_jq
install_tool syft "$SYFT_VERSION"
install_tool grype "$GRYPE_VERSION"

# The vulnerability database is large; fetch it once now so scans are fast.
for _ in 1 2 3; do grype db update && break; sleep 10; done

touch /tmp/.lab-ready
