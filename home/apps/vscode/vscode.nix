{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    mutableExtensionsDir = false;
    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;
    };
  };

  home.file."Applications/Visual Studio Code.app".source = "${pkgs.vscode}/Applications/Visual Studio Code.app";
}
