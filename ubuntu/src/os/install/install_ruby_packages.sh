#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
  && source "../utils.sh" \
  && source "utils.sh"

gem_install_or_update() {
  if gem list "$1" --installed > /dev/null; then
    execute "gem update $1 --no-document" "$1"
  else
    execute "gem install $1 --no-document" "$1"
  fi
}

main() {
  step "Ruby gems"
  source "$HOME/.bash.local"
  gem_install_or_update rails
  gem_install_or_update rubocop
}

main