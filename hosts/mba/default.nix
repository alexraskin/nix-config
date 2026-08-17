{ ... }:
{
  # MacBook Air (aarch64-darwin). Everything shared with other Macs lives in
  # modules/darwin/ — this file is only for what is true of this machine.
  imports = [
    ./dock.nix
  ];

  # Homebrew lists merge with modules/darwin/homebrew.nix, so per-machine
  # extras are just:
  #   homebrew.casks = [ "davinci-resolve" ];
}
