#!/usr/bin/env bash
set -Eeuo pipefail

echo '=== update system and install prerequisites ==='
sudo pacman -Syu --needed bitwarden git yadm openssh

echo
echo '=== verify installed packages ==='
pacman -Q bitwarden git yadm openssh

echo
echo '=== verify commands ==='
command -v git
command -v yadm
command -v ssh
