{ lib, primaryUser, ... }:
{
  # serial ports (/dev/ttyUSB*) for flashing ESP32 boards over USB
  users.users.${primaryUser}.extraGroups = [ "dialout" ];

  home-manager.users.${primaryUser} = {
    # headless login: aws sso login --use-device-code
    imports = [
      ../../home/apps/aws/aws.nix
      ../../home/apps/claude/claude.nix
      ../../home/apps/kiro/kiro.nix
    ];

    programs.git.settings = {
      gpg.format = "ssh";
      user.signingkey = lib.mkForce "~/.ssh/id_ed25519.pub";
      commit.gpgsign = lib.mkForce true;
      tag.gpgsign = true;
    };

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
