script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

source "$script_dir/text_format.sh"

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
