{ pkgs, ... }:
let
  # Not in nixpkgs yet (nixpkgs still carries the old sswg.swift-lang), so pull
  # the VSIX straight from the marketplace.
  swift-vscode = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      name = "swift-vscode";
      publisher = "swiftlang";
      version = "2.16.7";
      sha256 = "1krzmz2s2l4bwpvp4msjf6pwqfha11a21bpwq942lhx3zbgvh0d6";
    }
  ];
in
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    mutableExtensionsDir = false;
    profiles.default = {
      enableUpdateCheck = true;
      enableExtensionUpdateCheck = false;

      extensions =
        (with pkgs.vscode-extensions; [
          bbenoist.nix
          catppuccin.catppuccin-vsc
          llvm-vs-code-extensions.lldb-dap
          ms-azuretools.vscode-containers
          ms-azuretools.vscode-docker
        ])
        ++ swift-vscode;

      userSettings = {
        "workbench.colorTheme" = "Catppuccin Macchiato";

        "chat.disableAIFeatures" = true;
        "chat.commandCenter.enabled" = false;
        "editor.inlineSuggest.enabled" = false;
        "github.copilot.enable"."*" = false;
        "github.copilot.nextEditSuggestions.enabled" = false;
      };
    };
  };

  home.file."Applications/Visual Studio Code.app".source =
    "${pkgs.vscode}/Applications/Visual Studio Code.app";
}
