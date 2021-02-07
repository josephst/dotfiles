#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
  && source "../utils.sh" \
  && source "utils.sh"

declare -r ASDF_DIRECTORY="$HOME/.asdf"
declare -r ASDF_REPO_URL="https://github.com/asdf-vm/asdf.git"
declare -r LOCAL_BASH_CONFIG_FILE="$HOME/.bash.local"


add_bash_config() {
  declare -r CONFIGS="
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# asdf
export ASDF_DIR=\"$ASDF_DIRECTORY\"
[ -f \"\$ASDF_DIR/asdf.sh\" ] \\
    && . \"\$ASDF_DIR/asdf.sh\"
[ -f \"\$ASDF_DIR/completions/asdf.bash\" ] \\
    && . \"\$ASDF_DIR/completions/asdf.bash\"
"
  execute \
    "printf '%s' '$CONFIGS' >> $LOCAL_BASH_CONFIG_FILE" \
    "asdf (update $LOCAL_BASH_CONFIG_FILE)"
  source "$ASDF_DIRECTORY/asdf.sh"
}


install_asdf() {
  # don't need to add to zshrc; oh-my-zsh takes care of this
  # add to bashrc
  execute "git clone --quiet $ASDF_REPO_URL $ASDF_DIRECTORY \
  && pushd $ASDF_DIRECTORY \
  && git checkout \$(git describe --abbrev=0 --tags) \
  && popd" "install asdf"
  add_bash_config
}

update_asdf() {
  execute "$ASDF_DIRECTORY/bin/asdf update" "ASDF installed and updated"
  source "$ASDF_DIRECTORY/asdf.sh"
}

alias install_asdf_plugin=add_or_update_asdf_plugin
add_or_update_asdf_plugin() {
  local name="$1"
  local url="$2"

  if ! asdf plugin-list &> /dev/null | grep -Fq "$name"; then
    asdf plugin-add "$name" "$url" &> /dev/null
  else
    asdf plugin-update "$name" &> /dev/null
  fi
}

install_asdf_language() {
  local language="$1"
  # install latest specified version, or the latest stable version otherwise
  local version

  if [[ -z "$2" ]]; then
    # no version specified; go with latest available
    version=$(asdf latest "$language")
  else
    # version specified, install that version
    version=$(asdf list all "$language" "$2" | grep -v "[a-z]" | tail -1)
  fi

  if ! asdf list "$language" | grep -Fq "$version"; then
    asdf install "$language" "$version"
    asdf global "$language" "$version"
  fi
}

install_latest_stable_node() {
  execute "source $ASDF_DIRECTORY/asdf.sh \
    && bash -c '${ASDF_DATA_DIR:=$HOME/.asdf}/plugins/nodejs/bin/import-release-team-keyring' \
    && install_asdf_language \"nodejs\" \"14\"" "asdf install (node)"
}

install_latest_stable_ruby() {
  execute "source $ASDF_DIRECTORY/asdf.sh \
    && install_asdf_language \"ruby\" \"2.7\"" "asdf install (ruby)"
}



main() {
  step "asdf version manager"

  if [[ ! -d "$ASDF_DIRECTORY" ]]; then
    install_asdf
  else
    update_asdf
  fi

  # -----------------------------------------------------------------------------
  # asdf plugins (version manager)
  # -----------------------------------------------------------------------------

  add_or_update_asdf_plugin "ruby" "https://github.com/asdf-vm/asdf-ruby.git"
  add_or_update_asdf_plugin "nodejs" "https://github.com/asdf-vm/asdf-nodejs.git"

  install_latest_stable_node
  install_latest_stable_ruby
}

main