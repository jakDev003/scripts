#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=../lib/module_init.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/module_init.sh"

bold "Installing Rust (rustup, stable toolchain, rustfmt, clippy)"

# Prefer rustup (per-user, most reliable & up-to-date)
if ! command -v rustup >/dev/null 2>&1; then
  curl https://sh.rustup.rs -sSf | sh -s -- -y --profile default --default-toolchain stable
  ok "rustup installed."
else
  info "rustup already present: $(rustup --version)"
fi

# Ensure cargo/rustup on PATH for current and future shells
ensure_path_export "${HOME}/.cargo/bin"
# shellcheck disable=SC1090
[ -f "${HOME}/.cargo/env" ] && . "${HOME}/.cargo/env" || true

# Toolchain & components
rustup toolchain install stable
rustup default stable
rustup component add rustfmt clippy || warn "Could not add rustfmt/clippy (may be already installed)."

# Quick verification
if command -v cargo >/dev/null 2>&1; then
  info "cargo: $(cargo --version)"
  info "rustc: $(rustc --version)"
  info "rustfmt: $(rustfmt --version || echo 'not found')"
  ok "Rust toolchain ready."
else
  err "cargo not found in PATH. Try: source ~/.bashrc"
  exit 1
fi

