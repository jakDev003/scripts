#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=../lib/module_init.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/module_init.sh"

bold "Installing Go (distro pkg preferred; go.dev fallback to latest stable)"

install_go_pkg() {
  case "$PM" in
    apt-get)
      $SUDO apt-get update -y
      $SUDO apt-get install -y golang || return 1
      ;;
    dnf|yum)
      $SUDO $PM install -y golang || return 1
      ;;
    pacman)
      $SUDO pacman -Sy --noconfirm --needed go || return 1
      ;;
    zypper)
      $SUDO zypper -n install go || return 1
      ;;
    apk)
      $SUDO apk add --no-cache go || return 1
      ;;
    *)
      return 1
      ;;
  esac
  return 0
}

# Determine install target for manual tarball
_resolve_go_prefix() {
  # Prefer system-wide /usr/local if writable (root or sudo); else fallback to user-local
  local sys="/usr/local"
  local usr="${HOME}/.local"
  if [ -w "$sys" ] || [ -n "${SUDO:-}" ]; then
    echo "$sys"
  else
    mkdir -p "${usr}"
    echo "${usr}"
  fi
}

install_go_tarball() {
  bold "Installing Go via official tarball (latest stable)"
  # Get latest stable version string like "go1.22.5"
  local VERSION
  VERSION="$(curl -fsSL https://go.dev/VERSION?m=text)"
  if [ -z "${VERSION:-}" ]; then
    err "Unable to determine latest Go version."
    return 1
  fi

  # Map arch
  local ARCH_RAW ARCH_SUFFIX
  ARCH_RAW="$(uname -m)"
  case "$ARCH_RAW" in
    x86_64|amd64) ARCH_SUFFIX="amd64" ;;
    aarch64|arm64) ARCH_SUFFIX="arm64" ;;
    armv7l|armv7|armv6l|armhf) ARCH_SUFFIX="armv6l" ;; # Go provides armv6l build compatible with v6+
    *)
      warn "Unknown arch $ARCH_RAW; defaulting to amd64."
      ARCH_SUFFIX="amd64"
      ;;
  esac

  local TARBALL="${VERSION}.linux-${ARCH_SUFFIX}.tar.gz"
  local URL="https://go.dev/dl/${TARBALL}"
  local TMP
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' RETURN

  info "Downloading ${URL}"
  curl -fsSL "$URL" -o "$TMP/$TARBALL"

  local PREFIX; PREFIX="$(_resolve_go_prefix)"
  local TARGET="${PREFIX}/go"

  # Remove any existing Go at the target to avoid conflicts
  if [ -d "$TARGET" ]; then
    info "Removing existing ${TARGET}"
    $SUDO rm -rf "$TARGET"
  fi

  info "Extracting to ${PREFIX}"
  $SUDO tar -C "$PREFIX" -xzf "$TMP/$TARBALL"

  # Ensure PATH updates for both system and user installs
  if [ "$PREFIX" = "/usr/local" ]; then
    ensure_path_export "/usr/local/go/bin"
  else
    ensure_path_export "${PREFIX}/go/bin"
  fi
  # Also ensure GOPATH/bin is in PATH for user tools
  ensure_path_export "${HOME}/go/bin"
}

verify_go() {
  if ! command -v go >/dev/null 2>&1; then
    err "go is not in PATH. Try: source ~/.bashrc"
    return 1
  fi
  info "go: $(go version)"
  ok "Go toolchain ready."
}

# Try package manager first for simplicity; fall back to official tarball
if ! command -v go >/dev/null 2>&1; then
  install_go_pkg || { warn "Package manager install failed or too old; using official tarball."; install_go_tarball; }
else
  info "go already present: $(go version)"
fi

# Verify and set common envs
verify_go

# Optional: set GOPATH if user hasn’t set it (non-exporting; we only add bin to PATH above)
if [ -z "${GOPATH:-}" ]; then
  info "You can set GOPATH to customize workspace, e.g.: export GOPATH=\$HOME/go"
fi

