#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && \
  source "./utils.sh"

# from Cătălin’s dotfiles (https://github.com/alrra/dotfiles)
create_gitconfig_local() {

  local FILE_PATH="$HOME/.gitconfig.local"
  local created_file="false"

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  if [[ ! -e "$FILE_PATH" ]]; then
    printf "%s\n" \
"[commit]
  # Sign commits using GPG.
  # https://help.github.com/articles/signing-commits-using-gpg/
  # gpgsign = true
[user]
  name =
  email =
  # signingkey =" \
    >> "$FILE_PATH"
  created_file="true" # 0 for true (created a new file)
  fi

  if [[ $created_file == "true" ]]; then
    print_result $? "$FILE_PATH"
  else
    print_success_muted "$FILE_PATH already exists. Skipping."
  fi
}

create_bash_local() {

  declare -r FILE_PATH="$HOME/.bash.local"
  local created_file="false"

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  if [ ! -e "$FILE_PATH" ] || [ -z "$FILE_PATH" ]; then
    DOTFILES_BIN_DIR="$(dirname "$(pwd)")/bin/"

    printf "%s\n" \
"#!/bin/bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set PATH additions.
# PATH=\"$DOTFILES_BIN_DIR:\$PATH\"
# export PATH
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
" \
    >> "$FILE_PATH"
    created_file="true"
   fi
   if [[ $created_file == "true" ]]; then
    print_result $? "$FILE_PATH"
  else
    print_success_muted "$FILE_PATH already exists. Skipping"
  fi

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {

    chapter "Create local config files"

    create_bash_local
    create_gitconfig_local
    # create_vimrc_local

}

main
