#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../utils.sh"

chapter "Themes, Configuration, and Preferences"

./zsh.sh
./neovim.sh