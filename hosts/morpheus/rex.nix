{ inputs, primaryUser, ... }:
{
  imports = [ inputs.rex.nixosModules.default ];

  # Rex joins the tailnet as its own node, rex.tail649c4.ts.net, so morpheus's
  # own Serve mapping stays free for Plex. The node's identity lives in
  # /var/lib/rex/tsnet/rex; first start logs a login URL (journalctl -u rex).
  # Only the Tailscale account that enrolls it may connect.
  services.rex = {
    enable = true;
    user = primaryUser;
    group = "users";
    tailscale = {
      enable = true;
      hostname = "rex";
    };
  };
}
