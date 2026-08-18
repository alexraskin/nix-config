{ pkgs, ... }:
let
  # Catppuccin Mocha, same palette Ghostty is themed with.
  crust = "0xff11111b";
  surface = "0xff313244";
  text = "0xffcdd6f4";
  green = "0xffa6e3a1";
  blue = "0xff89b4fa";
  peach = "0xfffab387";
  yellow = "0xfff9e2af";
  red = "0xfff38ba8";

  barHeight = 32;

  aerospace = "${pkgs.aerospace}/bin/aerospace";
  sketchybar = "${pkgs.sketchybar}/bin/sketchybar";
  iconMap = "${pkgs.sketchybar-app-font}/bin/icon_map.sh";

  # One workspace item per AeroSpace workspace; empty ones hide themselves so the
  # left side stays as sparse as a polybar workspace module.
  workspaces = [
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

  spacePlugin = pkgs.writeShellScript "sketchybar-space" ''
    sid="$1"

    if [ "$sid" = "$FOCUSED_WORKSPACE" ]; then
      ${sketchybar} --set "$NAME" drawing=on \
        background.color=${text} \
        label.color=${crust}
      exit 0
    fi

    windows=$(${aerospace} list-windows --workspace "$sid" --format '%{window-id}' 2>/dev/null | wc -l | tr -d ' ')
    if [ "''${windows:-0}" -gt 0 ]; then
      ${sketchybar} --set "$NAME" drawing=on \
        background.color=${surface} \
        label.color=${text}
    else
      ${sketchybar} --set "$NAME" drawing=off
    fi
  '';

  frontAppPlugin = pkgs.writeShellScript "sketchybar-front-app" ''
    app="$INFO"

    # On a forced update there is no event payload, so ask LaunchServices.
    if [ -z "$app" ]; then
      app=$(lsappinfo info -only name "$(lsappinfo front)" | cut -d'"' -f4)
    fi
    [ -z "$app" ] && exit 0

    ${sketchybar} --set "$NAME" label="$app" icon="$(${iconMap} "$app")"
  '';

  batteryPlugin = pkgs.writeShellScript "sketchybar-battery" ''
    info=$(pmset -g batt)
    pct=$(echo "$info" | grep -Eo '[0-9]+%' | head -1 | tr -d '%')
    [ -z "$pct" ] && exit 0

    if echo "$info" | grep -q "AC Power"; then
      icon="󰂄"
      color=${green}
    elif [ "$pct" -gt 60 ]; then
      icon="󰁹"
      color=${green}
    elif [ "$pct" -gt 30 ]; then
      icon="󰁽"
      color=${yellow}
    elif [ "$pct" -gt 15 ]; then
      icon="󰁻"
      color=${peach}
    else
      icon="󰁺"
      color=${red}
    fi

    ${sketchybar} --set "$NAME" icon="$icon" icon.color="$color" label="$pct%"
  '';

  volumePlugin = pkgs.writeShellScript "sketchybar-volume" ''
    vol="$INFO"
    if [ -z "$vol" ]; then
      vol=$(osascript -e 'output volume of (get volume settings)')
    fi
    [ -z "$vol" ] && exit 0

    if [ "$vol" -eq 0 ]; then
      icon="󰝟"
    elif [ "$vol" -lt 34 ]; then
      icon="󰕿"
    elif [ "$vol" -lt 67 ]; then
      icon="󰖀"
    else
      icon="󰕾"
    fi

    ${sketchybar} --set "$NAME" icon="$icon" label="$vol%"
  '';

  clockPlugin = pkgs.writeShellScript "sketchybar-clock" ''
    ${sketchybar} --set "$NAME" label="$(date '+%a %d %b %I:%M %p')"
  '';

  spaceItems = builtins.concatStringsSep " \\\n" (
    map (sid: ''
      --add item space.${sid} left \
      --subscribe space.${sid} aerospace_workspace_change \
      --set space.${sid} \
        icon.drawing=off \
        label="${sid}" \
        label.padding_left=8 \
        label.padding_right=8 \
        background.color=${surface} \
        click_script="${aerospace} workspace ${sid}" \
        script="${spacePlugin} ${sid}"'') workspaces
  );
in
{
  fonts.packages = [
    pkgs.nerd-fonts.symbols-only
    pkgs.sketchybar-app-font
  ];

  services.sketchybar = {
    enable = true;

    extraPackages = [
      pkgs.aerospace
      pkgs.sketchybar-app-font
    ];

    config = ''
      #!/usr/bin/env bash

      # A flat, full-width, square-cornered bar: no floating island, no rounded
      # shell, no shadow — the parts that read as "macOS" rather than polybar.
      ${sketchybar} --bar \
        height=${toString barHeight} \
        position=top \
        sticky=on \
        topmost=window \
        color=${crust} \
        corner_radius=0 \
        border_width=0 \
        y_offset=0 \
        margin=0 \
        padding_left=6 \
        padding_right=6 \
        blur_radius=0 \
        shadow=off \
        font_smoothing=on

      # Every module is a small pill: Nerd Font glyph, then a monospace label.
      ${sketchybar} --default \
        updates=when_shown \
        icon.font="Symbols Nerd Font Mono:Regular:15.0" \
        icon.color=${text} \
        icon.padding_left=8 \
        icon.padding_right=5 \
        label.font="Iosevka:Bold:13.0" \
        label.color=${text} \
        label.padding_left=0 \
        label.padding_right=8 \
        background.color=${surface} \
        background.corner_radius=6 \
        background.height=22 \
        padding_left=3 \
        padding_right=3

      ${sketchybar} --add event aerospace_workspace_change

      ${sketchybar} \
        ${spaceItems}

      ${sketchybar} --add item front_app left \
        --subscribe front_app front_app_switched \
        --set front_app \
          icon.font="sketchybar-app-font:Regular:15.0" \
          icon.color=${green} \
          script="${frontAppPlugin}"

      # Added right-to-left, so this reads battery | volume | clock on screen.
      ${sketchybar} --add item clock right \
        --set clock \
          icon="󰃭" \
          icon.color=${peach} \
          update_freq=15 \
          script="${clockPlugin}"

      ${sketchybar} --add item volume right \
        --subscribe volume volume_change \
        --set volume \
          icon.color=${blue} \
          script="${volumePlugin}"

      ${sketchybar} --add item battery right \
        --subscribe battery power_source_change system_woke \
        --set battery \
          update_freq=120 \
          script="${batteryPlugin}"

      ${sketchybar} --update
      ${sketchybar} --trigger aerospace_workspace_change \
        FOCUSED_WORKSPACE="$(${aerospace} list-workspaces --focused)"
    '';
  };
}
