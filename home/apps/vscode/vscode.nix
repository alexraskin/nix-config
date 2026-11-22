{ pkgs, ... }:
let
  marketplaceExtensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      name = "swift-vscode";
      publisher = "swiftlang";
      version = "2.16.7";
      sha256 = "1krzmz2s2l4bwpvp4msjf6pwqfha11a21bpwq942lhx3zbgvh0d6";
    }
    {
      name = "kiro-for-vscode";
      publisher = "kiro";
      version = "1.5.0";
      arch = "darwin-arm64";
      sha256 = "1ahj2akb2my8i8aavk0b302fss4ik0q0y7k7w96g5ippc1qbyjg6";
    }
  ];
in
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    mutableExtensionsDir = true;
    profiles.default = {
      enableUpdateCheck = true;
      enableExtensionUpdateCheck = true;

      extensions =
        (with pkgs.vscode-extensions; [
          astro-build.astro-vscode
          bbenoist.nix
          catppuccin.catppuccin-vsc
          catppuccin.catppuccin-vsc-icons
          hashicorp.terraform
          llvm-vs-code-extensions.lldb-dap
          ms-azuretools.vscode-containers
          ms-azuretools.vscode-docker
          ms-python.python
          golang.go
          redhat.vscode-yaml
          ms-kubernetes-tools.vscode-kubernetes-tools
          anthropic.claude-code
          ms-vscode-remote.remote-ssh
          ms-vscode.cpptools-extension-pack
          tamasfe.even-better-toml
          ms-vscode.cmake-tools
          ms-vscode-remote.remote-containers
        ])
        ++ marketplaceExtensions;

      userSettings = {
        "extensions.autoUpdate" = "on";
        "workbench.colorTheme" = "Catppuccin Mocha";
        "chat.disableAIFeatures" = true;
        "chat.commandCenter.enabled" = false;
        "editor.inlineSuggest.enabled" = false;
        "github.copilot.enable"."*" = false;
        "github.copilot.nextEditSuggestions.enabled" = false;
        "git.autofetch" = true;
        "explorer.confirmDelete" = false;
        "git.confirmSync" = false;
        "explorer.confirmPasteNative" = false;
        "redhat.telemetry.enabled" = false;
        "workbench.startupEditor" = "none";
        "explorer.confirmDragAndDrop" = false;
        "files.autoSave" = "onFocusChange";
        "go.toolsManagement.autoUpdate" = true;
        "vs-kubernetes"."vs-kubernetes.crd-code-completion" = "enabled";
        "yaml.disableSchemaDetection" = [
          "**/docker-compose.yml"
          "**/docker-compose.yaml"
          "**/docker-compose.*.yml"
          "**/docker-compose.*.yaml"
          "**/compose.yml"
          "**/compose.yaml"
          "**/compose.*.yml"
          "**/compose.*.yaml"
          "**/.github/workflows/*.yml"
          "**/.github/workflows/*.yaml"
          "**/.gitea/workflows/*.yml"
          "**/.gitea/workflows/*.yaml"
          "**/.forgejo/workflows/*.yml"
          "**/.forgejo/workflows/*.yaml"
        ];
      };
    };
  };

  home.file."Applications/Visual Studio Code.app".source =
    "${pkgs.vscode}/Applications/Visual Studio Code.app";
}
