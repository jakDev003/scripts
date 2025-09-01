# scripts/30-dotnet.sh
#!/usr/bin/env bash
set -euo pipefail
source "${ROOT_DIR}/scripts/lib/log.sh"
source "${ROOT_DIR}/scripts/lib/os.sh"
source "${ROOT_DIR}/scripts/lib/path.sh"

install_dotnet_via_pkgmgr() {
  bold "Installing .NET 8 SDK via package manager"
  case "$PM" in
    apt-get)
      if ! $SUDO apt-get install -y dotnet-sdk-8.0 2>/dev/null; then
        info "Adding Microsoft repo (Debian/Ubuntu family)"
        $SUDO mkdir -p /etc/apt/keyrings
        curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | $SUDO tee /etc/apt/keyrings/microsoft.gpg >/dev/null
        $SUDO chmod 644 /etc/apt/keyrings/microsoft.gpg
        . /etc/os-release
        CODENAME="${VERSION_CODENAME:-stable}"
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/ubuntu/${VERSION_ID:-22.04}/prod ${CODENAME} main" | $SUDO tee /etc/apt/sources.list.d/microsoft-prod.list >/dev/null || true
        $SUDO apt-get update
        $SUDO apt-get install -y dotnet-sdk-8.0 || return 1
      fi
      ;;
    dnf|yum)
      $SUDO $PM install -y dotnet-sdk-8.0 || {
        info "Adding Microsoft repo (RHEL/Fedora family)"
        $SUDO $PM install -y "https://packages.microsoft.com/config/$(. /etc/os-release; echo "$ID/$VERSION_ID")/packages-microsoft-prod.rpm" || true
        $SUDO $PM install -y dotnet-sdk-8.0 || return 1
      }
      ;;
    pacman)
      $SUDO pacman -Sy --noconfirm --needed dotnet-sdk || return 1
      ;;
    zypper)
      $SUDO zypper -n install dotnet-sdk-8.0 || {
        info "Adding Microsoft repo (openSUSE/SLES)"
        $SUDO zypper -n addrepo "https://packages.microsoft.com/config/$(. /etc/os-release; echo "$ID/$VERSION_ID")/prod.repo" microsoft-prod || true
        $SUDO zypper -n refresh
        $SUDO zypper -n install dotnet-sdk-8.0 || return 1
      }
      ;;
    apk)
      # Alpine: generally no official .NET 8 package — fall back
      return 1
      ;;
    *) return 1 ;;
  esac
  return 0
}

install_dotnet_via_script() {
  bold "Installing .NET 8 SDK via official script (per-user)"
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' RETURN
  curl -fsSL https://dot.net/v1/dotnet-install.sh -o "$TMP/dotnet-install.sh"
  bash "$TMP/dotnet-install.sh" --channel 8.0 --install-dir "$HOME/.dotnet"
  ensure_path_export "$HOME/.dotnet"
  ensure_path_export "$HOME/.dotnet/tools"
}

if ! command -v dotnet >/dev/null 2>&1; then
  if ! install_dotnet_via_pkgmgr; then
    warn "Package manager install failed/unavailable; using dotnet-install."
    install_dotnet_via_script
  fi
else
  info "dotnet present: $(dotnet --version)"
fi

bold "Installing CSharpier (global dotnet tool)"
if ! command -v csharpier >/dev/null 2>&1; then
  dotnet tool install -g csharpier
  ensure_path_export "$HOME/.dotnet/tools"
else
  dotnet tool update -g csharpier || true
fi

ok ".NET SDK + CSharpier installed."

