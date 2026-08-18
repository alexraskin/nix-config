{ pkgs, lib, ... }:
let
  wallpaper = pkgs.fetchurl {
    url = "https://cdn.alexraskin.com/wallpapers/mbawp.jpg";
    hash = "sha256-mt/4yPoAc6C6++fL0eQKGqIzNt2mgblgGvPlgfKLPrM=";
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
