{ config, ... }:
{
  # AUTH_TOKEN and SERVER_URL for the net-check agent
  age.secrets.net-check-env.file = ../../secrets/net-check.env.age;

  # github.com/alexraskin/net-check is private and not published to a registry,
  # so the image is built from that repo and loaded by hand:
  #   docker build -t net-check-agent:latest .   (or docker save | docker load)
  virtualisation.oci-containers.containers.net-check-agent = {
    image = "net-check-agent:latest";
    pull = "never";
    environmentFiles = [ config.age.secrets.net-check-env.path ];
    environment = {
      MODE = "agent";
      HEARTBEAT_INTERVAL = "30s";
      HEARTBEAT_TIMEOUT = "90s";
      LISTEN_ADDR = ":8080";
      LISTEN_PORT = "8080";
    };
  };
}
