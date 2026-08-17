{ ... }:
{
  # The firewall is already on; this pins it so a rebuild can't leave it off.
  # Stealth mode is left alone — it silently drops pings and unsolicited
  # probes, which is a nuisance when debugging your own LAN.
  networking.applicationFirewall = {
    enable = true;
    enableStealthMode = false;
  };

  security.pam.services.sudo_local = {
    touchIdAuth = true;

    # Keeps Touch ID for sudo working inside tmux and other reattached
    # sessions, where pam_tid would otherwise fail.
    reattach = true;
  };
}
