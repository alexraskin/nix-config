{ primaryUser, ... }:
{
  # morpheus is the dev server: toolchains come from mise (global ones here,
  # the rest from each project's mise.toml); nix-ld runs its prebuilt binaries
  home-manager.users.${primaryUser} = {
    # same AWS SSO setup as the MacBook; headless login: aws sso login --use-device-code
    imports = [ ../../home/apps/aws/aws.nix ];

    # gh comes from homebrew on the Mac; git itself is shared via home/apps/git
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
