#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
  && source "../utils.sh" \
  && source "utils.sh"

install_rust() {
  local -r RUSTUP_SCRIPT="https://sh.rustup.rs"
  local tmpFile=""

  tmpFile="$(mktemp /tmp/XXXXX)"

  curl -q --proto '=https' --tlsv1.2 -sSf "$RUSTUP_SCRIPT" -o "$tmpFile" &> /dev/null
  execute "sh $tmpFile -y" "Rustup installer"
}

main() {
  step "Rust"
  if cmd_exists "rustup"; then
    # already installed rust
    print_success_muted "Rust already installed. Skipping."
  else
    install_rust
  fi
  source "$HOME/.cargo/env"
}

main