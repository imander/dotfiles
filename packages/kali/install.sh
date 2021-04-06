#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(dirname $0)
GREEN='\033[0;32m'
NC='\033[0m' # No Color
SUDO='sudo'

if [ $(id -u) -eq 0 ]; then
  SUDO=''
fi

function log() {
  msg=${1:-}
  printf "$(date -u) ${GREEN}INFO${NC} $msg\n"
}

function install() {
  pkg=${1:-}
  if [[ -n "$pkg" ]]; then
    apt -qq list "$pkg" 2>/dev/null | grep -q 'installed' || (
      log "installing $pkg"
      $SUDO apt-get install -y "$pkg"
    )
  fi
}

function install_golang() {
  GO_VERSION='1.16.3'
  log "installing golang $GO_VERSION"
  wget https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz
  $SUDO tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
  rm -f "go${GO_VERSION}.linux-amd64.tar.gz"
}

function install_node() {
  log "installing nodejs"
  curl -sL install-node.now.sh/lts | $SUDO bash -s -- --yes
}

function install_fzf() {
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --all
}

$SUDO apt-get update

while read package; do
  install "$package"
done <"${SCRIPT_DIR}/packages"

which go || install_golang
which node || install_node
which fzf || install_fzf

exit 0
