{ pkgs, lib, ... }:
let
  wallpaper = pkgs.fetchurl {
    url = "https://blob.alexraskin.dev/wallpapers/54711963389_f93f1e294c_o.jpg";
    hash = "sha256-bgTDVmpUtVIqzREtuZL76fgicmp1oXl6Idm+P3/C5M4=";
  };

  setWallpaper = pkgs.writeShellScriptBin "set-wallpaper" ''
    set -euo pipefail

    /usr/bin/osascript -e 'tell application "Finder" to set desktop picture to POSIX file "${wallpaper}"'
  '';
in
{
  config = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    home.packages = [ setWallpaper ];

    home.activation.setWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${setWallpaper}/bin/set-wallpaper
    '';
  };
}
