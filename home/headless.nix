{
  config,
  lib,
  pkgs,
  primaryUser,
  currentSystemName,
  ...
}:
{
  imports = [
    ./packages.nix
    ./dotfiles.nix
    ./apps/git/git.nix
    ./apps/zsh/zsh.nix
    ./apps/mise/mise.nix
  ];

  options.local.configDir = lib.mkOption {
    type = lib.types.str;
    default = "${config.home.homeDirectory}/nix-config";
  };

  config = {
    home = {
      username = primaryUser;
      stateVersion = "25.05";
      packages = with pkgs; [
        nixd
        nixfmt
      ];
    };

    programs.git.settings.commit.gpgsign = false;

    home.activation.generateSshKey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
        run mkdir -p "$HOME/.ssh"
        run chmod 700 "$HOME/.ssh"
        run ${pkgs.openssh}/bin/ssh-keygen -q -t ed25519 -N "" \
          -C "${currentSystemName}" -f "$HOME/.ssh/id_ed25519"
      fi
    '';
  };
}
