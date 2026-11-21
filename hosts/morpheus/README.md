# morpheus: Debian → NixOS cutover

Intel NUC13 (i7, 32 GB). NixOS goes on the 1.8 TB NVMe; the Debian install on the
500 GB SATA SSD (`sda`) is left untouched as rollback and as the source for data,
mounted read-only at `/mnt/debian`. Reformat it as `/var/lib` storage once settled.

## What carries over

| Debian | NixOS |
| --- | --- |
| plex (docker compose, host net, `/dev/dri`) | `plex.nix`, `docker-plex.service`, same `/var/lib/plexmediaserver` |
| prom-plex-exporter on :9001 | `plex.nix`, token in `secrets/morpheus-plex.env.age` |
| net-check agent (locally built image) | `net-check.nix`, image loaded by hand (see below) |
| plex-backup / plex-cleanup timers + scripts | `plex.nix` + `plex-backup*.sh`, webhook in agenix |
| `mnt-media.mount`, `mnt-plex_backup.mount` (NFS over tailnet) | `storage.nix`, automounted after tailscaled |
| wol.service | `networking.interfaces.enp86s0.wakeOnLan` |
| docker `daemon.json` (log rotation, DNS) | `docker.nix` |
| tailscale `morpheus`, `--ssh`, exit node | `default.nix`; state copied so IP stays 100.73.219.120 |
| ssh host keys | copied, so known_hosts and agenix keep working |
| `~/.ssh/id_ed25519` (alex@morpheus) | copied from the old home |
| — | Rex on its own tailnet node `rex`; Plex served at `https://morpheus.tail649c4.ts.net` |

Dropped: meowbot, fileserver, NUT, cron `certs.sh` (already disabled; Tailscale Serve
now provides the HTTPS cert), the `k3s-nix-store` docker volume and unused images.

## Before

1. Commit and push this config (autoUpgrade pulls `github:alexraskin/nix-config#morpheus`).
2. Back up anything on the NVMe you care about (only the old Proxmox `vm-102-disk-0` LVM).
3. Export the net-check image: `ssh morpheus 'docker save net-check-agent:latest' > net-check-agent.tar`
   (or just rebuild it from the repo afterwards).
4. Take a final Plex backup: `sudo systemctl start plex-backup` on Debian.

## Install (from the NixOS installer USB)

```sh
# NVMe: 1G ESP, 16G swap, rest root — the labels are what hardware-configuration.nix mounts
sudo vgchange -an neo-lvm-group
sudo wipefs -a /dev/nvme0n1
sudo parted /dev/nvme0n1 -- mklabel gpt \
  mkpart ESP fat32 1MiB 1GiB set 1 esp on \
  mkpart swap linux-swap 1GiB 17GiB \
  mkpart root ext4 17GiB 100%
sudo mkfs.fat -F32 -n BOOT /dev/nvme0n1p1
sudo mkswap -L swap /dev/nvme0n1p2
sudo mkfs.ext4 -L nixos /dev/nvme0n1p3

sudo mount /dev/disk/by-label/nixos /mnt
sudo mount --mkdir -o umask=077 /dev/disk/by-label/BOOT /mnt/boot

# carry over identity from Debian BEFORE first boot
sudo mount --mkdir -o ro /dev/sda2 /old
sudo mkdir -p /mnt/etc/ssh /mnt/var/lib/tailscale
sudo cp -a /old/etc/ssh/ssh_host_* /mnt/etc/ssh/
sudo cp -a /old/var/lib/tailscale/. /mnt/var/lib/tailscale/
# plex library now, so plex never starts empty and sets itself up as a new server
sudo mkdir -p /mnt/var/lib/plexmediaserver
sudo cp -a /old/var/lib/plexmediaserver/. /mnt/var/lib/plexmediaserver/

# compare hardware detection with hardware-configuration.nix
nixos-generate-config --show-hardware-config --root /mnt | less

sudo nixos-install --flake github:alexraskin/nix-config#morpheus --no-root-passwd
```

Make sure Debian is never booted again while the NixOS node is online: both would
use the same Tailscale node key.

## After first boot

Delete the old `rex` node in the Tailscale admin console (its state stayed in
Debian's ~/.local/state/rex); keep `morpheus`, whose state was copied.

```sh
# data from the old disk (mounted ro at /mnt/debian)
rsync -a /mnt/debian/home/alex/.ssh/id_ed25519* ~/.ssh/
rsync -a /mnt/debian/home/alex/coding ~/          # plus whatever else of the 54G home you want

docker load < net-check-agent.tar && sudo systemctl restart docker-net-check-agent

# Rex's tailnet node: open the login URL it prints, then it's rex.tail649c4.ts.net
journalctl -u rex -f
```

Checks:

- `tailscale status` shows `morpheus` at 100.73.219.120, `tailscale serve status` shows Plex on 443
- `ls /mnt/media/Media /mnt/plex_backup` (automounts)
- `curl -s localhost:32400/identity`, Plex plays with hardware transcoding (Settings → Transcoder)
- `curl -s localhost:9001/metrics | head` (gatus and prometheus scrape 10.0.200.87)
- `systemctl list-timers 'plex-*'`
- `systemctl status docker-net-check-agent rex`
- In Plex → Network → Custom server access URLs, use `https://morpheus.tail649c4.ts.net:443`
  (replaces the old p12 cert)
