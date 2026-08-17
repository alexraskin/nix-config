{
  config,
  lib,
  primaryUser,
  ...
}:
{
  imports = [
    ./packages.nix
    ./dotfiles.nix
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
      sessionVariables = {
        # shared environment variables
      };

      file.".hushlogin".text = "";
    };
  };
}
