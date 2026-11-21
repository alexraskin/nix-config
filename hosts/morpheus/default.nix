{ lib, primaryUser, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./storage.nix
    ./docker.nix
    ./plex.nix
    ./net-check.nix
    ./rex.nix
  ];

  # installed with 26.11; modules/nixos defaults to 25.05
  system.stateVersion = lib.mkForce "26.11";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernel.sysctl."kernel.panic" = 10;

  time.timeZone = "America/Phoenix";
  networking.networkmanager.enable = true;
  # same MAC as under Debian, so the DHCP reservation (10.0.200.87) carries over;
  # infrastructure's gatus and prometheus scrape that address
  networking.interfaces.enp86s0.wakeOnLan.enable = true;
  services.journald.settings.Journal.SystemMaxUse = "500M";

  # keep the Debian uid so files restored from the old disk keep their owner
  users.users.${primaryUser} = {
    uid = 1000;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFZ/ZjjWTINdBcOkNfdsnwMJxBsCpcgNvM4wxcBEXG/a"
    ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  programs.ssh.knownHosts."github.com".publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    openFirewall = true;
    extraSetFlags = [
      "--ssh"
      "--advertise-exit-node"
    ];
  };
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  systemd.services.tailscaled-set.serviceConfig.RemainAfterExit = true;

  nix.settings.trusted-users = [ primaryUser ];
  security.sudo.wheelNeedsPassword = false;
  programs.nix-ld.enable = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.settings.auto-optimise-store = true;
}
