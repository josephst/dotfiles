script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

source "$script_dir/text_format.sh" &&
  source "$script_dir/utils.sh"

###############################################################################
# SSH and Github
###############################################################################

copy_key_github() {
  # adapted for WSL2
  inform 'Public key copied! Paste into Github…'
  local os=""
  os="$(get_os)"

  if [[ "$os" == "macOS" ]]; then
    [[ -f $pub ]] && cat $pub | pbcopy
    open 'https://github.com/settings/keys'
  elif [[ "$os" == ubuntu ]] && check_wsl; then
    # in WSL; Windows apps are available
    [[ -f $pub ]] && < "$pub" /mnt/c/Windows/System32/clip.exe
    "/mnt/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe" "https://github.com/settings/keys"
  else
    # unsure of OS
    print_warning "Unsure of OS; please enter key into Github manually."
  fi

  read -r -p "   ✦  Press enter to continue…"
  print_success "SSH key"
  return
}

github_key_check() {
  if ask "SSH key found. Enter it in Github?" Y; then
    copy_key_github;
  else
    print_success "SSH key";
  fi
}

create_ssh_key() {
  if ask "No SSH key found. Create one?" Y; then
    ssh-keygen -t ed25519; github_key_check;
  else
    return 0;
  fi
}

ssh_key_setup() {
  local pub=$HOME/.ssh/id_ed25519.pub
  
  if ! [[ -f $pub ]]; then
    create_ssh_key
  else
    github_key_check
  fi
}