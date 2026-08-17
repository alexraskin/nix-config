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
      # Must stay false while masApps is non-empty. With auto-update on, brew
      # updates and then re-execs itself through bin/brew's "filter the user
      # environment" step, which resets PATH to git + /usr/bin:/bin:/usr/sbin:/sbin.
      # HOMEBREW_PATH becomes that filtered PATH, so `which("mas")` — which brew
      # resolves against it — comes up empty, brew decides mas isn't installed,
      # `brew install mas` reports it already is, and every app dies with
      # "Unable to install <app> app. mas installation failed."
      #
      # Disabling it puts HOMEBREW_NO_AUTO_UPDATE=1 on the activation command,
      # skipping the re-exec so /opt/homebrew/bin survives and mas resolves.
      # Formula metadata then only refreshes when you run `brew update`.
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
    };
  };
}
