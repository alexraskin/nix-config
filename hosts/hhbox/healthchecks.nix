{ config, pkgs, ... }:
{
  age.secrets.healthchecks-env.file = ../../secrets/healthchecks.env.age;

  systemd.services.healthchecks-ping = {
    description = "Ping healthchecks.io";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      DynamicUser = true;
      EnvironmentFile = config.age.secrets.healthchecks-env.path;
    };
    script = ''
      ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 -o /dev/null "$HC_PING_URL"
    '';
  };

  systemd.timers.healthchecks-ping = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "30min";
    };
  };
}
