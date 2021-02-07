#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && \
  source "./utils.sh"
declare -r DOTFILES_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../dotfiles" &>/dev/null && pwd -P)

symlink_dotfiles() {
  local overwrite_all=false backup_all=false skip_all=false

  # TODO: preserve directory structure (for example, symlink within a .config folder)
  for src in $(find -H "$DOTFILES_ROOT" -maxdepth 2 -name '*.symlink' -not -path '*.git*')
  do
    dst="$HOME/.$(basename "${src%.*}")"
    _link_file "$src" "$dst"
  done
}

_link_file() {
  local src=$1 dst=$2

  local overwrite=
  local backup=
  local skip=
  local action=

  # -f = file exists; -d = directory exists; -L = symlink exists
  if [ -f "$dst" ] || [ -d "$dst" ] || [ -L "$dst" ]; then
    if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]; then
      local currentSrc

      if [[ -L "$dst" ]]; then
        currentSrc=$(readlink "$dst")
      fi

      if [[ -n "${currentSrc:-}" ]] && [[ "$currentSrc" == "$src" ]]; then
        # check if currentSrc is non-empty && if it points to the existing symlink
        skip=true;
      else
        print_warning "File already exists: $dst ($(basename "$src")), what do you want to do?
      [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
        read -r -n 1 action

        case "$action" in
          o )
            overwrite=true;;
          O )
            overwrite_all=true;;
          b )
            backup=true;;
          B )
            backup_all=true;;
          s )
            skip=true;;
          S )
            skip_all=true;;
          * )
            ;;
          esac
        fi
      fi

    overwrite=${overwrite:-$overwrite_all}
    backup=${backup:-$backup_all}
    skip=${skip:-$skip_all}

    if [ "$overwrite" == "true" ]; then
      rm -rf "$dst"
      print_success "deleted $dst"
    fi

    if [ "$backup" == "true" ]; then
      mv "$dst" "${dst}.backup"
      print_success "moved $dst to ${dst}.backup"
    fi

    if [ "$skip" == "true" ]; then
      print_success_muted "$src already linked. Skipped."
    fi
  fi

  if [ "$skip" != "true" ]; then
      # "false" or empty
    ln -s "$1" "$2"
    print_success "linked $1 to $2"
  fi
}

main() {
  chapter "Symlinking Dotfiles"
  symlink_dotfiles
}

main