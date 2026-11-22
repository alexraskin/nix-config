{ lib, pkgs, ... }:
{
  home.packages = [ pkgs.kiro-cli ];

  # kiro-cli execs its helpers from ~/.local/bin (where the upstream installer
  # puts them), not from PATH, so point them at the nix package
  home.file = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    ".local/bin/kiro-cli-chat".source = "${pkgs.kiro-cli}/bin/kiro-cli-chat";
    ".local/bin/kiro-cli-term".source = "${pkgs.kiro-cli}/bin/kiro-cli-term";
  };
}
