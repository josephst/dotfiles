script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

source "$script_dir/text_format.sh"

###############################################################################
# Utility Functions
###############################################################################

_kill_all_subprocesses() {

  local i=""

  for i in $(jobs -p); do
    kill "$i"
    wait "$i" &> /dev/null
  done

}

_set_trap() {

  trap -p "$1" | grep "$2" &> /dev/null \
    || trap '$2' "$1"

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

append_to_zshrc() {
  local text="$1" zshrc
  local skip_new_line="${2:-0}"

  if [ -w "$HOME/.zshrc.local" ]; then
    zshrc="$HOME/.zshrc.local"
  else
    zshrc="$HOME/.zshrc"
  fi

  if ! grep -Fqs "$text" "$zshrc"; then
    if [ "$skip_new_line" -eq 1 ]; then
      printf "%s\\n" "$text" >> "$zshrc"
    else
      printf "\\n%s\\n" "$text" >> "$zshrc"
    fi
  fi
}

###############################################################################
# Meta Checks
###############################################################################

check_bash_version() {
  if ((BASH_VERSINFO[0] < 3)); then
    print_error "Sorry, you need at least bash-3.0 to run this script."
    exit 1
  fi
}

check_wsl() {
  local os=""
  os="$(get_os)"

  if [[ "$os" == "ubuntu" ]] && [[ "$(cat /proc/sys/kernel/osrelease)" == *microsoft* ]]; then
    return 0 # true (is WSL)
  else
    return 1 # false (not WSL)
  fi
}

get_os() {
  local os=""
  local kernelName=""

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  kernelName="$(uname -s)"

  if [[ "$kernelName" == "Darwin" ]]; then
    os="macOS"
  elif [[ "$kernelName" == "Linux" ]] && [[ -e "/etc/lsb-release" ]]; then
    os="ubuntu"
  else
    os="$kernelName"
  fi

  printf "%s" "$os"

}

get_os_version() {

  local os=""
  local version=""

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  os="$(get_os)"

  if [ "$os" == "macOS" ]; then
    version="$(sw_vers -productVersion)"
  elif [ "$os" == "ubuntu" ]; then
    version="$(lsb_release -d | cut -f2 | cut -d' ' -f2)"
  fi

  printf "%s" "$version"

}

get_installed_package_version() {
  dpkg -s "$1" | grep '^Version' | cut -d' ' -f2
}

check_internet_connection() {
  if [[ $(ping -q -w 1 -c 1 google.com &> /dev/null) ]]; then
    print_error "Please check your internet connection";
  exit 0
  else
    print_success "Internet connection";
  fi
}

###############################################################################
# Execution
###############################################################################

execute() {

  local -r CMDS="$1"
  local -r MSG="${2:-$1}"
  local -r TMP_FILE="$(mktemp /tmp/XXXXX)"

  local exitCode=0
  local cmdsPID=""

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # If the current process is ended,
  # also end all its subprocesses.

  _set_trap "EXIT" "_kill_all_subprocesses"

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Execute commands in background

  eval "$CMDS" \
  &> /dev/null \
  2> "$TMP_FILE" &

  cmdsPID=$!

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Show a spinner if the commands
  # require more time to complete.

  _show_spinner "$cmdsPID" "$CMDS" "$MSG"

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Wait for the commands to no longer be executing
  # in the background, and then get their exit code.

  wait "$cmdsPID" &> /dev/null
  exitCode=$?

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Print output based on what happened.

  print_result $exitCode "$MSG"

  if [ $exitCode -ne 0 ]; then
    _print_error_stream < "$TMP_FILE"
  fi

  rm -rf "$TMP_FILE"

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  return $exitCode

}

mkd() {
  if [ -n "$1" ]; then
    if [ -e "$1" ]; then
      if [ ! -d "$1" ]; then
        print_error "$1 - a file with the same name already exists!"
      else
        print_success_muted "$1 already exists. Skipped."
      fi
    else
      execute "mkdir -p $1" "$1"
    fi
  fi
}

symlink_dotfiles() {
  local overwrite_all=false backup_all=false skip_all=false

  # TODO: preserve directory structure (for example, symlink within a .config folder)
  for src in $(find -H "$DOTFILES_ROOT" -maxdepth 2 -name '*.symlink' -not -path '*.git*')
  do
    dst="$HOME/.$(basename "${src%.*}")"
    _link_file "$src" "$dst"
  done
}

###############################################################################
# Misc user-created functions
###############################################################################

install_bat() {
  BAT_VERSION=$(get_github_version_latest sharkdp/bat)
  # remove 'v' from filename (ex v0.17.1 => 0.17.1)
  BAT_FILENAME=bat_${BAT_VERSION#v}_amd64.deb
  if [[ -x $(command -v bat) ]] || [[ -x $(command -v batcat) ]] ; then
    # bat is installed; check for updates
    INSTALLED_BAT_VERSION=$(get_installed_package_version bat)
    if dpkg --compare-versions "$INSTALLED_BAT_VERSION" "lt" "${BAT_VERSION#v}"; then
      # update bat
      install_update_dpkg "https://github.com/sharkdp/bat/releases/download/$BAT_VERSION/$BAT_FILENAME"
      print_in_green "    ✓ bat $BAT_VERSION installed\n"
    else
      print_success_muted "bat already installed and up to date. Skipping"
    fi
  else
    # bat not yet installed
    install_update_dpkg "https://github.com/sharkdp/bat/releases/download/$BAT_VERSION/$BAT_FILENAME"
    print_in_green "    ✓ bat $BAT_VERSION installed\n"
  fi
}

# The releases are returned in the format
# {"id":3622206,"tag_name":"hello-1.0.0.11",…}
# we have to extract the tag_name.
get_github_version_latest() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | jq -r .tag_name
}

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

  if [[ created_file == "true" ]]; then
    print_result $? "$FILE_PATH"
  else
    print_success_muted "$FILE_PATH already exists. Skipping."
  fi
}