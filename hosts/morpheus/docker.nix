{ primaryUser, ... }:
{
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      log-driver = "json-file";
      log-opts = {
        max-size = "10m";
        max-file = "432";
      };
      dns = [
        "1.1.1.1"
        "1.0.0.1"
      ];
    };
  };
  virtualisation.oci-containers.backend = "docker";

  users.users.${primaryUser}.extraGroups = [ "docker" ];
}
