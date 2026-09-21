{
  description = "alexraskin's system configuration — macOS (nix-darwin) and NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # declarative homebrew management
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    codex-cli-nix.url = "github:sadjow/codex-cli-nix";
    codex-cli-nix.inputs.nixpkgs.follows = "nixpkgs";

    pi.url = "github:lukasl-dev/pi.nix";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      inherit (import ./lib { inherit inputs self; }) mkDarwin mkNixos;

      forAllSystems =
        f:
        nixpkgs.lib.genAttrs [
          "aarch64-darwin"
          "x86_64-darwin"
          "aarch64-linux"
          "x86_64-linux"
        ] (system: f nixpkgs.legacyPackages.${system});
    in
    {
      darwinConfigurations = {
        mba = mkDarwin "mba" {
          system = "aarch64-darwin";
          user = "alex";
          hostname = "alexs-mba";
        };
      };

      # Same shape for Linux boxes, e.g.
      #   nixos = mkNixos "nixos" {
      #     system = "x86_64-linux";
      #     user = "alex";
      #     hostname = "nixos";
      #   };
      # which expects hosts/nixos/{default.nix,hardware-configuration.nix}.
      nixosConfigurations = { };

      formatter = forAllSystems (pkgs: pkgs.nixfmt);
    };
}
