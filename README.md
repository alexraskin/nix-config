# nix-config

[![CI](https://github.com/alexraskin/nix-config/actions/workflows/ci.yml/badge.svg)](https://github.com/alexraskin/nix-config/actions/workflows/ci.yml)

My Mac and Linux boxes, all set up from one flake: packages, apps, macOS settings, dotfiles.

![ff](https://cdn.alexraskin.com/shottr/SCR-20260818-svg.png "ff")
![ffnix](https://sadge.lol/ROaOqB.png "ffnix")

## Machines

- `mba` — MacBook Air
- `hhbox` — NixOS box running Plex and Syncthing
- `nixcosmo` — NixOS box, Tailscale exit node

## What's where

```text
flake.nix     the list of machines
lib/          helpers that build a Mac or NixOS system
modules/      stuff every Mac (darwin/) or every Linux box (nixos/) gets
hosts/        stuff only one machine gets, one folder each
home/         my user setup, shared everywhere: packages, shell, app configs
bin/          install script for a fresh Mac
```

## New Mac

```bash
curl -fsSL https://raw.githubusercontent.com/alexraskin/nix-config/main/bin/install.sh | bash
```

Installs Nix, clones this repo to `~/nix-config`, and applies it. Keep it at that path; the dotfile links point there.

## Day to day

```bash
nix-switch            # rebuild and apply
hm-switch             # just the home stuff, no sudo
nix flake update      # update everything
nix fmt -- **/*.nix   # format
```

## Adding a machine

1. Make `hosts/<name>/default.nix`. On Linux, also copy over the box's `/etc/nixos/hardware-configuration.nix` and import it.
2. Add it to `flake.nix`:

   ```nix
   <name> = mkNixos "<name>" {   # or mkDarwin
     system = "x86_64-linux";
     user = "alex";
     hostname = "<name>";
   };
   ```

   The name has to match the folder under `hosts/`.
3. `git add` the new files, since the flake can't see untracked files.

## Adding stuff

- **CLI tool:** `home/packages.nix`
- **Mac app:** `modules/darwin/homebrew.nix`, or the host's `default.nix` for just one Mac
- **App config:** `home/apps/<app>/`, then import it from `home/apps/default.nix`

## CI

Every push checks formatting and builds every machine in the flake. New machines get picked up automatically.
