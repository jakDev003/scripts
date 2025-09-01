# scripts/20-python.sh
#!/usr/bin/env bash
set -euo pipefail
source "${ROOT_DIR}/scripts/lib/log.sh"
source "${ROOT_DIR}/scripts/lib/os.sh"
source "${ROOT_DIR}/scripts/lib/path.sh"

bold "Installing Python 3 + pip"
case "$PM" in
  apt-get) eval "$PM_INSTALL python3 python3-pip" ;;
  dnf|yum) eval "$PM_INSTALL python3 python3-pip" ;;
  pacman)  eval "$PM_INSTALL python python-pip" ;;
  zypper)  eval "$PM_INSTALL python3 python3-pip" ;;
  apk)     eval "$PM_INSTALL python3 py3-pip" ;;
esac

bold "Installing Black + Pylint (user)"
python3 -m pip install --user --upgrade pip
python3 -m pip install --user black pylint
ensure_path_export "${HOME}/.local/bin"

ok "Python toolchain installed."

