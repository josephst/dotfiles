#!/bin/bash

###############################################################################
# VARIABLES
###############################################################################

count=1

# TODO: convert escape sequences to tput color code lookups (see _print_in_color() )
reset="\033[0m"
highlight="\033[41m\033[97m"
dot="\033[31m▸ $reset"
dim="\033[2m"
blue="\e[34m"
green="\e[32m"
yellow="\e[33m"
tag_green="\e[30;42m"
tag_blue="\e[30;46m"
bold=$(tput bold)
normal=$(tput sgr0)
underline="\e[37;4m"
indent="    "

###############################################################################
# Print Functions
###############################################################################

_print_in_color() {
  printf "%b" \
    "$(tput setaf "$2" 2> /dev/null)" \
    "$1" \
    "$(tput sgr0 2> /dev/null)"
}

_print_error_stream() {
  while read -r line; do
    print_in_red "     ↳ ERROR: $line\n"
  done
}

_show_spinner() {
  local -r FRAMES='/-\|'

  # shellcheck disable=SC2034
  local -r NUMBER_OR_FRAMES=${#FRAMES}

  local -r CMDS="$2"
  local -r MSG="$3"
  local -r PID="$1"

  local i=0
  local frameText=""

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Note: In order for the Travis CI site to display
    # things correctly, it needs special treatment, hence,
    # the "is Travis CI?" checks.

    if [ "$TRAVIS" != "true" ]; then

        # Provide more space so that the text hopefully
        # doesn't reach the bottom line of the terminal window.
        #
        # This is a workaround for escape sequences not tracking
        # the buffer position (accounting for scrolling).
        #
        # See also: https://unix.stackexchange.com/a/278888

        printf "\n\n\n"
        tput cuu 3

        tput sc

    fi

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Display spinner while the commands are being executed.

  while kill -0 "$PID" &>/dev/null; do

    frameText=" [${FRAMES:i++%NUMBER_OR_FRAMES:1}] $MSG"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Print frame text.

    if [ "$TRAVIS" != "true" ]; then
        printf "%s\n" "$frameText"
      else
        printf "%s" "$frameText"
    fi

    sleep 0.2

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Clear frame text.

    if [ "$TRAVIS" != "true" ]; then
      tput rc
    else
      printf "\r"
    fi

  done

}

print_in_red() {
  _print_in_color "$1" 1
}

print_in_green() {
  _print_in_color "$1" 2
}

print_in_yellow() {
  _print_in_color "$1" 3
}

print_in_blue() {
  _print_in_color "$1" 4
}

print_in_purple() {
  _print_in_color "$1" 5
}

print_in_cyan() {
  _print_in_color "$1" 6
}

print_in_white() {
  _print_in_color "$1" 7
}

print_result() {
  if [ "$1" -eq 0 ]; then
    print_success "$2"
  else
    print_error "$2"
  fi

  return "$1"
}

print_question() {
  print_in_yellow "  [?] $1\n"
}

print_success() {
  print_in_green "  [✓] $1\n"
}

print_success_muted() {
  printf "  ${dim}[✓] $1${reset}\n" "$@"
}

print_muted() {
  printf "  ${dim}$1${reset}\n" "$@"
}

print_warning() {
  print_in_yellow "  [!] $1\n"
}

print_error() {
  print_in_red "  [𝘅] $1 $2\n"
}

###############################################################################
# Text Formatting
###############################################################################
title() {
  local fmt="$1"; shift
  printf "\n✦  ${bold}$fmt${normal}\n└─────────────────────────────────────────────────────○\n" "$@"
}

chapter() {
  local fmt="$1"; shift
  printf "\n✦  ${bold}$((count++)). $fmt${normal}\n└─────────────────────────────────────────────────────○\n" "$@"
}

echo_install() {
  local fmt="$1"; shift
  printf "  [↓] $fmt " "$@"
}

todo() {
  local fmt="$1"; shift
  printf "  [ ] $fmt\n" "$@"
}

inform() {
  local fmt="$1"; shift
  printf "   ✦  $fmt\n" "$@"
}

announce() {
  local fmt="$1"; shift
  printf "○───✦ $fmt\n" "$@"
}

step() {
  printf "\n   ${dot}${underline}$*${reset}\n"
}

label_blue() {
  printf "\e[30;46m $1 \033[0m\e[34m $2 \033[0m\n"
}

label_green() {
  printf "\e[30;42m $1 \e[0m\e[32m $2 \033[0m\n"
}

e_lemon_ated() {
  printf "
    ${bold}Congrats! You're in formation!${normal} 🍋

    ╭────────────────────────────────────────────────────╮
    │ Thanks for using Formation!                        │
    │ If you liked it, then you should put a star on it! │
    │                                                    │
    │ https://github.com/minamarkham/formation           │
    ╰────────────────────────────────────────────────────╯

    "
}

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
  2>| "$TMP_FILE" &

  # >| is used to overwrite the "noclobber" bash option; it's safe
  # to overwrite the tmp_file

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

###############################################################################
# Prompts
###############################################################################
ask_for_sudo() {

  # Ask for the administrator password upfront.

  sudo -v &> /dev/null

  # Update existing `sudo` time stamp
  # until this script has finished.
  #
  # https://gist.github.com/cowboy/3118588

  # Keep-alive: update existing `sudo` time stamp until script has finished
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
    print_success "Password cached"

}

ask() {
# https://djm.me/ask
# https://gist.github.com/davejamesmiller/1965569
  local prompt default reply

  if [ "${2:-}" = "Y" ]; then
    prompt="Y/n"
    default=Y
  elif [ "${2:-}" = "N" ]; then
    prompt="y/N"
    default=N
  else
    prompt="y/n"
    default=
  fi

  while true; do

    # Ask the question (not using "read -p" as it uses stderr not stdout)
    echo -n "  [?] $1 [$prompt] "

    # Read the answer (use /dev/tty in case stdin is redirected from somewhere else)
    read -r reply </dev/tty

    # Default?
    if [ -z "$reply" ]; then
      reply=$default
    fi

    # Check if the reply is valid
    case "$reply" in
        Y*|y*) return 0 ;;
        N*|n*) return 1 ;;
    esac

  done
}
