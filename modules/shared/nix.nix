{ self, ... }:
{
  nix = {
    enable = true;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
      # disabled due to https://github.com/NixOS/nix/issues/7273
      # auto-optimise-store = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  # Stamps the flake revision onto the built system, so `darwin-version` /
  # `nixos-version` reports the commit it came from.
  system.configurationRevision = self.rev or self.dirtyRev or null;
}
