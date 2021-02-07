#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {

    chapter "Restart"

    if ask "Do you want to restart?" "n"; then
        if check_wsl; then
          print_success_muted "Running in WSL; not restarting the VM"
        else
          sudo shutdown -r now &> /dev/null
        fi
    fi

 }

 main