#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

GREEN='\033[0;32m'
NC='\033[0m' # No Color

SCRIPT_DIR=$(dirname $0)

function log() {
  msg=${1:-}
  printf "$(date -u) ${GREEN}INFO${NC} $msg\n"
}

function install_homebrew() {
  which brew >/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
}

function install_brew() {
  log "Installing $brew"
  brew install "$brew"
}

function install_cask() {
  log "Installing cask $cask"
  brew cask install "$cask"
}

install_homebrew

log "Installing missing packges"
brew list --formula >installed_brews
trap "rm -f installed_brew*" EXIT

while read brew; do
  install_brew
done < <(grep -vf installed_brews "${SCRIPT_DIR}/brews")

brew list --casks >installed_brew_casks
while read cask; do
  install_cask
done < <(grep -vf installed_brew_casks "${SCRIPT_DIR}/casks")

exit 0
