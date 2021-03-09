#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
  && source "../utils.sh" \
  && source "utils.sh"

install_fd() {
  declare remote_version=""
  remote_version=$(get_github_version_latest sharkdp/fd)
  # remove 'v' from filename (ex v0.17.1 => 0.17.1)
  declare -r filename=fd_${remote_version#v}_amd64.deb
  declare -r installer_url="https://github.com/sharkdp/fd/releases/download/$remote_version/$filename"

  declare should_install="false"

  if cmd_exists fd; then
    # installed, check version
    declare local_version=""
    local_version=$(get_installed_package_version fd)

    if dpkg --compare-versions "$local_version" "lt" "${remote_version#v}"; then
      should_install="true"
    else
      print_success_muted "fd already installed and up-to-date. Skipping."
    fi
  else
    # not yet installed
    should_install="true"
  fi

  if [[ $should_install == "true" ]]; then
    download_install_dpkg "$installer_url" "Install fd $remote_version"
  fi  
}


main() {
  step "fd"
  install_fd
}

main
