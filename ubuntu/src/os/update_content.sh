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

  # if ask "Do you want to update the content from the 'dotfiles' directory?" "Y"; then

  #     git fetch --all 1> /dev/null \
  #         && git reset --hard origin/master 1> /dev/null \
  #         && git checkout master &> /dev/null \
  #         && git clean -fd 1> /dev/null

  #     print_result $? "Update content"

  # fi

  if ask "Do you want to update the content from the 'dotfiles' directory?" "Y"; then
    if [[ -z "$(git status --porcelain)" ]]; then
      # no changes or untracked files; safe to update
      git fetch --all 1> /dev/null \
        && git checkout master &> /dev/null
      
      print_result $? "Update content"
    else
      print_error "Changes and/ or untracked files present in git repo; not updating."
    fi
  fi
}

main