{ config, inputs, ... }:
{
  imports = [ inputs.agenix.nixosModules.default ];

  # contains WIFI_SSID=... and WIFI_PSK=...
  age.secrets.wifi-env.file = ../../secrets/wifi.env.age;

  # NetworkManager's default route metrics (ethernet 100, wifi 600) keep eno1 preferred when plugged in
  networking.networkmanager.ensureProfiles = {
    environmentFiles = [ config.age.secrets.wifi-env.path ];
    profiles.home-wifi = {
      connection = {
        id = "home-wifi";
        type = "wifi";
        interface-name = "wlp0s20f0u3";
        autoconnect = true;
      };
      wifi = {
        mode = "infrastructure";
        ssid = "$WIFI_SSID";
      };
      wifi-security = {
        key-mgmt = "wpa-psk";
        psk = "$WIFI_PSK";
      };
      ipv4.method = "auto";
      ipv6.method = "auto";
    };
  };
}
