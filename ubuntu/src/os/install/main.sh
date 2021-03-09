#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
  && source "../utils.sh" \
  && source "utils.sh"

chapter "Installs"

update
upgrade

# install packages
./install_apt_packages.sh

# install asdf version manager (and nodejs+ruby)
./install_asdf.sh

# npm packages
./install_npm_packages.sh

# ruby packages
./install_ruby_packages.sh

# rust
./install_rust.sh

# bat
./install_bat.sh

# ripgrep
./install_ripgrep.sh

# fd
./install_fd.sh
