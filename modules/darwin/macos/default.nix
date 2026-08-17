{ ... }:
# macOS settings, one file per topic. Every option here is a typed nix-darwin
# option where one exists; CustomUserPreferences is the fallback for domains
# nix-darwin does not model.
#
# To find more: `defaults read <domain>` shows what a machine currently has,
# and `darwin-rebuild changelog` / the nix-darwin source under
# modules/system/defaults/ lists the typed options.
{
  imports = [
    ./appearance.nix
    ./apps.nix
    ./dock.nix
    ./finder.nix
    ./keyboard.nix
    ./login.nix
    ./security.nix
    ./software-update.nix
    ./trackpad.nix
  ];
}
