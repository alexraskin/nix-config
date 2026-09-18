{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;

    mutableExtensionsDir = false;
    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;
  };

  home.file."Applications/VSCodium.app".source = "${pkgs.vscodium}/Applications/VSCodium.app";
}
