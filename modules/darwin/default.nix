{ ... }:
{
  imports = [
    ./system.nix
    ./macos
    ./homebrew.nix
    ./nix-gc.nix
    ./rift.nix
    ./home-manager.nix
  ];
}
