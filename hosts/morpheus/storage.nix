{ config, ... }:
let
  # Synology, reached over the tailnet; its NFS rules allow morpheus's tailnet IP (100.73.219.120)
  nas = "100.109.167.97";
  nfs = share: {
    device = "${nas}:/volume1/${share}";
    fsType = "nfs";
    options = [
      "noatime"
      "rsize=8192"
      "_netdev"
      "nofail"
      # the NAS is only reachable once the tailnet is up, which is later than
      # tailscaled.service starting; mount on first access after that
      "x-systemd.automount"
      "x-systemd.requires=tailscale-online.service"
      "x-systemd.after=tailscale-online.service"
      "x-systemd.mount-timeout=120"
    ];
  };
in
{
  systemd.services.tailscale-online = {
    description = "Wait for the tailnet to be up";
    after = [ "tailscaled.service" ];
    requires = [ "tailscaled.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${config.services.tailscale.package}/bin/tailscale wait";
      TimeoutStartSec = "5min";
    };
  };

  boot.supportedFilesystems = [ "nfs" ];

  fileSystems."/mnt/media" = nfs "media";
  fileSystems."/mnt/plex_backup" = nfs "plex_backup";

  # The old Debian root on the SATA SSD, kept read-only for the migration
  # (home dir, plex library, tailscale state). Reformat as /var/lib storage later.
  fileSystems."/mnt/debian" = {
    device = "/dev/disk/by-uuid/277b8702-2a7d-4370-a9ac-fb258b309637";
    fsType = "ext4";
    options = [
      "ro"
      "nofail"
    ];
  };
}
