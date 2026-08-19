{
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;

  toml = pkgs.formats.toml { };

  workspaceNames = [
    "1"
    "2"
    "3"
    "4"
    "5"
    "6"
    "7"
    "B"
    "C"
    "E"
    "M"
    "N"
    "T"
  ];

  ws = lib.listToAttrs (lib.imap0 (i: n: lib.nameValuePair n i) workspaceNames);

  switchKeys = lib.listToAttrs (
    lib.imap0 (i: n: lib.nameValuePair "Alt + ${n}" { switch_to_workspace = i; }) workspaceNames
  );

  moveKeys = lib.listToAttrs (
    lib.imap0 (i: n: lib.nameValuePair "comb1 + ${n}" { move_window_to_workspace = i; }) workspaceNames
  );

  config = {
    settings = {
      animate = true;
      animation_duration = 0.1;
      animation_fps = 60.0;
      animation_easing = "ease_out_quad";

      default_disable = false;

      focus_follows_mouse = false;
      mouse_follows_focus = true;
      mouse_hides_on_focus = false;

      auto_focus_blacklist = [ "com.apple.Spotlight" ];

      run_on_start = [ ];
      hot_reload = true;

      layout = {
        mode = "traditional";
        window_insertion_point = "next_to_selection";

        traditional.equalize_nodes = true;

        stack = {
          stack_offset = 30.0;
          default_orientation = "perpendicular";
        };

        gaps = {
          outer = {
            top = 0;
            left = 0;
            bottom = 0;
            right = 0;
          };
          inner = {
            horizontal = 0;
            vertical = 0;
          };
        };
      };

      ui.menu_bar = {
        enabled = true;
        show_empty = false;
        mode = "active";
        active_label = "name";
        display_style = "label";
      };
    };

    virtual_workspaces = {
      enabled = true;
      default_workspace_count = builtins.length workspaceNames;
      auto_assign_windows = true;
      preserve_focus_per_workspace = true;
      workspace_auto_back_and_forth = false;
      prevent_wrapping = false;
      reapply_app_rules_on_title_change = false;
      default_workspace = 0;
      workspace_names = workspaceNames;
      workspace_rules = [ ];

      # aerospace's on-window-detected
      app_rules = [
        {
          app_id = "com.google.Chrome";
          workspace = ws.B;
        }
        {
          app_id = "dev.zed.Zed";
          workspace = ws."1";
        }
        {
          app_id = "org.alacritty";
          workspace = ws.T;
        }
        {
          app_id = "com.mitchellh.ghostty";
          workspace = ws.T;
        }
        {
          app_id = "com.apple.mail";
          workspace = ws."4";
        }
        {
          app_id = "com.apple.finder";
          workspace = ws.E;
        }
        {
          app_id = "com.apple.iCal";
          workspace = ws.N;
        }
        {
          app_id = "net.whatsapp.WhatsApp";
          workspace = ws."2";
        }
        {
          app_id = "com.spotify.client";
          workspace = ws.M;
        }
      ];
    };

    modifier_combinations.comb1 = "Alt + Shift";

    keys = switchKeys // moveKeys // {
      "Alt + Z" = "toggle_space_activated";
      "comb1 + R" = "reload_config";

      "Alt + H" = { move_focus = "left"; };
      "Alt + J" = { move_focus = "down"; };
      "Alt + K" = { move_focus = "up"; };
      "Alt + L" = { move_focus = "right"; };

      "comb1 + H" = { move_node = "left"; };
      "comb1 + J" = { move_node = "down"; };
      "comb1 + K" = { move_node = "up"; };
      "comb1 + L" = { move_node = "right"; };

      "Alt + Ctrl + H" = { join_window = "left"; };
      "Alt + Ctrl + J" = { join_window = "down"; };
      "Alt + Ctrl + K" = { join_window = "up"; };
      "Alt + Ctrl + L" = { join_window = "right"; };
      "Alt + Ctrl + E" = "unjoin_windows";

      "Alt + Slash" = "toggle_orientation";
      "Alt + Comma" = "toggle_stack";

      "Alt + Minus" = { resize_window_shrink = "smart"; };
      "Alt + Equal" = { resize_window_grow = "smart"; };

      "comb1 + F" = "toggle_fullscreen";
      "comb1 + Space" = "toggle_window_floating";

      "Alt + Tab" = "switch_to_last_workspace";

      "Alt + Ctrl + Left" = { move_window_to_display = { selector = "left"; }; };
      "Alt + Ctrl + Right" = { move_window_to_display = { selector = "right"; }; };
      "Alt + Ctrl + Up" = { move_window_to_display = { selector = "up"; }; };
      "Alt + Ctrl + Down" = { move_window_to_display = { selector = "down"; }; };
    };
  };
in
{
  xdg.configFile."rift/config.toml" = lib.mkIf isDarwin {
    source = toml.generate "rift-config.toml" config;
  };
}
