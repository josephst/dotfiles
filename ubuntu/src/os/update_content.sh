#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && source "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {

    ssh -T git@github.com &> /dev/null

    if [ $? -ne 1 ]; then
        ./ssh_setup.sh \
            || return 1
    fi

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    chapter "Update content"

    ask_for_confirmation "Do you want to update the content from the 'dotfiles' directory?"

    if answer_is_yes; then

        git fetch --all 1> /dev/null \
            && git reset --hard origin/main 1> /dev/null \
            && git checkout main &> /dev/null \
            && git clean -fd 1> /dev/null

        print_result $? "Update content"

    fi

}

main