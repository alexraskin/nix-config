{
  inputs,
  primaryUser,
  ...
}:
{
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  nix-homebrew = {
    user = primaryUser;
    enable = true;
    autoMigrate = true;
  };

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;

      upgrade = true;
      cleanup = "zap";
    };

    global.brewfile = true;

    casks = [
      "shottr"

      # dev
      "ghostty"
      "zed"

      # browsers
      "google-chrome"

      # media
      "spotify"

      # fonts
      "font-b612"
      "font-iosevka"

      "1password"
      "1password-cli"
      "wifiman"
      "obsidian"
    ];
    brews = [
      "mas"
      "fastfetch"

      {
        name = "rift";
        start_service = true;
        restart_service = "changed";
      }
    ];
    taps = [
      {
        name = "acsandmann/tap";
        trusted = true;
      }
    ];
    masApps = {
      "Tailscale" = 1475387142;
      "Second Clock" = 6450279539;
      "WhatsApp Messenger" = 310633997;
      "Flycut" = 442160987;
      "Passepartout" = 1433648537;
      "Yubico Authenticator" = 1497506650;
      "Gifski" = 1351639930;
    };
  };
}
