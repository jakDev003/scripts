#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=../lib/module_init.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/module_init.sh"

bold "Verifying installed toolchain"

pad() { printf "%-14s" "$1"; }
show() {
  local label="$1"; shift
  local cmd=("$@")
  if command -v "${cmd[0]}" >/dev/null 2>&1; then
    local out
    # Capture only the first line of version output; ignore errors
    out="$("${cmd[@]}" 2>/dev/null | head -n1 || true)"
    # Some tools (like dotnet) print just a version number; fallback if empty
    if [ -z "$out" ]; then
      out="$("${cmd[0]}" --version 2>/dev/null | head -n1 || true)"
    fi
    printf "%s %s\n" "$(pad "${label}:")" "${out:-OK}"
  else
    printf "%s %s\n" "$(pad "${label}:")" "not found"
  fi
}

echo "— Runtimes —"
show "Node"        node --version
show "npm"         npm --version
show "Prettier"    npx --yes prettier --version
show "Python"      python3 --version
show "Go"          go version
show "Rust"        rustc --version
show "Cargo"       cargo --version
show ".NET SDK"    dotnet --version

echo
echo "— Python tooling —"
show "Black"       python3 -m black --version
show "Pylint"      python3 -m pylint --version

echo
echo "— .NET tooling —"
show "CSharpier"   csharpier --version

echo
echo "— CLI utilities —"
show "ripgrep"     rg --version
show "lazygit"     lazygit --version

echo
ok "Verification complete. If something shows 'not found', re-run the corresponding module or check PATH:"
echo "  - \$HOME/.local/bin       (Python user tools)"
echo "  - \$HOME/.dotnet/tools    (dotnet global tools)"
echo "  - \$HOME/.cargo/bin       (rustup/cargo)"
echo "  - /usr/local/go/bin or your Go install bin"
echo
echo "Tip: apply to current shell:"
echo "  source ~/.bashrc"

