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
  curl -sL install-node.now.sh/lts | sudo bash -s -- --yes
}

function install_kubectl() {
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  rm -f kubectl
}

function install_gh() {
  VER=1.5.0
  curl -LO "https://github.com/cli/cli/releases/download/v1.5.0/gh_${VER}_linux_amd64.deb"
  sudo apt install "./gh_${VER}_linux_amd64.deb"
  rm -f "gh_${VER}_linux_amd64.deb"
}

sudo add-apt-repository -y ppa:jonathonf/vim
sudo apt-get update
# ensure latest vim
sudo apt install -y vim

while read package; do
  install "$package"
done <"${SCRIPT_DIR}/packages"

which go || install_golang
which node || install_node
which kubectl || install_kubectl
which gh || install_gh

exit 0
