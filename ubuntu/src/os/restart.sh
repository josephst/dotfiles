#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {

    chapter "Restart"

    ask_for_confirmation "Do you want to restart?"
    printf "\n"

    if answer_is_yes; then
        if check_wsl; then
          print_success_muted "Running in WSL; not restarting the VM"
        else
          sudo shutdown -r now &> /dev/null
        fi
    fi

 }

 main