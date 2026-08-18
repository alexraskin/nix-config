{ pkgs, lib, ... }:
let
  wallpaper = pkgs.fetchurl {
    url = "https://misc-assets.raycast.com/wallpapers/loupe-mono-dark.heic";
    hash = "sha256-MwvRU7U4tO6F1duxBrHLOd7F5Gnzv/zyiZkm5EFqkY4=";
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
