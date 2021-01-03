#!/usr/bin/env bash

# modified from ~/.macos — https://mths.be/macos and Kent C. Dodds' script (https://github.com/kentcdodds/dotfiles/blob/master/.macos)
# Run without downloading:
# curl https://raw.githubusercontent.com/josephst/dotfiles/master/ubuntu/.ubuntu | bash


# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.ubuntu` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

###############################################################################
# Joseph's Customizations                                                     #
###############################################################################

echo "Hello $(whoami)! Let's get you set up."

echo "mkdir -p ${HOME}/code"
mkdir -p "${HOME}/code"

echo "fetching updated package lists"
sudo apt update

echo "installing shell"
sudo apt-get install -y zsh
# chsh -s $(which zsh) # doesn't seem to work in script

# echo "installing homebrew"
# # install homebrew https://brew.sh
# /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# echo "brew installing stuff"
# # hub: a github-specific version of git
# # libdvdcss: makes handbreak capable of ripping DVDs
# # ripgrep: rg is faster than alternatives
# # imagemagick: eventually I will need this for something
# # ffmpeg: eventually I'll need this for something
# # tree: really handy for listing out directories in text
# # bat: A cat(1) clone with syntax highlighting and Git integration.
# # switchaudio-osx: allows me to switch the audio device via the command line
# brew install git hub libdvdcss ripgrep imagemagick watchman tree bat \
# delta switchaudio-osx

# echo "installing node (via n-install)"
# curl -L https://git.io/n-install | bash

echo "install development libraries and tools"
sudo apt-get install -y autoconf bison build-essential libssl-dev libyaml-dev \
libreadline-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev \
libsqlite3-dev

echo "installing node (via Nodesource)"
curl -sL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

echo "node --version: $(node --version)"
echo "npm --version: $(npm --version)"

echo "installing a few global npm packages"
npm install --global serve prettier npm-check-updates
# npm install --global fkill-cli npm-quick-run semantic-release-cli npm-check-updates

echo "installing rb-env to manage ruby"
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer | bash
# update available ruby versions
pushd "${HOME}/.rbenv/plugins/ruby-build"
git pull
popd

echo "install ruby 2.7.2"
source ~/.zshrc # re-load zshrc to enable rbenv
rbenv install 2.7.2
rbenv global 2.7.2
ruby --version


echo "installing other common apps"
sudo apt-get install -y httpie bat jq

# echo "installing apps with brew cask"
# brew cask install alfred google-chrome firefox brave-browser bettertouchtool divvy \
# bartender google-drive-file-stream itsycal visual-studio-code 1password dash \
# screenflow marshallofsound-google-play-music-player skype workflowy \
# sublime-text vlc discord obs handbrake zoomus betterzip avibrazil-rdm sip \
# qlcolorcode qlmarkdown qlstephen quicklook-json webpquicklook \
# suspicious-package qlvideo spotify focus dropbox front qmoji slack

if ! test -f ~/.ssh/id_rsa; then
  echo "Generating an RSA token for GitHub"
  mkdir -p ~/.ssh
  touch ~/.ssh/config
  ssh-keygen -t rsa -b 4096 -C "hello@josephstahl.com" -f ~/.ssh/id_rsa
  echo "Host *\n AddKeysToAgent yes\n IdentityFile ~/.ssh/id_rsa" | tee ~/.ssh/config
  chmod 600 ~/.ssh/config
  eval "$(ssh-agent -s)"
  echo "run 'cat ~/.ssh/id_rsa.pub | clip.exe' and paste that into GitHub"
else
echo "RSA token already created"
fi

if ! test -d "${HOME}/.zprezto"; then
  echo "get Prezto set up for zsh"
  zsh -c "git clone --recursive https://github.com/josephst/prezto.git \"${ZDOTDIR:-$HOME}/.zprezto\""
  zsh -c "setopt EXTENDED_GLOB && for rcfile in \"${ZDOTDIR:-$HOME}\"/.zprezto/runcoms/^README.md(.N); do
  echo \"linking \$rcfile to \"${ZDOTDIR:-$HOME}/.\${rcfile:t}\"\";
  ln -s \"\$rcfile\" \"${ZDOTDIR:-$HOME}/.\${rcfile:t}\"
  done"
  # switch to ssh instead of https after cloning (can't clone with ssh initially since ssh key not yet added to github"
  pushd "${HOME}/.zprezto"
  git remote set-url origin git@github.com:josephst/prezto.git
  git remote add upstream https://github.com/sorin-ionescu/prezto.git
  popd
  echo "installing starship (theme for zsh)"
  curl -fsSL https://starship.rs/install.sh | sudo bash
else
  echo "prezto already set up"
fi

if ! test -d "${HOME}/dotfiles"; then
  echo "cloning dotfiles"
  git clone https://github.com/josephst/dotfiles.git "${HOME}/dotfiles"
  # ln -s "${HOME}/dotfiles/.zshrc" "${HOME}/.zshrc"
  # ln -s "${HOME}/dotfiles/.gitignore_global" "${HOME}/.gitignore_global"
  ln -s "${HOME}/dotfiles/ubuntu/gitconfig" "${HOME}/.gitconfig"
  ln -s "${HOME}/dotfiles/ubuntu/gemrc" "${HOME}/.gemrc"
  if ! test -d ~/.config; then
    mkdir -p ~/.config
  fi
  ln -s "${HOME}/dotfiles/ubuntu/config/starship.toml" "${HOME}/.config/starship.toml"
  # ln -s "${HOME}/dotfiles/.my_bin" "${HOME}/.my_bin"
  # ln -s "${HOME}/dotfiles/.vimrc" "${HOME}/.vimrc"
  # ln -s "${HOME}/dotfiles/.vimrc-parts" "${HOME}/.vimrc-parts"
  pushd "${HOME}/dotfiles"
  git remote set-url origin git@github.com:josephst/dotfiles.git
  popd
else
  echo "dotfiles already set up"
fi

# get bat and delta all configured
# mkdir -p "${HOME}/.config/bat/themes"
# ln -s "${HOME}/dotfiles/.config/bat/config" "${HOME}/.config/bat/config"
# git clone https://github.com/batpigandme/night-owlish "${HOME}/.config/bat/themes/night-owlish"
# bat cache --build