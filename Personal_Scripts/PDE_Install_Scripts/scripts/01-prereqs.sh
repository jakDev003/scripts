# scripts/01-prereqs.sh
#!/usr/bin/env bash
set -euo pipefail
source "${ROOT_DIR}/scripts/lib/log.sh"
source "${ROOT_DIR}/scripts/lib/os.sh"

bold "Installing core prerequisites"
case "$PM" in
  apt-get) eval "$PM_INSTALL ca-certificates curl git gnupg build-essential pkg-config" ;;
  dnf|yum)
    [ -n "$PM_GROUPDEV" ] && eval "$PM_GROUPDEV" || true
    eval "$PM_INSTALL ca-certificates curl git gnupg2"
    ;;
  pacman)
    eval "$PM_INSTALL curl git gnupg"
    [ -n "$PM_GROUPDEV" ] && eval "$PM_GROUPDEV" || true
    ;;
  zypper)  eval "$PM_INSTALL ca-certificates curl git gpg2 gcc make" ;;
  apk)
    eval "$PM_INSTALL ca-certificates curl git gnupg"
    [ -n "$PM_GROUPDEV" ] && eval "$PM_GROUPDEV" || true
    ;;
esac
ok "Prerequisites ready."

