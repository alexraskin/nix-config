{ pkgs, ... }:
{
  # PGP for email (hi@alexraskin.com); git signing stays on the 1Password SSH agent
  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    pinentry.package =
      if pkgs.stdenv.hostPlatform.isDarwin then pkgs.pinentry_mac else pkgs.pinentry-curses;
  };
}
