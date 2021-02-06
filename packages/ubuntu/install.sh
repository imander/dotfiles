#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(dirname $0)
GREEN='\033[0;32m'
NC='\033[0m' # No Color

function log() {
  msg=${1:-}
  printf "$(date -u) ${GREEN}INFO${NC} $msg\n"
}

function install() {
  pkg=${1:-}
  if [[ -n "$pkg" ]]; then
    apt -qq list "$pkg" 2>/dev/null | grep -q 'installed' || (
      log "installing $pkg"
      sudo apt-get install -y "$pkg"
    )
  fi
}

function install_golang() {
  GO_VERSION='1.15.8'
  log "installing golang $GO_VERSION"
  wget https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz
  sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
  rm -f "go${GO_VERSION}.linux-amd64.tar.gz"
}

function install_node() {
  log "installing nodejs"
  curl -sL install-node.now.sh/lts | bash
}

sudo add-apt-repository ppa:jonathonf/vim
sudo apt-get update
# ensure latest vim
sudo apt install vim

while read package; do
  install "$package"
done <"${SCRIPT_DIR}/packages"

which go || install_golang
which node || install_golang

exit 0
