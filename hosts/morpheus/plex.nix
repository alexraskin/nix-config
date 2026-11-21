{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  dataDir = "/var/lib/plexmediaserver";
  envFile = config.age.secrets.plex-env.path;

  runtimeInputs = with pkgs; [
    coreutils
    curl
    gnugrep
    gnused
    gnutar
    gzip
    findutils
    util-linux
    systemd
    inetutils
  ];
  plex-backup = pkgs.writeShellApplication {
    name = "plex-backup";
    inherit runtimeInputs;
    text = builtins.readFile ./plex-backup.sh;
  };
  plex-backup-cleanup = pkgs.writeShellApplication {
    name = "plex-backup-cleanup";
    inherit runtimeInputs;
    text = builtins.readFile ./plex-backup-cleanup.sh;
  };

  backupService = description: exe: log: {
    inherit description;
    unitConfig.RequiresMountsFor = "/mnt/plex_backup";
    restartIfChanged = false;
    environment = {
      PLEX_DATA_DIR = dataDir;
      PLEX_UNIT = "docker-plex.service";
      BACKUP_DIR = "/mnt/plex_backup";
      BACKUP_LOG = "/mnt/plex_backup/${log}";
    };
    serviceConfig = {
      Type = "oneshot";
      EnvironmentFile = envFile;
      ExecStart = lib.getExe exe;
      TimeoutStartSec = "4h";
    };
  };
in
{
  imports = [ inputs.agenix.nixosModules.default ];

  # PLEX_TOKEN (exporter) and DISCORD_WEBHOOK (backup notifications)
  age.secrets.plex-env.file = ../../secrets/morpheus-plex.env.age;

  systemd.tmpfiles.rules = [
    "d ${dataDir} 0755 alex users -"
    "d /var/cache/plex-transcode 0755 alex users -"
  ];

  virtualisation.oci-containers.containers = {
    plex = {
      image = "plexinc/pms-docker:latest";
      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = config.time.timeZone;
      };
      volumes = [
        "/etc/localtime:/etc/localtime:ro"
        "${dataDir}:/config"
        "/var/cache/plex-transcode:/transcode"
        "/mnt/media/Media:/media:ro"
      ];
      extraOptions = [
        "--network=host"
        "--device=/dev/dri:/dev/dri"
      ];
    };

    prom-plex-exporter = {
      image = "ghcr.io/jsclayton/prometheus-plex-exporter:latest";
      # scraped by infrastructure's apps/base/monitoring at 10.0.200.87:9001
      ports = [ "9001:9000" ];
      environmentFiles = [ envFile ];
      environment.PLEX_SERVER = "http://host.docker.internal:32400";
      dependsOn = [ "plex" ];
      extraOptions = [ "--add-host=host.docker.internal:host-gateway" ];
    };
  };

  systemd.services.docker-plex.unitConfig.RequiresMountsFor = [ "/mnt/media/Media" ];

  # https://morpheus.tail649c4.ts.net -> plex, with tailscale's own cert
  systemd.services.tailscale-serve-plex = {
    after = [ "tailscaled.service" ];
    wants = [ "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = 10;
    };
    script = "${config.services.tailscale.package}/bin/tailscale serve --bg --https=443 http://127.0.0.1:32400";
  };

  networking.firewall = {
    allowedTCPPorts = [
      32400 # plex
      8324 # plex companion
      32469 # dlna
      9001 # prom-plex-exporter
    ];
    allowedUDPPorts = [
      1900 # dlna
      32410 # gdm discovery
      32412
      32413
      32414
    ];
    # the exporter reaches plex from the docker bridge
    interfaces.docker0.allowedTCPPorts = [ 32400 ];
  };

  systemd.services.plex-backup =
    backupService "Back up the Plex library to the NAS" plex-backup
      "backup.log";
  systemd.services.plex-backup-cleanup =
    backupService "Prune old Plex backups" plex-backup-cleanup
      "cleanup.log";

  # infrastructure's gatus has a maintenance window around this time; keep them in sync
  systemd.timers.plex-backup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-1/4 22:00:00 America/Denver";
      Persistent = true;
    };
  };
  systemd.timers.plex-backup-cleanup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-1/4 04:00:00";
      Persistent = true;
    };
  };
}
