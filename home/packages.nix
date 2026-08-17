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
    plezy

    mise
    yt-dlp
    ffmpeg
  ];
}
