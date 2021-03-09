#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
  && source "../utils.sh" \
  && source "utils.sh"

install_bat() {
  declare bat_version=""
  bat_version=$(get_github_version_latest sharkdp/bat)
  # remove 'v' from filename (ex v0.17.1 => 0.17.1)
  declare -r bat_filename=bat_${bat_version#v}_amd64.deb
  declare -r bat_installer_url="https://github.com/sharkdp/bat/releases/download/$bat_version/$bat_filename"

  declare should_install="false"

  if cmd_exists bat || cmd_exists batcat; then
    # bat installed, check version
    declare local_bat_version=""
    local_bat_version=$(get_installed_package_version bat)

    if dpkg --compare-versions "$local_bat_version" "lt" "${bat_version#v}"; then
      should_install="true"
    else
      print_success_muted "Bat already installed and up-to-date. Skipping."
    fi
  else
    # bat not yet installed
    should_install="true"
  fi

  if [[ $should_install == "true" ]]; then
    download_install_dpkg "$bat_installer_url" "Install bat $bat_version"
  fi  
}


main() {
  step "bat"
  install_bat
}

main
