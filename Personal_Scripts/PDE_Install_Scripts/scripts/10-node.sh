# scripts/10-node.sh
#!/usr/bin/env bash
set -euo pipefail
source "${ROOT_DIR}/scripts/lib/log.sh"
source "${ROOT_DIR}/scripts/lib/path.sh"

bold "Installing NVM"
if [ ! -d "${HOME}/.nvm" ]; then
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
else
  info "NVM already present"
fi

export NVM_DIR="$HOME/.nvm"
# shellcheck disable=SC1090
. "$NVM_DIR/nvm.sh"

bold "Installing Node 20 and Prettier"
nvm install 20
nvm use 20
npm install -g npm
npm install -g prettier
ok "Node 20 + Prettier installed."

