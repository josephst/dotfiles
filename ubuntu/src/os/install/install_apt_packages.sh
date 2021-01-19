#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
  && source "../utils.sh" \
  && source "utils.sh"

step "APT install"

# build-essential
install_package "Build Essential" "build-essential"

# GnuPG archive keys of the Debian archive.
install_package "GnuPG archive keys" "debian-archive-keyring"

# Git
install_package "Git" "git"

# Zsh
install_package "Zsh" "zsh"

# Vim and Neovim
install_package "Vim" "vim"
if ! package_is_installed "neovim"; then
  add_ppa "neovim-ppa/stable" \
    || print_error "Neovim (add PPA)"
  
  update $> /dev/null \
    || print_error "Neovim (resync package files)"
fi
install_package "Neovim (nvim)" "neovim"

# Curl
install_package "cURL" "curl"

# HTTPie
install_package "HTTPie" "httpie"

# jq
install_package "jq" "jq"

# Library files (for building Ruby)
install_package "Ruby library files" "autoconf bison libffi-dev libgdbm-dev libgdbm6 libncurses5-dev libreadline-dev libsqlite3-dev libssl-dev libyaml-dev zlib1g-dev"

# CLEANUP
step "Cleanup"
autoremove