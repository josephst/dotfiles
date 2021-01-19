#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
  && . "../utils.sh"

download_omz_installer() {
  declare -r OMZ_INSTALLER="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
  local tmpFile=""

  tmpFile="$(mktemp /tmp/XXXXX)"

  download "$OMZ_INSTALLER" "$tmpFile" \
  && sh -c "$tmpFile" \
  && rm -rf "$tmpFile" \
  && return 0

  return 1
}

download() {

  local url="$1"
  local output="$2"

  if command -v "curl" &> /dev/null; then

    curl -LsSo "$output" "$url" &> /dev/null
    #     │││└─ write output to file
    #     ││└─ show error messages
    #     │└─ don't show the progress meter
    #     └─ follow redirects

    return $?

  elif command -v "wget" &> /dev/null; then

    wget -qO "$output" "$url" &> /dev/null
    #     │└─ write output to file
    #     └─ don't show output

    return $?
  fi

  return 1

}

install_omz() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    print_success_muted "OMZ already installed. Skipping."
  else
    # zsh installed by apt
    declare -r OMZ_INSTALLER="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
    local tmpFile=""

    tmpFile="$(mktemp /tmp/XXXXX)"

    download "$OMZ_INSTALLER" "$tmpFile"

    # delete zshrc so that there's not a file conflict when symlinking later
    execute "sh -c $tmpFile --unattended \
      && rm ~/.zshrc \
      && rm -rf $tmpFile \
      && return 0" "oh-my-zsh install script"
    # 
  fi
}

install_starship() {
  if command -v "starship" &> /dev/null; then
    print_success_muted "Starship already installed. Skipping"
  else
    declare -r STARSHIP_INSTALLER="https://starship.rs/install.sh"
    local tmpFile=""

    tmpFile="$(mktemp /tmp/XXXXX)"

    download "$STARSHIP_INSTALLER" "$tmpFile"

    execute "sudo bash $tmpFile -y \
      && rm -rf $tmpFile \
      && return 0" "starship install script"
  fi
}

change_shell() {
  local shell_path;
  shell_path="$(command -v zsh)"

  if ! grep "$shell_path" /etc/shells &> /dev/null ; then
    print_in_green "Adding '$shell_path' to /etc/shells"
    sudo sh -c "echo $shell_path >> /etc/shells"
  fi
  sudo chsh -s "$shell_path" "$USER"
  print_success "Zsh set as default"
}

main() {
  step "oh-my-zsh"
  install_omz

  step "starship"
  install_starship

  step "changing shells"
  change_shell
}

main