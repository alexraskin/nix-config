{
  description = "alexraskin's system configuration — macOS (nix-darwin) and NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    codex-cli-nix.url = "github:sadjow/codex-cli-nix";
    codex-cli-nix.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    figurine-shell.url = "github:alexraskin/figurine-shell";
    figurine-shell.inputs.nixpkgs.follows = "nixpkgs";

    rex.url = "https://pkgs.superlogical.com/rex/nix/snapshot.tar.gz";
    rex.inputs.nixpkgs.follows = "nixpkgs";
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
        kappa = mkDarwin "kappa" {
          system = "aarch64-darwin";
          user = "alex";
          hostname = "kappa";
        };
      };

      nixosConfigurations = {
        hhbox = mkNixos "hhbox" {
          system = "x86_64-linux";
          user = "alex";
          hostname = "hhbox";
        };

        morpheus = mkNixos "morpheus" {
          system = "x86_64-linux";
          user = "alex";
          hostname = "morpheus";
        };
      };

      formatter = forAllSystems (pkgs: pkgs.nixfmt);
    };
}
