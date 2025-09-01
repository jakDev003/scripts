#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=../lib/module_init.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/module_init.sh"

bold "Installing GCC (and build tools if needed)"

case "$PM" in
  apt-get)
    eval "$PM_INSTALL gcc g++ make"
    ;;
  dnf|yum)
    [ -n "${PM_GROUPDEV:-}" ] && eval "$PM_GROUPDEV" || true
    eval "$PM_INSTALL gcc gcc-c++ make"
    ;;
  pacman)
    eval "$PM_INSTALL gcc make"
    [ -n "${PM_GROUPDEV:-}" ] && eval "$PM_GROUPDEV" || true
    ;;
  zypper)
    eval "$PM_INSTALL gcc gcc-c++ make"
    ;;
  apk)
    eval "$PM_INSTALL gcc g++ make libc-dev"
    ;;
  *)
    warn "Unknown package manager. Skipping gcc install."
    exit 0
    ;;
esac

ok "GCC toolchain installed."

