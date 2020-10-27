#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

GREEN='\033[0;32m'
NC='\033[0m' # No Color

function log() {
  msg=${1:-}
  printf "$(date -u) ${GREEN}INFO${NC} $msg\n"
}

function install_homebrew() {
  which brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
}

function install_brew() {
  log "Installing $brew"
  brew info "$brew" >/dev/null 2>&1 || brew install "$brew"
}

function install_cask() {
  log "Installing cask $cask"
  brew info "$cask" >/dev/null 2>&1 || brew cask install "$cask"
}

while read brew; do
  install_brew
done <brews

while read cask; do
  install_cask
done <casks

exit 0
