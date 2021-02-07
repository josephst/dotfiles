#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
  && source "../utils.sh" \
  && source "utils.sh"

install_npm_package() {
    execute ". $HOME/.bash.local \
      && npm install --global --silent $2" \
      "$1"
}

main() {
  step "npm packages"
  install_npm_package "npm (update)" "npm"
  install_npm_package "ncu" "npm-check-updates"
  install_npm_package "prettier" "prettier"
  install_npm_package "serve" "serve"
  install_npm_package "tldr" "tldr"
}

main