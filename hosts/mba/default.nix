{ ... }:
{
  imports = [
    ./dock.nix
  ];

  # Homebrew lists merge with modules/darwin/homebrew.nix, so per-machine
  # extras are just:
  #   homebrew.casks = [ "davinci-resolve" ];
}
