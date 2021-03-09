#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
  && source "../utils.sh" \
  && source "utils.sh"

install_ripgrep() {
  declare remote_version=""
  remote_version=$(get_github_version_latest BurntSushi/ripgrep)
  # remove 'v' from filename (ex v0.17.1 => 0.17.1)
  declare -r filename=ripgrep_${remote_version}_amd64.deb
  declare -r installer_url="https://github.com/BurntSushi/ripgrep/releases/download/$remote_version/$filename"

  declare should_install="false"

  if cmd_exists rg; then
    # ripgrep installed, check version
    declare local_version=""
    local_version=$(get_installed_package_version ripgrep)

    if dpkg --compare-versions "$local_version" "lt" "${remote_version#v}"; then
      should_install="true"
    else
      print_success_muted "Ripgrep already installed and up-to-date. Skipping."
    fi
  else
    # not yet installed
    should_install="true"
  fi

  if [[ $should_install == "true" ]]; then
    download_install_dpkg "$installer_url" "Install ripgrep $remote_version"
  fi  
}


main() {
  step "ripgrep"
  install_ripgrep
}

main
