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
      # the NAS is only reachable once tailscaled is up; mount on first access
      "x-systemd.automount"
      "x-systemd.after=tailscaled.service"
      "x-systemd.mount-timeout=60"
    ];
  };
in
{
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
