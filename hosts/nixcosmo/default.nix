{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./adsb.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernel.sysctl."kernel.panic" = 10;

  time.timeZone = "America/Phoenix";
  networking.networkmanager.enable = true;
  services.journald.extraConfig = "SystemMaxUse=500M";

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

  nix.settings.trusted-users = [ "alex" ];
  security.sudo.wheelNeedsPassword = false;
  programs.nix-ld.enable = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.settings.auto-optimise-store = true;
}
