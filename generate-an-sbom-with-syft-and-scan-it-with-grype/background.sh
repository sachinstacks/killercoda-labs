#!/bin/bash
# Prepares the environment: Syft, Grype, jq and the Grype vulnerability
# database (large, so it is fetched once here). Generating and scanning the
# SBOM is the task and is not done here.
set -x

# --- SachinStacks terminal identity (shared block, identical in every scenario) ---
# Installs the banner helper and, through .bashrc, the prompt and a hook that prints
# the banner once per interactive shell at its first prompt after /tmp/.lab-ready
# exists. Killercoda's terminal sometimes reconnects and starts a fresh shell while
# the foreground script is still running in the old one; the hook covers that shell
# too. Nothing here touches the lab.
install_sachinstacks_identity() { # short-name "lab title"
  cat > /usr/local/bin/sachinstacks-banner <<'BANNER'
#!/bin/bash
# Usage: sachinstacks-banner "<lab title>". Prints the SachinStacks lab banner, in
# colour when the terminal supports it. Callers decide when (see .bashrc hook).
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
BANNER
  chmod +x /usr/local/bin/sachinstacks-banner
  if ! grep -q 'sachinstacks_lab_hook' /root/.bashrc 2>/dev/null; then
    cat >> /root/.bashrc <<BASHRC

# SachinStacks lab identity: prompt, and the banner once per shell after setup is ready
PS1="[sachinstacks@$1 \\W]# "
sachinstacks_lab_hook() {
  if [ -z "\$SACHINSTACKS_BANNER_SHOWN" ] && [ -f /tmp/.lab-ready ]; then
    SACHINSTACKS_BANNER_SHOWN=1
    sachinstacks-banner "$2"
  fi
}
PROMPT_COMMAND="sachinstacks_lab_hook\${PROMPT_COMMAND:+;\$PROMPT_COMMAND}"
BASHRC
  fi
}
install_sachinstacks_identity 'sbom' 'Generate an SBOM with Syft and Scan It with Grype'
# --- end SachinStacks terminal identity ---
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
install_tool() { # name version: the release tarball, straight from GitHub
  command -v "$1" >/dev/null 2>&1 && return 0
  for _ in 1 2 3; do
    curl -sSfL "https://github.com/anchore/$1/releases/download/v$2/$1_$2_linux_amd64.tar.gz" \
      | tar -xz -C /usr/local/bin "$1" && chmod +x "/usr/local/bin/$1" && return 0
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
