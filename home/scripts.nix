{ pkgs, ... }:
let
  rip = pkgs.writeShellApplication {
    name = "rip";
    runtimeInputs = [ pkgs.ffmpeg ];
    text = ''
      if [[ -z "''${1:-}" ]]; then
        echo "Usage: $(basename "$0") <URL to stream video from> [output name]"
        exit 1
      fi

      output_name="''${2:-video.mp4}"

      ffmpeg -i "$1" -c copy -bsf:a aac_adtstoasc "$output_name"
    '';
  };

  rip-yt = pkgs.writeShellApplication {
    name = "rip-yt";
    runtimeInputs = [
      pkgs.yt-dlp
      pkgs.ffmpeg
      pkgs.coreutils
    ];
    text = ''
      usage() {
        echo "Usage: $(basename "$0") <URL>"
        echo
        echo "Description:"
        echo "  Downloads the best available MP4 video using yt-dlp."
        echo
        echo "Examples:"
        echo "  $(basename "$0") https://www.youtube.com/watch?v=phRn9Thc1zc"
        exit 1
      }

      if [ $# -eq 0 ]; then
        usage
      fi

      URL="$1"
      OUTPUT_DIR="$HOME/documents/youtube-videos"

      mkdir -p "$OUTPUT_DIR"

      yt-dlp -f "bestvideo[ext=mp4][vcodec^=avc1]+bestaudio[ext=m4a]/best[ext=mp4]" \
        --merge-output-format mp4 \
        -o "$OUTPUT_DIR/%(title)s.%(ext)s" \
        --cookies-from-browser chrome "$URL"
    '';
  };

  fwd = pkgs.writeShellApplication {
    name = "fwd";
    text = ''
      PORT="''${1:-3000}"

      echo "Forwarding port $PORT to localhost:$PORT"

      ssh alex@morpheus -N -L "$PORT":localhost:"$PORT"
    '';
  };
in
{
  home.packages = [
    rip
    rip-yt
    fwd
  ];
}
