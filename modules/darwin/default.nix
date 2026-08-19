{ ... }:
{
  imports = [
    ./system.nix
    ./macos
    ./homebrew.nix
    ./nix-gc.nix
    ./home-manager.nix
  ];
}
