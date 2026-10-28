{
  config,
  lib,
  pkgs,
  ...
}:
let
  incoming = "/srv/media/.putio-incoming";
  # feed name (also the /srv/media subdirectory) -> env var holding its RSS URL
  feeds = {
    movies = "PUTIO_MOVIES_RSS_URL";
    tvshows = "PUTIO_TVSHOWS_RSS_URL";
  };
in
{
  age.secrets.putio-env.file = ../../secrets/putio.env.age;

  systemd.tmpfiles.rules = [ "d ${incoming} 0755 alex users -" ];

  systemd.services = lib.mapAttrs' (
    name: urlVar:
    lib.nameValuePair "putio-sync-${name}" {
      description = "Download new put.io ${name} from RSS";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      unitConfig.RequiresMountsFor = "/srv/media";
      path = [
        pkgs.curl
        pkgs.xmlstarlet
        pkgs.coreutils
        pkgs.gnugrep
        pkgs.gnused
      ];
      serviceConfig = {
        Type = "oneshot";
        User = "alex";
        Group = "users";
        EnvironmentFile = config.age.secrets.putio-env.path;
        StateDirectory = "putio-sync/${name}";
        TimeoutStartSec = "infinity";
      };
      script = ''
        set -euo pipefail
        seen="$STATE_DIRECTORY/seen"
        touch "$seen"

        curl -fsS -m 60 --retry 3 "''$${urlVar}" \
          | xmlstarlet sel -t -m '//item[enclosure/@url]' -v 'guid' -o $'\t' -v 'enclosure/@url' -n \
          | while IFS=$'\t' read -r guid url; do
              key="''${guid:-$url}"
              grep -qxF "$key" "$seen" && continue

              tmp=$(mktemp -d -p ${incoming})
              echo "downloading $key"
              # abort if throughput stays under 10KB/s for 5 minutes so a stalled transfer retries next run
              if curl -fL --retry 5 --speed-limit 10240 --speed-time 300 \
                   -J -O --output-dir "$tmp" "$url" </dev/null; then
                for f in "$tmp"/*; do
                  target=/srv/media/${name}
                  ${lib.optionalString (name == "tvshows") ''
                    # Show.Name.S01E02... -> Show Name/Season 01/; unmatched files stay in tvshows/
                    re='^(.+)[. _-]+[Ss]([0-9]{1,2})[Ee][0-9]{1,3}'
                    if [[ $(basename "$f") =~ $re ]]; then
                      show=$(echo "''${BASH_REMATCH[1]}" | tr '._' '  ' | sed -E 's/ +/ /g; s/^ | $//g')
                      target=$(printf '%s/%s/Season %02d' "$target" "$show" "$((10#''${BASH_REMATCH[2]}))")
                    fi
                  ''}
                  mkdir -p "$target"
                  mv -n "$f" "$target/"
                done
                echo "$key" >> "$seen"
              else
                echo "failed $key, will retry"
              fi
              rm -rf "$tmp"
            done
      '';
    }
  ) feeds;

  systemd.timers = lib.mapAttrs' (
    name: _:
    lib.nameValuePair "putio-sync-${name}" {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "2min";
        OnUnitInactiveSec = "30min";
      };
    }
  ) feeds;
}
