# scripts/lib/path.sh
#!/usr/bin/env bash
set -euo pipefail

ensure_path_export() {
  local dir="$1"
  local profile="${HOME}/.bashrc"
  grep -qs "export PATH=.*${dir}" "$profile" 2>/dev/null || {
    echo "export PATH=\"${dir}:\$PATH\"" >> "$profile"
    printf "[i] Added %s to PATH in %s\n" "$dir" "$profile"
  }
}

