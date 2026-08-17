{ config, ... }:
let
  apps = "${config.local.configDir}/home/apps";
  link = path: config.lib.file.mkOutOfStoreSymlink "${apps}/${path}";
in
{
  home.file = {
    ".p10k.zsh".source = link "p10k/.p10k.zsh";
    ".claude/settings.json".source = link "claude/settings.json";
  };

  xdg.configFile = {
    "ghostty/config".source = link "ghostty/config";
  };
}
