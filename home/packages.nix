{ pkgs, ... }:
{
  home.packages = with pkgs; [
    age
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
