# scripts/lib/os.sh
#!/usr/bin/env bash
set -euo pipefail

# Globals every module can use:
#   SUDO, DIST_ID, PM, PM_INSTALL, PM_GROUPDEV
detect_os_and_pm() {
  if [ -r /etc/os-release ]; then
    . /etc/os-release
    DIST_ID=${ID:-unknown}
  else
    DIST_ID="$(uname -s | tr '[:upper:]' '[:lower:]')"
  fi
  export DIST_ID

  if [ "${EUID:-$(id -u)}" -ne 0 ] && command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
  else
    SUDO=""
  fi
  export SUDO

  case "$DIST_ID" in
    debian|ubuntu|raspbian|linuxmint|pop|neon)
      PM="apt-get"
      PM_INSTALL="$SUDO apt-get update && $SUDO apt-get install -y"
      PM_GROUPDEV=""
      ;;
    fedora)
      PM="dnf"
      PM_INSTALL="$SUDO dnf install -y"
      PM_GROUPDEV="$SUDO dnf groupinstall -y 'Development Tools'"
      ;;
    rhel|centos|rocky|almalinux|ol)
      if command -v dnf >/dev/null 2>&1; then
        PM="dnf"; PM_INSTALL="$SUDO dnf install -y"
        PM_GROUPDEV="$SUDO dnf groupinstall -y 'Development Tools'"
      else
        PM="yum"; PM_INSTALL="$SUDO yum install -y"
        PM_GROUPDEV="$SUDO yum groupinstall -y 'Development Tools'"
      fi
      ;;
    arch|manjaro|endeavouros)
      PM="pacman"
      PM_INSTALL="$SUDO pacman -Sy --noconfirm --needed"
      PM_GROUPDEV="$SUDO pacman -S --noconfirm --needed base-devel"
      ;;
    opensuse*|suse|sles|sle*)
      PM="zypper"
      PM_INSTALL="$SUDO zypper -n install"
      PM_GROUPDEV="" # install gcc/make directly
      ;;
    alpine)
      PM="apk"
      PM_INSTALL="$SUDO apk add --no-cache"
      PM_GROUPDEV="$SUDO apk add --no-cache build-base"
      ;;
    *)
      # Fallback autodetect
      if command -v apt-get >/dev/null 2>&1; then
        PM="apt-get"; PM_INSTALL="$SUDO apt-get update && $SUDO apt-get install -y"
      elif command -v dnf >/dev/null 2>&1; then
        PM="dnf"; PM_INSTALL="$SUDO dnf install -y"
      elif command -v pacman >/dev/null 2>&1; then
        PM="pacman"; PM_INSTALL="$SUDO pacman -Sy --noconfirm --needed"
      elif command -v zypper >/dev/null 2>&1; then
        PM="zypper"; PM_INSTALL="$SUDO zypper -n install"
      elif command -v apk >/dev/null 2>&1; then
        PM="apk"; PM_INSTALL="$SUDO apk add --no-cache"
      else
        err "No supported package manager found."; exit 1
      fi
      PM_GROUPDEV=""
      ;;
  esac

  export PM PM_INSTALL PM_GROUPDEV
  bold "Using $PM on $DIST_ID"
}

