#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=../lib/module_init.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/module_init.sh"

bold "Installing ripgrep (rg)"

install_ripgrep_pkg() {
  case "$PM" in
    apt-get)
      # Debian/Ubuntu
      $SUDO apt-get update -y
      $SUDO apt-get install -y ripgrep || return 1
      ;;
    dnf|yum)
      # Fedora/RHEL family (may require EPEL on some RHEL clones)
      if ! $SUDO $PM install -y ripgrep; then
        warn "ripgrep not in default repos; trying EPEL (RHEL-like only)."
        if [ "${DIST_ID:-}" = "rhel" ] || [ "${DIST_ID:-}" = "centos" ] || [ "${DIST_ID:-}" = "rocky" ] || [ "${DIST_ID:-}" = "almalinux" ]; then
          if command -v dnf >/dev/null 2>&1; then
            $SUDO dnf install -y epel-release || true
            $SUDO dnf install -y ripgrep || return 1
          else
            $SUDO yum install -y epel-release || true
            $SUDO yum install -y ripgrep || return 1
          fi
        else
          return 1
        fi
      fi
      ;;
    pacman)
      # Arch/Manjaro
      $SUDO pacman -Sy --noconfirm --needed ripgrep || return 1
      ;;
    zypper)
      # openSUSE/SLES
      $SUDO zypper -n install ripgrep || return 1
      ;;
    apk)
      # Alpine
      $SUDO apk add --no-cache ripgrep || return 1
      ;;
    *)
      return 1
      ;;
  esac
  return 0
}

install_ripgrep_github() {
  bold "Installing ripgrep via GitHub release (latest)"
  ARCH_RAW="$(uname -m)"
  case "$ARCH_RAW" in
    x86_64|amd64) RG_ARCH="x86_64-unknown-linux-gnu" ;;
    aarch64|arm64) RG_ARCH="aarch64-unknown-linux-gnu" ;;
    armv7l|armv7)  RG_ARCH="arm-unknown-linux-gnueabihf" ;;
    *)
      warn "Unknown arch $ARCH_RAW; defaulting to x86_64."
      RG_ARCH="x86_64-unknown-linux-gnu"
      ;;
  esac

  # Get latest tag
  LATEST="$(curl -fsSL https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | grep -Po '"tag_name":\s*"\K[^"]+')"
  [ -n "${LATEST:-}" ] || { err "Could not resolve ripgrep latest version tag"; return 1; }

  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' RETURN

  # ripgrep release naming: ripgrep-<ver>-<triple>.tar.gz
  TARBALL="ripgrep_${LATEST#v}_${RG_ARCH}.tar.gz"
  URL="https://github.com/BurntSushi/ripgrep/releases/download/${LATEST}/${TARBALL}"

  info "Downloading $URL"
  curl -fsSL "$URL" -o "$TMP/$TARBALL"
  tar -xzf "$TMP/$TARBALL" -C "$TMP"
  # Extracted dir is like ripgrep-<ver>-<triple>/
  RG_DIR="$(find "$TMP" -maxdepth 1 -type d -name "ripgrep-*-${RG_ARCH}" | head -n1)"
  [ -d "$RG_DIR" ] || { err "Unexpected archive layout for ripgrep"; return 1; }

  $SUDO install -m 0755 "$RG_DIR/rg" /usr/local/bin/rg
  ok "ripgrep installed to /usr/local/bin/rg"
}

if ! command -v rg >/dev/null 2>&1; then
  install_ripgrep_pkg || { warn "Package manager failed; using GitHub fallback."; install_ripgrep_github; }
else
  info "ripgrep already present: $(rg --version | head -n1)"
fi

ok "ripgrep ready."

