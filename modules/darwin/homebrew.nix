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
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    global.brewfile = true;

    casks = [
      "shottr"

      # dev
      "ghostty"
      "zed"
      "claude-code"

      # browsers
      "google-chrome"

      # media
      "plex"
      "spotify"

      # fonts
      "font-b612"
      "font-iosevka"

      # other
      "1password"
      "1password-cli"
      "wifiman"
      "obsidian"
    ];
    brews = [
      "mas"
      "fastfetch"
    ];
    taps = [ ];
    masApps = {
      "Tailscale" = 1475387142;
      "Second Clock" = 6450279539;
      "WhatsApp Messenger" = 310633997;
      "Menu World Time" = 1446377255;
      "Flycut" = 442160987;
      "Passepartout" = 1433648537;
      "Yubico Authenticator" = 1497506650;
      "Xcode" = 497799835;
      "Infuse" = 1136220934;
      "Gifski" = 1351639930;

      # "Plezy: Media Server Client" = 6754315964;
      #   Left out on purpose: 6754315964 is an iOS/iPadOS app, not a Mac App
      #   Store app. It only runs on Apple Silicon via the "iPhone & iPad
      #   Apps" tab, which `mas` cannot install — adding it fails the switch.
      #   Install it from the App Store by hand.
    };
  };
}
