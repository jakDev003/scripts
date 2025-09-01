# run-all.sh
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ROOT_DIR

source "$ROOT_DIR/scripts/lib/log.sh"
source "$ROOT_DIR/scripts/lib/os.sh"
source "$ROOT_DIR/scripts/lib/path.sh"

bold "==> Dev environment bootstrap (modular)"

# Detect OS + package manager early so modules can use globals
detect_os_and_pm

# Execute modules in sequence
for mod in 01-prereqs 05-gcc 10-node 15-ripgrep 20-python 25-rust 27-go 30-dotnet 40-lazygit 50-verify; do
  bold "==> Running module: ${mod}"
  bash "$ROOT_DIR/scripts/${mod}.sh"
done

bold "==> All set!"
echo "Reload your shell or run: source ~/.bashrc"

