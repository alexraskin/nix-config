{ ... }:
{
  imports = [
    ./system.nix
    ./macos
    ./homebrew.nix
    ./nix-gc.nix
    ./aerospace.nix
    ./home-manager.nix
  ];
}
