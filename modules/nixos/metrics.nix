{
  # Scraped over the tailnet via infrastructure's apps/base/monitoring/egress.yaml; the LAN keeps 9100 closed.
  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [ "systemd" ];
  };
}
