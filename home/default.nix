{
  config,
  lib,
  pkgs,
  primaryUser,
  ...
}:
{
  imports = [
    ./packages.nix
    ./scripts.nix
    ./dotfiles.nix
    ./wallpaper.nix
    ./apps
  ];

  options.local.configDir = lib.mkOption {
    type = lib.types.str;
    default = "${config.home.homeDirectory}/nix-config";
    description = ''
      Working-tree checkout of this repo. The out-of-store symlinks in
      dotfiles.nix and the rebuild aliases in apps/zsh point here, so it has
      to match wherever the repo was actually cloned.
    '';
  };

  config = {
    home = {
      username = primaryUser;
      stateVersion = "25.05";

      # macOS-only GUI apps; home-manager symlinks the .app bundles into
      # ~/Applications/Home Manager Apps. packages.nix is shared with the
      # headless NixOS hosts, so these can't live there.
      packages = with pkgs; [
        plezy
      ];
      sessionVariables = {
        # shared environment variables
      };

      file = {
        ".hushlogin".text = "";

        # hosts/mba/dock.nix pins this path, same as Visual Studio Code.
        # linkApps only gives us ~/Applications/Home Manager Apps/Plezy.app.
        "Applications/Plezy.app".source = "${pkgs.plezy}/Applications/Plezy.app";
      };
    };

    home.activation.registerDarwinApps = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      lsregister=/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister
      if [ -x "$lsregister" ]; then
        run "$lsregister" -f "$HOME/Applications/Plezy.app"
      fi
    '';
  };
}
