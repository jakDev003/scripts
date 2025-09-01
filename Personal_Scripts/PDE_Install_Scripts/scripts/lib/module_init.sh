#!/usr/bin/env bash
set -euo pipefail

# Resolve ROOT_DIR if not provided (supports running modules directly)
: "${ROOT_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
export ROOT_DIR

# Load shared libs
# shellcheck source=./log.sh
source "${ROOT_DIR}/scripts/lib/log.sh"
# shellcheck source=./os.sh
source "${ROOT_DIR}/scripts/lib/os.sh"
# shellcheck source=./path.sh
source "${ROOT_DIR}/scripts/lib/path.sh"

# Ensure OS/PM globals exist when running a module directly
if [ -z "${PM:-}" ] || [ -z "${DIST_ID:-}" ]; then
  detect_os_and_pm
fi

