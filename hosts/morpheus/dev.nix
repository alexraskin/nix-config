{
  lib,
  pkgs,
  primaryUser,
  ...
}:
{
  # serial ports (/dev/ttyUSB*) for flashing ESP32 boards over USB
  users.users.${primaryUser}.extraGroups = [ "dialout" ];

  home-manager.users.${primaryUser} = {
    # headless login: aws sso login --use-device-code
    imports = [
      ../../home/apps/aws/aws.nix
      ../../home/apps/claude/claude.nix
      ../../home/apps/codex/codex.nix
      ../../home/apps/kiro/kiro.nix
      ../../home/apps/gnupg/gnupg.nix
    ];

    programs.git.settings = {
      gpg.format = "ssh";
      user.signingkey = lib.mkForce "~/.ssh/id_ed25519.pub";
      commit.gpgsign = lib.mkForce true;
      tag.gpgsign = true;
    };

    # Tailscale SSH sessions skip pam_systemd, so XDG_RUNTIME_DIR is unset and
    # clients like gpg can't find the agent socket under /run/user/$UID.
    programs.zsh.envExtra = ''
      export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$UID}"
    '';

    # no desktop app here, so op can't use app integration; sign in with
    # `op account add` once, then `eval $(op signin)` per shell
    home.packages = [ pkgs._1password-cli ];

    programs.gh = {
      enable = true;
      settings.git_protocol = "ssh";
    };

    programs.mise.globalConfig = {
      # mise otherwise builds these from source here, and there's no compiler;
      # use the prebuilt releases instead
      settings.node.compile = false;
      settings.python.compile = false;

      tools.helm = "3";
    };
  };
}
