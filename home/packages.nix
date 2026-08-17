{ pkgs, lib, ... }:
{
  home.packages =
    with pkgs;
    [
      curl
      wget
      htop
      tree
      ripgrep
      jq
      gh

      mise
      yt-dlp
      ffmpeg
    ]
    ++ lib.optionals stdenv.isDarwin [
      xcode-install
    ];
}
