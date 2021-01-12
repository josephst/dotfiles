script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

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

  if [ -n "${TRAVIS:-}" ] && [ "$TRAVIS" != "true" ]; then
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