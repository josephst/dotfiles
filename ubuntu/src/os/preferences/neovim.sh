#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../utils.sh"

NVIM_CONFIG="$HOME/.config/nvim/init.vim"
NVIM_CONFIG_DIR=$(dirname "$NVIM_CONFIG")

# TODO: try to find a way to make this part of the dotfiles linking
create_neovim_config() {
  touch "$NVIM_CONFIG"

  printf "%s\n" \
  "set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc" \
  >> "$NVIM_CONFIG"
  print_success "Neovim config created."
}

main() {
  step "Neovim config"
  if ! [[ -e $NVIM_CONFIG ]]; then
    [[ -d $NVIM_CONFIG_DIR ]] || mkdir -p "$HOME/.config/nvim"
    create_neovim_config
  else
    print_success_muted "Neovim config already present"
  fi
}

main
