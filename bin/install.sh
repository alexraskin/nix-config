#!/usr/bin/env bash
# Bootstrap a fresh Mac. Everything except git, nix, and this repo is declared
# in the flake — packages, Homebrew itself, casks, macOS defaults, dotfiles.
#
#   ./install.sh [host]   host defaults to "mba"; it must match an attribute
#                         of darwinConfigurations in flake.nix.
set -euo pipefail

REPO="git@github.com:alexraskin/nix-config.git"
DIR="$HOME/nix-config"
HOST="${1:-mba}"
FLAKE="path:$DIR#$HOST"
NIX="/nix/var/nix/profiles/default/bin/nix"

step() { echo "==> $*"; }

if [[ "$(uname)" != "Darwin" ]]; then
  echo "This script is macOS only. On NixOS, install from the ISO and then" >&2
  echo "run: sudo nixos-rebuild switch --flake $DIR#$HOST" >&2
  exit 1
fi

# Xcode Command Line Tools — prereq for git and nix.
if ! xcode-select -p &>/dev/null; then
  step "Installing Xcode Command Line Tools"
  xcode-select --install
  echo "    Re-run this script once the installation completes."
  exit 0
fi

if [[ ! -e "$NIX" ]]; then
  step "Installing Nix"
  installer="$(mktemp)"
  curl --proto '=https' --tlsv1.2 -fsSL https://nixos.org/nix/install -o "$installer"
  sh "$installer" --daemon
  rm -f "$installer"
fi
# shellcheck disable=SC1091
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

if [[ ! -d "$DIR" ]]; then
  step "Cloning nix-config"
  git clone "$REPO" "$DIR"
fi

step "Activating nix-darwin for host '$HOST'"
sudo "$NIX" --extra-experimental-features 'nix-command flakes' \
  run nix-darwin/master#darwin-rebuild -- switch --flake "$FLAKE"

echo "Done! Open a new terminal session to load your shell config."
