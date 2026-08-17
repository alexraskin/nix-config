{ pkgs, ... }:
{
  home.packages = with pkgs; [
    curl
    wget
    htop
    tree
    ripgrep
    jq

    mise
    yt-dlp
    ffmpeg
  ];
}
