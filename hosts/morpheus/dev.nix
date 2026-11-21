{ lib, primaryUser, ... }:
{
  # morpheus is the dev server: toolchains come from mise (global ones here,
  # the rest from each project's mise.toml); nix-ld runs its prebuilt binaries
  home-manager.users.${primaryUser} = {
    # same AWS SSO setup as the MacBook; headless login: aws sso login --use-device-code
    imports = [
      ../../home/apps/aws/aws.nix
      # same claude-code setup as the MacBook; skills live in ~/.claude/skills
      ../../home/apps/claude/claude.nix
    ];

    # gh comes from homebrew on the Mac; git itself is shared via home/apps/git
    # sign with the passphrase-less alex@morpheus key (no 1Password agent here);
    # home/headless.nix turns signing off for the other servers
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
