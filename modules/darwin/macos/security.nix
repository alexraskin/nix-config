{ primaryUser, ... }:
{
  networking.applicationFirewall = {
    enable = true;
    enableStealthMode = false;
  };

  services.openssh = {
    enable = true;
    extraConfig = ''
      PermitRootLogin no
    '';
  };

  services.tailscale.enable = true;

  users.users.${primaryUser}.openssh.authorizedKeys.keys = [
    # morpheus
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL9eDKXtB1s6U9XCukV9AdQzAsSxCdX3BpALWsaMOhm+"
  ];

  security.pam.services.sudo_local = {
    touchIdAuth = true;

    reattach = true;
  };
}
