#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" && \
  source "./utils.sh"

create_directories() {
  readonly DIRECTORIES=(
    "$HOME/code"
    "$HOME/Downloads"
  )

  step "Making directories…"
  for dir in "${DIRECTORIES[@]}"; do
    mkd "$dir"
  done
}

main() {
  chapter "Creating directories"
  create_directories
}

main