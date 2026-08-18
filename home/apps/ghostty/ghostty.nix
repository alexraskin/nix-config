{ lib, pkgs, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in
{
  programs.zsh.initContent = lib.mkOrder 450 ''
    if [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
      source "$GHOSTTY_RESOURCES_DIR"/shell-integration/zsh/ghostty-integration
    fi
  '';

  programs.ghostty = {
    enable = true;

    package = lib.mkIf isDarwin null;

    enableZshIntegration = false;

    settings = {
      theme = "Catppuccin Mocha";
      background-opacity = 0.92;
      cursor-color = "#e6e6e6";
      cursor-text = "#1e1f29";
      cursor-style-blink = true;
      split-divider-color = "203040";

      font-family = "Iosevka";
      font-size = 16;
      font-feature = "-calt";

      scrollback-limit = 100000000;
      shell-integration-features = "no-cursor,ssh-env,ssh-terminfo";
      clipboard-paste-protection = false;

      keybind = [ "shift+enter=text:\\n" ];

      window-width = 120;
      window-height = 33;
      window-padding-x = 8;
      window-padding-y = 8;
      window-padding-color = "extend";
      window-padding-balance = true;
    }
    // lib.optionalAttrs isDarwin {
      font-thicken = true;
      background-blur = 20;
      macos-option-as-alt = true;
      macos-non-native-fullscreen = "padded-notch";
      macos-titlebar-style = "tabs";
      macos-icon = "custom-style";
      macos-icon-frame = "aluminum";
      macos-icon-ghost-color = "#52fc85";
      macos-icon-screen-color = "#0f2213";
    };
  };
}
