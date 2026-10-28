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
  putio-sync = pkgs.writeShellApplication {
    name = "putio-sync";
    runtimeInputs = [
      pkgs.curl
      pkgs.xmlstarlet
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.gnused
    ];
    text = builtins.readFile ./putio-sync.sh;
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
      environment = {
        PUTIO_DEST = "/srv/media/${name}";
        PUTIO_INCOMING = incoming;
        PUTIO_SORT_TV = if name == "tvshows" then "1" else "0";
      };
      serviceConfig = {
        Type = "oneshot";
        User = "alex";
        Group = "users";
        EnvironmentFile = config.age.secrets.putio-env.path;
        StateDirectory = "putio-sync/${name}";
        TimeoutStartSec = "infinity";
      };
      # the secret holds one URL per feed; hand the right one to the script
      script = ''
        PUTIO_RSS_URL="''$${urlVar}" exec ${lib.getExe putio-sync}
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
