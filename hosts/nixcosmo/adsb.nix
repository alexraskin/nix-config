{ config, inputs, ... }:
let
  envFile = config.age.secrets.adsb-env.path;
in
{
  imports = [ inputs.agenix.nixosModules.default ];

  age.secrets.adsb-env.file = ../../secrets/adsb.env.age;

  boot.blacklistedKernelModules = [ "dvb_usb_rtl28xxu" ];

  systemd.tmpfiles.rules = [
    "d /var/lib/adsb 0750 root root -"
    "d /var/lib/adsb/globe_history 0755 root root -"
    "d /var/lib/adsb/graphs1090 0755 root root -"
  ];

  systemd.services.tailscale-serve-adsb = {
    after = [ "tailscaled.service" ];
    wants = [ "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = 10;
    };
    script = "${config.services.tailscale.package}/bin/tailscale serve --bg 8080";
  };

  virtualisation.oci-containers.containers = {
    ultrafeeder = {
      image = "ghcr.io/sdr-enthusiasts/docker-adsb-ultrafeeder:telegraf";
      hostname = "ultrafeeder";
      ports = [
        "8080:80" # tar1090
        "9273-9274:9273-9274" # telegraf + readsb prometheus
        "127.0.0.1:30005:30005" # beast out for fr24feed
      ];
      environmentFiles = [ envFile ];
      environment = {
        TZ = config.time.timeZone;
        PROMETHEUS_ENABLE = "true";
        TAR1090_ENABLE_AC_DB = "true";
        READSB_DEVICE_TYPE = "rtlsdr";
        READSB_GAIN = "autogain";
        READSB_ALT = "350m";
        MLAT_USER = "alexraskin";
        UUID = "bec05b31-8c3e-4a85-aec3-440d4fe00c0a";
        ULTRAFEEDER_CONFIG = "adsb,feed.adsb.fi,30004,beast_reduce_plus_out;adsb,in.adsb.lol,30004,beast_reduce_plus_out;mlat,feed.adsb.fi,31090,39000;mlat,in.adsb.lol,31090,39001";
      };
      volumes = [
        "/var/lib/adsb/globe_history:/var/globe_history"
        "/var/lib/adsb/graphs1090:/var/lib/collectd"
        "/proc/diskstats:/proc/diskstats:ro"
        "/dev/bus/usb:/dev/bus/usb"
      ];
      extraOptions = [
        "--device-cgroup-rule=c 189:* rwm"
        "--tmpfs=/run:exec,size=256M"
        "--tmpfs=/tmp:size=128M"
        "--tmpfs=/var/log:size=32M"
      ];
    };

    fr24feed = {
      image = "ghcr.io/sdr-enthusiasts/docker-flightradar24:latest";
      dependsOn = [ "ultrafeeder" ];
      environmentFiles = [ envFile ];
      environment = {
        BEASTHOST = "127.0.0.1";
        BEASTPORT = "30005";
        BIND_INTERFACE = "0.0.0.0";
      };
      extraOptions = [ "--network=host" ];
    };
  };
}
