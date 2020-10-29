#!/bin/bash

SCRIPT_DIR=$(dirname $0)

function install() {
  pacman -Qi "$1" >/dev/null || sudo pacman --noconfirm -S "$1"
}

function install_aur() {
  pacman -Qi "$1" >/dev/null || yay -S \
    --answerclean N \
    --answerdiff N \
    --answeredit N \
    --answerupgrade N \
    --noconfirm \
    --noprovides "$1"
}

function install_yay() {
  pushd /tmp
  git clone https://aur.archlinux.org/yay-git.git
  pushd yay-git
  makepkg -si --noconfirm
  popd
  rm -rf yay-git
  popd
}

while read package; do
  install "$package"
done <"${SCRIPT_DIR}/package_os"

pacman -Qi yay >/dev/null || install_yay

while read package; do
  install_aur "$package"
done <"${SCRIPT_DIR}/package_aur"
