# scripts/40-lazygit.sh
#!/usr/bin/env bash
set -euo pipefail
source "${ROOT_DIR}/scripts/lib/log.sh"
source "${ROOT_DIR}/scripts/lib/os.sh"

install_lazygit_pkg() {
  bold "Installing LazyGit via package manager"
  case "$PM" in
    apt-get) $SUDO apt-get install -y lazygit || return 1 ;;
    dnf|yum) $SUDO $PM install -y lazygit || return 1 ;;
    pacman)  $SUDO pacman -Sy --noconfirm --needed lazygit || return 1 ;;
    zypper)  $SUDO zypper -n install lazygit || return 1 ;;
    apk)     $SUDO apk add --no-cache lazygit || return 1 ;;
    *)       return 1 ;;
  esac
  return 0
}

install_lazygit_github() {
  bold "Installing LazyGit via GitHub release (latest)"
  ARCH="$(uname -m)"
  OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
  case "$ARCH" in
    x86_64|amd64) LG_ARCH="x86_64" ;;
    aarch64|arm64) LG_ARCH="arm64" ;;
    armv7l|armv7) LG_ARCH="armv7" ;;
    *) warn "Unknown arch $ARCH; defaulting x86_64"; LG_ARCH="x86_64" ;;
  esac

  LATEST="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep -Po '"tag_name":\s*"\K[^"]+')"
  [ -n "${LATEST:-}" ] || { err "Could not resolve latest version"; return 1; }

  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' RETURN
  TARBALL="lazygit_${LATEST#v}_${OS}_${LG_ARCH}.tar.gz"
  URL="https://github.com/jesseduffield/lazygit/releases/download/${LATEST}/${TARBALL}"

  info "Downloading $URL"
  curl -fsSL "$URL" -o "$TMP/$TARBALL"
  tar -xzf "$TMP/$TARBALL" -C "$TMP"
  $SUDO install -m 0755 "$TMP/lazygit" /usr/local/bin/lazygit
  ok "LazyGit installed to /usr/local/bin/lazygit"
}

if ! command -v lazygit >/dev/null 2>&1; then
  install_lazygit_pkg || { warn "Pkg install failed; using GitHub binary"; install_lazygit_github; }
else
  info "lazygit present: $(lazygit --version || true)"
fi

ok "LazyGit ready."

